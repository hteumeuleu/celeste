local pd <const> = playdate
local gfx <const> = pd.graphics
local image_table <const> = gfx.imagetable.new("Levels/1bit-classic")

class('Smoke').extends(gfx.sprite)

function Smoke:init(arg_x, arg_y)

	Smoke.super.init(self)
	local x <const> = arg_x + -1 + math.random() * 2
	local y <const> = arg_y + -1 + math.random() * 2
	self.spr = 29
	self.spd = pd.geometry.vector2D.new(0, 0)
	self.spd.y = -0.1
	self.spd.x = 0.3 + math.random() * 0.2
	self.solids = false
	self.flip = {}
	self.flip.x = maybe()
	self.flip.y = maybe()
	local img <const> = image_table:getImage(self.spr)
	self:setImage(img)
	self:setCenter(0, 0)
	self:moveTo(x, y)
	self:setZIndex(0)
	self:add()
	return self

end

function Smoke:update()

	Smoke.super.update(self)
	self.spr += 0.2
	if self.spr >= 32 then
		self:remove()
		gfx.sprite.addDirtyRect(self.x, self.y, self.width, self.height)
	else
		local img <const> = image_table:getImage(math.floor(self.spr) + 1)
		self:setImage(img, flip(self.flip.x, self.flip.y))
	end

end

