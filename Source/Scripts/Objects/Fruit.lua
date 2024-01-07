local pd <const> = playdate
local gfx <const> = pd.graphics
local imageTable <const> = gfx.imagetable.new("Assets/fruit")
local img <const> = imageTable:getImage(1)

class('Fruit').extends(ParentObject)

function Fruit:init(x, y)

	Fruit.super.init(self, x, y)
	self.start = y
	self.off = 0
	self:setImage(img)
	self:setGroups({4})
	self:setCollideRect(self.hitbox:offsetBy(1,1))
	self:setCollidesWithGroups({1})
	self:moveTo(x - 1, y)
	self:setZIndex(20)
	self:add()
	return self

end

function Fruit:update()

	Fruit.super.update(self)
	self.off += 1
	self:moveTo(self.x, self.start + sin(self.off/40) * 2.5)
	local _, _, collisions, length = self:checkCollisions(0, 0)
	if length == 1 then
		local player = collisions[1].other
		self:hit(player)
	end

end

function Fruit:hit(player)

	if player ~= nil then
		player.djump = player.max_djump
		sfx_timer = 20
		sfx(13)
		-- got_fruit[1+level_index] = true
		LifeUp(self.x, self.y)
		self:destroy()
	end

end
