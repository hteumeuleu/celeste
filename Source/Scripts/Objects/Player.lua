local pd <const> = playdate
local gfx <const> = pd.graphics
local offset <const> = pd.geometry.point.new(-4, -4)
local image_table <const> = gfx.imagetable.new("Assets/player")
local k_left <const> = pd.kButtonLeft
local k_right <const> = pd.kButtonRight
local k_up <const> = pd.kButtonUp
local k_down <const> = pd.kButtonDown
local k_jump <const> = pd.kButtonA
local k_dash <const> = pd.kButtonB
local max_djump <const> = 1
local sqrt_one_half <const> = 0.70710678118
local btn = function(i) return pd.buttonIsPressed(i) end
local appr = function(val, target, amount) return val > target and math.max(val - amount, target) or math.min(val + amount, target) end
local sign = function(v) return v > 0 and 1 or v < 0 and -1 or 0 end
local flip = function(flip_x, flip_y)
	local image_flip =  gfx.kImageUnflipped
	if flip_x and flip_y then
		 image_flip = gfx.kImageFlippedXY
	elseif flip_x then
		 image_flip = gfx.kImageFlippedX
	elseif flip_y then
		 image_flip = gfx.kImageFlippedY
	end
	return image_flip
end

class('Player').extends(gfx.sprite)

-- Player
--
function Player:init(x, y)

	Player.super.init(self)
	self.p_jump = false
	self.p_dash = false
	self.grace = 0
	self.jbuffer = 0
	self.djump = max_djump
	self.dash_time = 0
	self.dash_effect_time = 0
	self.dash_target = pd.geometry.vector2D.new(0, 0)
	self.dash_accel = pd.geometry.vector2D.new(0, 0)
	self.spr = 3
	self.spr_off = 0
	self.flip = {}
	self.flip.x = false
	self.flip.y = false
	self.hitbox = pd.geometry.rect.new(1,3,6,5)
	self.spd = pd.geometry.vector2D.new(0, 0)
	self.rem = pd.geometry.vector2D.new(0, 0)
	self.pos = pd.geometry.point.new(x, y)
	self.solids = true
	self:setCenter(0, 0)
	self:setZIndex(20)
	self:setCollideRect(self.hitbox:offsetBy(1,1))
	self:setCollidesWithGroups({2,3,4,5,6})
	self:setGroups({1})
	self.collisionResponse = gfx.sprite.kCollisionTypeOverlap
	self:moveTo(self.pos.x, self.pos.y)
	self:add()
	return self

end

