local pd <const> = playdate
local gfx <const> = pd.graphics
local image_table <const> = gfx.imagetable.new("Assets/player")
local dead_particle_img <const> = gfx.image.new(10, 10, gfx.kColorWhite)
local k_left <const> = pd.kButtonLeft
local k_right <const> = pd.kButtonRight
local k_up <const> = pd.kButtonUp
local k_down <const> = pd.kButtonDown
local k_jump <const> = pd.kButtonA
local k_dash <const> = pd.kButtonB
local sqrt_one_half <const> = 0.70710678118
local spikes_at <const> = pico8.celeste.spikes_at
local clamp <const> = pico8.celeste.clamp
local appr <const> = pico8.celeste.appr
local sign <const> = pico8.celeste.sign
local flip <const> = pico8.flip
local sin <const> = pico8.sin
local cos <const> = pico8.cos
local del <const> = pico8.del

class('Player').extends(ParentObject)

-- Player
--
function Player:init(x, y, parent)

	Player.super.init(self, x, y, parent)

	self.type_id = 18
	self.p_jump = false
	self.p_dash = false
	self.grace = 0
	self.jbuffer = 0
	self.djump = self.parent.parent.max_djump
	self.dash_time = 0
	self.dash_effect_time = 0
	self.dash_target = pd.geometry.vector2D.new(0, 0)
	self.dash_accel = pd.geometry.vector2D.new(0, 0)
	self.spr = 3
	self.spr_off = 0
	self.hitbox = pd.geometry.rect.new(1,3,6,5)
	self.pos = pd.geometry.point.new(x, y)
	self.solids = true
	self.hair = Hair(self)

	self.collisionResponse = gfx.sprite.kCollisionTypeOverlap
	self:setZIndex(20)
	self:setCollideRect(self.hitbox:offsetBy(1,1))
	self:setCollidesWithGroups({2,3,4,5,6})
	self:setGroups({1})
	self:add()


	pico8.frames = 0

	return self

end

