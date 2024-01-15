local pd <const> = playdate
local gfx <const> = pd.graphics
local image_table <const> = gfx.imagetable.new("Assets/fruit")
local img <const> = image_table:getImage(1)
local sin <const> = pico8.sin

class('Fruit').extends(ParentObject)

function Fruit:init(x, y, parent)

	Fruit.super.init(self, x, y, parent)
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

end

function Fruit:hit(player)

	if player ~= nil then
		player.djump = self.parent.parent.max_djump
		sfx_timer = 20
		sfx(13)
		self.parent.got_fruit = true
		LifeUp(self.x, self.y)
		self:destroy()
	end

end