function Player:_update()

	if (self.pause_player) then return end

	local on_ground = self:is_solid(0, 1)
	local on_ice = self:is_ice(0, 1)

	-- TODO: `Fall Floor` collisions
	-- local query = playdate.graphics.sprite.querySpritesInRect(self.x + self.hitbox.x - 1, self.y + self.hitbox.y, self.hitbox.width + 2, self.hitbox.height + 1)
	-- if #query > 1 then
	-- 	for i=1, #query do
	-- 		local other = query[i]
	-- 		if other.type == "fall_floor" then
	-- 			-- break_fall_floor(other.obj) -- TODO
	-- 		end
	-- 	end
	-- end
	print(self.pos)

	-- Collisions
	local _, _, collisions_at_x_y, length = self:checkCollisions(self.x, self.y)
	if length > 0 then
		for i=1, #collisions_at_x_y do
			local col = collisions_at_x_y[i]
			local playerIsAboveObject = col.spriteRect.y + col.spriteRect.height <= col.otherRect.y + col.otherRect.height
			local playerIsUnder = (col.spriteRect.y >= col.otherRect.y + col.otherRect.height) and ((col.spriteRect.x + col.spriteRect.width >= col.otherRect.x) or (col.spriteRect.x <= col.otherRect.x + col.otherRect.width))
			if col.other.type == "spikes" then
				-- -- spikes collide
				-- if game_obj.options:get("invicibility") == false then
				-- 	if spikes_at(this.x+this.hitbox.x,this.y+this.hitbox.y,this.hitbox.width,this.hitbox.height,this.spd.x,this.spd.y) then
				-- 		kill_player(this)
				-- 	end
				-- end
			elseif (col.other.type == "fruit" or col.other.type == "fly_fruit") and col.other.hit ~= nil then
				-- col.other:hit(col.sprite.obj)
			elseif col.other.type == "balloon" and col.other.hit ~= nil then
				-- col.other:hit(col.sprite.obj)
			elseif col.other.type == "platform" and col.other.hit ~= nil and on_ground and playerIsAboveObject then
				-- col.other:hit(col.sprite.obj)
			end
		end
	end

	local input = btn(k_right) and 1 or (btn(k_left) and -1 or 0)

	-- Bottom death
	if self.pos.y > 256 then
		self:kill()
	end

	-- Smoke particles
	if on_ground and not self.was_on_ground then
		Smoke(self.x, self.y + 4)
	end

	-- Jump
	local jump = btn(k_jump) and not self.p_jump
	self.p_jump = btn(k_jump)
	if jump then
		self.jbuffer = 4
	elseif self.jbuffer > 0 then
		self.jbuffer -= 1
	end

	-- Dash
	local dash = btn(k_dash) and not self.p_dash
	self.p_dash = btn(k_dash)

	-- Grace
	if on_ground then
		self.grace = 6
		if self.djump < max_djump then
			psfx(54)
			self.djump = max_djump
		end
	elseif self.grace > 0 then
		self.grace -= 1
	end

	self.dash_effect_time -= 1
	-- Player just dashed
	if self.dash_time > 0 then
		Smoke(self.x, self.y)
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
				Smoke(self.x + input * 6, self.y)
			end
		end

		if not on_ground then
			self.spd.y = appr(self.spd.y, maxfall, gravity)
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
				Smoke(self.x, self.y + 4)
			else
				-- Wall jump
				local wall_dir = (self:is_solid(-3, 0) and -1 or self:is_solid(3, 0) and 1 or 0)
				if wall_dir ~= 0 then
					psfx(2)
					self.jbuffer = 0
					self.spd.y = -2
					self.spd.x = -wall_dir * (maxrun + 1)
					if not self:is_ice(wall_dir * 3, 0) then
						Smoke(self.x + wall_dir * 6, self.y)
					end
				end
			end
		end

		-- Dash
		local d_full = 5
		local d_half = d_full * sqrt_one_half
		
		if self.djump > 0 and dash then
			Smoke(self.x, self.y)
			self.djump -= 1
			self.dash_time = 4
			has_dashed = true
			self.dash_effect_time = 10
			local v_input = (btn(k_up) and -1 or (btn(k_down) and 1 or 0))
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
			freeze = 2
			shake = 6
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
			Smoke(self.x, self.y)
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
	elseif btn(k_down) then
		-- Crouching down
		self.spr = 6
	elseif btn(k_up) then
		-- Looking up
		self.spr = 7
	elseif (self.spd.x == 0) or (not btn(k_left) and not btn(k_right)) then
		-- Stale
		self.spr = 1
	else
		-- Running left or right
		self.spr = 1 + self.spr_off % 4
	end

	-- TODO: Next level
	-- if self.pos.y <- 4 and level_index < 30 then
	-- 	self.pos.y = 0
	-- 	self.pos.x = 0
	-- 		next_room()
	-- end

	-- Was on the ground
	self.was_on_ground = on_ground

end

function Player:_move(ox, oy)

	-- [x] get move amount
	if ox ~= 0 then
		self.rem.x += ox
		local amount = math.floor(self.rem.x + 0.5)
		self.rem.x -= amount
		self:_move_x(amount, 0)
	end

	-- [y] get move amount
	if oy ~= 0 then
		self.rem.y += oy
		local amount = math.floor(self.rem.y + 0.5)
		self.rem.y -= amount
		self:_move_y(amount)
	end

