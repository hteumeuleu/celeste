local pd <const> = playdate
local gfx <const> = pd.graphics
local image_table <const> = gfx.imagetable.new("Assets/fruit")
local img <const> = image_table:getImage(1)
local sin <const> = pico8.sin
local psfx <const> = pico8.celeste.psfx

class('Fruit').extends(ParentObject)

function Fruit:init(x, y, parent)

	Fruit.super.init(self, x, y, parent)
	self.type_id = 6
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

function Fruit:_update()

	if self:collide("Player", 0, 0) then
		self:hit(self.parent.player)
	end
	self.off += 1
	self.pos.y = self.start + sin(self.off/40) * 2.5

end

function Fruit:_draw()

	self:moveTo(self.pos.x, self.pos.y)

end

function Fruit:hit(player)

	if player ~= nil then
		player.djump = self.parent.parent.max_djump
		pico8.celeste.sfx_timer = 20
		sfx(13)
		self.parent:addFruit()
		LifeUp(self.x, self.y, self.parent)
		self:destroy()
	end

end
