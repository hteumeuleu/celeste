local pd <const> = playdate
local gfx <const> = pd.graphics
local offset <const> = pd.geometry.point.new(-8, -8)
local imageTable <const> = gfx.imagetable.new("Assets/player")
local k_left <const> = pd.kButtonLeft
local k_right <const> = pd.kButtonRight
local k_up <const> = pd.kButtonUp
local k_down <const> = pd.kButtonDown
local k_jump <const> = pd.kButtonA
local k_dash <const> = pd.kButtonB
local btn = function(i) return pd.buttonIsPressed(i) end
local max_djump = 1

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
	self.hitbox = pd.geometry.rect.new(2,6,12,10)
	self.spd = pd.geometry.vector2D.new(0, 0)
	self.rem = pd.geometry.vector2D.new(0, 0)
	self.pos = pd.geometry.point.new(x, y)
	self.solids = true
	self:setCenter(0, 0)
	self:setZIndex(20)
	self:setCollideRect(self.hitbox:offsetBy(2,2))
	self:setCollidesWithGroups({2,3,4,5,6})
	self:setZIndex(20)
	self:setGroups({1})
	self:moveTo(x-2, y-2)
	self:add()
	return self

end

function Player:_update()

	if (self.pause_player) then return end

	local input = btn(k_right) and 1 or (btn(k_left) and -1 or 0)

	-- Spikes collide
	-- TODO

	-- Bottom death
	if self.pos.y > 256 then
		self:kill()
	end

	local on_ground = true -- TODO
	local on_ice = false -- TODO

	-- Smoke particles
	if on_ground and not self.was_on_ground then
		-- TODO
	end

	-- Jump
	local jump = btn(k_jump) and not self.p_jump
	self.p_jump = btn(k_jump)
	if (jump) then
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
	if self.dash_time > 0 then
		-- init_object(smoke,self.pos.x,self.pos.y) -- TODO
		self.dash_time -= 1
		self.spd.x = appr(self.spd.x, self.dash_target.x, self.dash_accel.x)
		self.spd.y = appr(self.spd.y, self.dash_target.y, self.dash_accel.y)
	else
		-- move
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
			self.spd.x = appr(self.spd.x, sign(self.spd.x)*maxrun, deccel)
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

	end

	-- Animation
	self.spr_off+=0.25
	if not on_ground then
		-- if self:is_solid(input, 0) then
		-- 	self.spr = 5
		-- else
		-- 	self.spr = 3
		-- end
	elseif btn(k_down) then
		-- Crouching down
		self.spr=6
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

	-- Next level
	-- TODO

	-- Was on the ground
	self.was_on_ground = on_ground

end

function Player:_move(ox, oy)

	local amount
	-- [x] get move amount
	self.rem.x += ox
	amount = math.floor(self.rem.x + 0.5)
	self.rem.x -= amount
	self:_move_x(amount, 0)

	-- [y] get move amount
	self.rem.y += oy
	amount = math.floor(self.rem.y + 0.5)
	self.rem.y -= amount
	self:_move_y(amount)

end

function Player:_move_x(amount, start)

	if self.solids then
		local step = sign(amount)
		for i=start, math.abs(amount) do
			if not self:is_solid(step, 0) then
				self.pos.x += step
			else
				self.spd.x = 0
				self.rem.x = 0
				break
			end
		end
	else
		self.pos.x += amount
	end

end

function Player:_move_y(amount, start)

	if self.solids then
		local step = sign(amount)
		for i=0, math.abs(amount) do
			if not self:is_solid(0, step) then
				self.pos.y += step
			else
				self.spd.y = 0
				self.rem.y = 0
				break
			end
		end
	else
		self.pos.y += amount
	end

end

function Player:is_solid(ox, oy)

	local rect = self:getCollideRect():offsetBy(self.pos.x+ox, self.pos.y+oy)
	local spritesInRect = playdate.graphics.sprite.querySpritesInRect(rect)
	if #spritesInRect > 0 then
		for _, s in ipairs(spritesInRect) do
			if s ~= self and s.is_solid then
				return true
			end
		end
	end
	return false

end

function Player:_draw()

	local img <const> = imageTable:getImage(math.floor(self.spr))
	self:setImage(img, flip(self.flip.x, self.flip.y))
	self:moveTo(self.pos.x-2, self.pos.y-2)

end

-- update
--
function Player:update()

	Player.super.update(self)
	self:_move(self.spd.x, self.spd.y)
	self:_update()
	self:_draw()

end

-- kill
--
function Player:kill()

	-- TODO
	self:remove()

end