end

function Player:_move_x(amount, start)


	if self.solids then
		local step = 0
		if amount > 0 then
			step = 1
		elseif amount < 0 then
			step = -1
		end

		local count = amount
		if count < 0 then
			count = count * -1
		end

		for i=start, count do
			if not self:is_solid(step, 0) then
				self.pos.x += step
			else
				self.spd.x = 0
				self.rem.x = 0
				break
			end
		end
	else
		self.x += amount
	end

end

function Player:_move_y(amount, start)

	local step <const> = sign(amount)
	local count <const> = math.abs(amount)
	for i=0, count do
		if not self:is_solid(0, step) then
			self.pos.y += step
		else
			self.spd.y = 0
			self.rem.y = 0
			break
		end
	end

end

function Player:is_solid(ox, oy)

	-- local rect = self:getCollideRect():offsetBy(self.x + ox, self.y + oy)
	-- local spritesInRect = playdate.graphics.sprite.querySpritesInRect(rect)
	-- if #spritesInRect > 0 then
	-- 	for _, s in ipairs(spritesInRect) do
	-- 		if s ~= self and s.is_solid then
	-- 			return true
	-- 		end
	-- 	end
	-- end
	-- return false

	-- TODO: special case for levels with platform
	-- if (#objects[platform.type_id] > 0) and (oy>0) then
	-- 	local collide_at_ox_0 = false
	-- 	local collide_at_ox_oy = false
	-- 	-- equivalent to obj.collide(platform,ox,oy) ~= nil
	-- 	local r <const> = playdate.geometry.rect.new(obj.x+obj.hitbox.x+ox+kDrawOffsetX, obj.y+obj.hitbox.y+oy+kDrawOffsetY, obj.hitbox.w, obj.hitbox.h)
	-- 	local sprites_in_rect = GFX.sprite.querySpritesInRect(r)
	-- 	for i=1, #sprites_in_rect do
	-- 		local s = sprites_in_rect[i]
	-- 		if s.type == "platform" then
	-- 			collide_at_ox_oy = true
	-- 		end
	-- 	end
	-- 	-- equivalent to obj.collide(platform,ox,0) ~= nil
	-- 	sprites_in_rect = GFX.sprite.querySpritesInRect(r:offsetBy(0, oy * -1))
	-- 	for i=1, #sprites_in_rect do
	-- 		local s = sprites_in_rect[i]
	-- 			if s.type == "platform" then
	-- 			collide_at_ox_0 = true
	-- 		end
	-- 	end
	-- 	if not collide_at_ox_0 and collide_at_ox_oy then
	-- 		return true
	-- 	end
	-- end
	local r <const> = playdate.geometry.rect.new(self.pos.x + self.hitbox.x + ox, self.pos.y + self.hitbox.y + oy, self.hitbox.width, self.hitbox.height)
	local sprites_in_rect <const> = gfx.sprite.querySpritesInRect(r)
	for i=1, #sprites_in_rect do
		local s = sprites_in_rect[i]
		if s.is_solid == true then
			return true
		end
	end
	return false

end

function Player:is_ice(ox, oy)

	return false

end

function Player:_draw()

	if self.pos.x < -1 or self.pos.x > 193 then 
		self.pos.x = clamp(self.pos.x, -1, 193)
		self.spd.x = 0
	end

	local img <const> = image_table:getImage(math.floor(self.spr))
	-- TODO: has_orb_effect
	self:setImage(img, flip(self.flip.x, self.flip.y))
	self:moveTo(self.pos.x - 1, self.pos.y - 1)
	-- TODO: draw_hair()

end

-- update
--
function Player:update()

	Player.super.update(self)
	if self.spd.x ~= 0 or self.spd.y ~= 0 then
		self:_move(self.spd.x, self.spd.y)
	end
	self:_update()
	self:_draw()

end

-- kill
--
function Player:kill()

	-- TODO: kill_player(obj)
	self:remove()

end
