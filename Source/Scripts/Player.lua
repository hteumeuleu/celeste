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

-- update
--
function Player:update()

	Player.super.update(self)
	if (self.pause_player) then return end

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
	local img <const> = imageTable:getImage(math.floor(self.spr))
	self:setImage(img, flip(self.flip.x, self.flip.y))

end