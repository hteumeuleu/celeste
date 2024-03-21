local pd <const> = playdate
local gfx <const> = pd.graphics
local img <const> = gfx.image.new("Assets/chest")
local rnd <const> = pico8.rnd
local sfx <const> = pico8.sfx

class('Chest').extends(ParentObject)

function Chest:init(x, y, parent)

	Chest.super.init(self, x, y, parent)

	self.type_id = 11
	self.pos.x -= 5
	self.start = self.pos.x
	self.timer = 20

	self:setCollideRect(self.hitbox:offsetBy(1,1))
	self:setCollidesWithGroups({1})
	self:setImage(img)
	self:setZIndex(20)
	self:add()

end

function Chest:_update()

	if self.parent.has_key then
		self.timer -= 1
		self.pos.x = self.start - 1 + rnd(3)
		if self.timer <= 0 then
			pico8.celeste.sfx_timer = 20
			sfx(16)
			Fruit(self.pos.x, self.pos.y - 4, self.parent)
			self:destroy()
		end
	end

end

function Chest:_draw()

	self:moveTo(self.pos.x, self.pos.y)

end