function Player:_update()

	if (self.pause_player) then return end

	local input = pico8.btn(k_right) and 1 or (pico8.btn(k_left) and -1 or 0)

	-- Spikes collide
	local _, _, collisions_at_x_y, length = self:checkCollisions(self.pos.x, self.pos.y)
	if length > 0 then
		for i=1, #collisions_at_x_y do
			local col = collisions_at_x_y[i]
			if col.other.type == "spikes" then
				if spikes_at(self.pos.x + self.hitbox.x, self.pos.y + self.hitbox.y, self.hitbox.width, self.hitbox.height, self.spd.x, self.spd.y) then
					self:kill()
				end
			end
		end
	end

	-- Bottom death
	if self.pos.y > 128 then
		self:kill()
	end
	
	local on_ground = self:is_solid(0, 1)
	local on_ice = self:is_ice(0, 1)

	-- Smoke particles
	if on_ground and not self.was_on_ground then
		Smoke(self.pos.x, self.pos.y + 4, self.parent)
	end

	-- Jump
	local jump = pico8.btn(k_jump) and not self.p_jump
	self.p_jump = pico8.btn(k_jump)
	if jump then
		self.jbuffer = 4
	elseif self.jbuffer > 0 then
		self.jbuffer -= 1
	end

	-- Dash
	local dash = pico8.btn(k_dash) and not self.p_dash
	self.p_dash = pico8.btn(k_dash)

	-- Grace
	if on_ground then
		self.grace = 6
		if self.djump < self.parent.parent.max_djump then
			psfx(54)
			self.djump = self.parent.parent.max_djump
		end
	elseif self.grace > 0 then
		self.grace -= 1
	end

	self.dash_effect_time -= 1
	-- Player just dashed
	if self.dash_time > 0 then
		Smoke(self.pos.x, self.pos.y, self.parent)
		self.dash_time -= 1
		self.spd.x = appr(self.spd.x, self.dash_target.x, self.dash_accel.x)
		self.spd.y = appr(self.spd.y, self.dash_target.y, self.dash_accel.y)
	else
		-- Move
		local maxrun = 1
		local accel = 0.6
		local deccel = 0.15

		if not on_ground then
			accel = 0.4
		elseif on_ice then
			accel = 0.05
			if input == (self.flip.x and -1 or 1) then
				accel = 0.05
			end
		end

		if math.abs(self.spd.x) > maxrun then
			self.spd.x = appr(self.spd.x, sign(self.spd.x) * maxrun, deccel)
		else
			self.spd.x = appr(self.spd.x, input*maxrun, accel)
		end

		-- Facing
		if self.spd.x ~= 0 then
			self.flip.x = (self.spd.x < 0)
		end

		-- Gravity
		local maxfall = 2
		local gravity = 0.21

		if math.abs(self.spd.y) <= 0.15 then
			gravity *= 0.5
		end

		-- Wall slide
		if input ~= 0 and self:is_solid(input, 0) and not self:is_ice(input, 0) then
			maxfall = 0.4
			if (math.random() * 10) < 2 then
				Smoke(self.pos.x + input * 6, self.pos.y, self.parent)
			end
		end

		if not on_ground then
			self.spd.y = appr(self.spd.y, maxfall, gravity)
		end

		-- Jump
		if self.jbuffer > 0 then
			if self.grace > 0 then
				-- Normal jump
				psfx(1)
				self.jbuffer = 0
				self.grace = 0
				self.spd.y = -2
				Smoke(self.pos.x, self.pos.y + 4, self.parent)
			else
				-- Wall jump
				local wall_dir = (self:is_solid(-3, 0) and -1 or self:is_solid(3, 0) and 1 or 0)
				if wall_dir ~= 0 then
					psfx(2)
					self.jbuffer = 0
					self.spd.y = -2
					self.spd.x = -wall_dir * (maxrun + 1)
					if not self:is_ice(wall_dir * 3, 0) then
						Smoke(self.pos.x + wall_dir * 6, self.pos.y, self.parent)
					end
				end
			end
		end

		-- Dash
		local d_full = 5
		local d_half = d_full * sqrt_one_half
		
		if self.djump > 0 and dash then
			Smoke(self.pos.x, self.pos.y, self.parent)
			self.djump -= 1
			self.dash_time = 4
			self.parent.has_dashed = true
			self.dash_effect_time = 10
			local v_input = (pico8.btn(k_up) and -1 or (pico8.btn(k_down) and 1 or 0))
			if input ~= 0 then
				if v_input ~= 0 then
					self.spd.x = input * d_half
					self.spd.y = v_input * d_half
				else
					self.spd.x = input * d_full
					self.spd.y = 0
				end
			elseif v_input ~= 0 then
				self.spd.x = 0
				self.spd.y = v_input * d_full
			else
				self.spd.x = (self.flip.x and -1 or 1)
				self.spd.y = 0
			end

			psfx(3)
			self.parent.parent.freeze = 2
			self.parent.parent.shake = 6
			self.dash_target.x = 2 * sign(self.spd.x)
			self.dash_target.y = 2 * sign(self.spd.y)
			self.dash_accel.x = 1.5
			self.dash_accel.y = 1.5
			
			if self.spd.y < 0 then
				self.dash_target.y *= .75
			end
			
			if self.spd.y ~= 0 then
				self.dash_accel.x *= sqrt_one_half
			end
			if self.spd.x ~= 0 then
				self.dash_accel.y *= sqrt_one_half
			end  
		elseif dash and self.djump <= 0 then
			psfx(9)
			Smoke(self.pos.x, self.pos.y, self.parent)
		end
	end

	-- Animation
	self.spr_off += 0.25
	if not on_ground then
		if self:is_solid(input, 0) then
			self.spr = 5
		else
			self.spr = 3
		end
	elseif pico8.btn(k_down) then
		-- Crouching down
		self.spr = 6
	elseif pico8.btn(k_up) then
		-- Looking up
		self.spr = 7
	elseif (self.spd.x == 0) or (not pico8.btn(k_left) and not pico8.btn(k_right)) then
		-- Stale
		self.spr = 1
	else
		-- Running left or right
		self.spr = 1 + self.spr_off % 4
	end

	-- Next level
	if self.pos.y < -8 and self.parent.parent.level_index < 30 then
		self.pos.y = 0
		self.pos.x = 0
		self.parent.parent:nextRoom()
	end

	-- Was on the ground
	self.was_on_ground = on_ground

