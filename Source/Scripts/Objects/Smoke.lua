local pd <const> = playdate
local gfx <const> = pd.graphics
local image_table <const> = gfx.imagetable.new("Levels/1bit-classic")
local flip <const> = pico8.flip
local maybe <const> = pico8.celeste.maybe

class('Smoke').extends(ParentObject)

function Smoke:init(x, y, parent)

	Smoke.super.init(self, x, y, parent)
	self.pos:offset(-1 + math.random() * 2, -1 + math.random() * 2)
	self.type_id = 5
	self.spr = 29
	self.spd.y = -0.1
	self.spd.x = 0.3 + math.random() * 0.2
	self.solids = false
	self.flip.x = maybe()
	self.flip.y = maybe()
	self:clearCollideRect()
	self:moveTo(self.pos.x, self.pos.y)
	self:setZIndex(30)
	self:add()

end

function Smoke:_update()

	self.spr += 0.2
	if self.spr >= 32 then
		self:destroy()
		gfx.sprite.addDirtyRect(self.x, self.y, self.width, self.height)
	end

end

function Smoke:_draw()

	local img <const> = image_table:getImage(math.floor(self.spr) + 1)
	self:setImage(img, flip(self.flip.x, self.flip.y))

end

