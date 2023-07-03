local pd <const> = playdate
local gfx <const> = pd.graphics
local offset <const> = pd.geometry.point.new(-8, -8)
local imageTable <const> = gfx.imagetable.new("Assets/player")

class('Player').extends(gfx.sprite)

-- Player
--
function Player:init(x, y)

	Player.super.init(self)
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

	local input = pd.buttonIsPressed(pd.kButtonRight) and 1 or (pd.buttonIsPressed(pd.kButtonLeft) and -1 or 0)

	-- Facing
	if self.spd.x ~= 0 then
		self.flip.x = (self.spd.x < 0)
	end

	-- Sprite image and animation
	self.spr_off += 0.25
	if pd.buttonIsPressed(pd.kButtonDown) then
		-- Looking up
		self.spr = 6
	elseif pd.buttonIsPressed(pd.kButtonUp) then
		-- Crouching down
		self.spr = 7
	elseif (self.spd.x==0) or (not pd.buttonIsPressed(pd.kButtonLeft) and not pd.buttonIsPressed(pd.kButtonRight)) then
		-- Stale
		self.spr=1
	else
		-- Going left or right
		print("left or right")
		self.spr = 1 + self.spr_off % 4
	end

end

function Player:_move(ox, oy)

	local amount
	-- [x] get move amount
	self.rem.x += ox
	amount = math.floor(self.rem.x + 0.5)
	self.rem.x -= amount
	self:_move_x(amount,0)

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
	return false
    -- if oy>0 and not obj.check(platform,ox,0) and obj.check(platform,ox,oy) then
    --     return true
    -- end
    -- return solid_at(obj.x+obj.hitbox.x+ox,obj.y+obj.hitbox.y+oy,obj.hitbox.w,obj.hitbox.h)
    --  or obj.check(fall_floor,ox,oy)
    --  or obj.check(fake_wall,ox,oy)
end
   

function Player:_draw()

	local img <const> = imageTable:getImage(math.floor(self.spr))
	self:setImage(img, flip(self.flip.x, self.flip.y))

end

-- update
--
function Player:update()

	Player.super.update(self)
	self:_move(self.spd.x, self.spd.y)
	self:_update()
	self:_draw()

end