end

function Player:_update_collisions()

	-- -- FallFloor collisions
	-- -- We check if the player hits a FallFloor horizontally or from the bottom.
	-- -- So we set a rectangle that's 2px wider than the player and 1px taller.
	-- local rect = pd.geometry.rect.new(self.pos.x + self.hitbox.x - 1, self.pos.y + self.hitbox.y, self.hitbox.width + 2, self.hitbox.height + 1)
	-- local query = gfx.sprite.querySpritesInRect(rect)
	-- if #query > 1 then
	-- 	for i=1, #query do
	-- 		local other = query[i]
	-- 		if other.className == "FallFloor" then
	-- 			other:hit(self)
	-- 		end
	-- 	end
	-- end

	-- -- Platform collisions
	-- self:setCollidesWithGroups({4})
	-- local _, _, collisions_at_x_y_plus_1, length = self:checkCollisions(self.x, self.y + 1)
	-- if length > 0 then
	-- 	for i=1, #collisions_at_x_y_plus_1 do
	-- 		local col = collisions_at_x_y_plus_1[i]
	-- 		local other = col.other
	-- 		if other.className == "Platform" then
	-- 			other:hit(self)
	-- 		end
	-- 	end
	-- end
	-- self:setCollidesWithGroups({2,3,4,5,6})

end

function Player:_draw()

	local max_x = 200 - (8 - 1) - self.parent.offset.x
	if self.pos.x < -1 or self.pos.x > max_x then 
		self.pos.x = clamp(self.pos.x, -1, max_x)
		self.spd.x = 0
	end

	-- Orb effect or dash effect
	local spr_offset = 0
	local has_orb_effect = (self.djump >= 2 and math.floor((self.parent.parent.frames / 3) % 2) == 0)
	-- if reduce_flashing then
	-- 	has_orb_effect = false
	-- end
	if self.djump == 0 or has_orb_effect then
		spr_offset = 7
	end

	local img = image_table:getImage(math.floor(self.spr + spr_offset))
	self:setImage(img, flip(self.flip.x, self.flip.y))
	self:moveTo(self.pos.x - 1, self.pos.y - 1)

	if self.hair ~= nil then
		self.hair:_draw(self, self.flip.x and -1 or 1)
	end

end

function Player:destroy()

	Player.super.destroy(self)
	if self.hair ~= nil then
		self.hair:remove()
	end

end

-- kill
--
function Player:kill()

	self.parent.parent.sfx_timer = 12
	sfx(0)
	self.parent.parent.deaths += 1
	self.parent.parent.shake = 10
	self:destroy()
	self:addDeadParticles()
	self.parent:restart()

end

function Player:addDeadParticles()

	local dir
	for dir = 0, 7 do
		local angle = (dir / 8)
		local particle = {
			x = self.pos.x + 4,
			y = math.min(self.pos.y + 4, 120),
			t = 10,
			spd = {
				x = sin(angle) * 3,
				y = cos(angle) * 3
			},
			spr = gfx.sprite.new(dead_particle_img)
		}
		particle.spr:setZIndex(30)
		particle.spr:add()
		particle.spr:moveTo(particle.x, particle.y)
		particle.spr.update = function()
			particle.x += particle.spd.x
			particle.y += particle.spd.y
			particle.t -= 1
			if particle.t <= 0 then
				particle.spr:remove()
			else
				local new_t <const> = math.floor(particle.t / 5) + 1
				particle.spr:setSize(new_t, new_t)
				particle.spr:moveTo(particle.x, particle.y)
			end
		end
	end

end
