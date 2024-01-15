local pd <const> = playdate
local gfx <const> = pd.graphics
local img <const> = gfx.image.new("Assets/life-up")

class('LifeUp').extends(ParentObject)

function LifeUp:init(x, y, parent)

	LifeUp.super.init(self, x, y, parent)

	self.type_id = 8
	self.spd.y = -0.25
	self.duration = 30
	self.x -= 2
	self.y -= 4
	self.flash = 0
	self.solids = false

	self:setImage(img)
	self:setZIndex(30)
	self:add()
	return self

end

function LifeUp:_update()

	self.duration -= 1
	if self.duration <= 0 then
		self:destroy()
	end

end

function LifeUp:_draw()

	self.flash += 0.5
	if math.floor(self.flash) % 2 == 0 then
		self:setImageDrawMode(gfx.kDrawModeInverted)
	else
		self:setImageDrawMode(gfx.kDrawModeCopy)
	end
	self:moveTo(self.pos.x, self.pos.y)

end
