local pd <const> = playdate
local gfx <const> = pd.graphics
local sin <const> = pico8.sin

class('Particle').extends(gfx.sprite)

function Particle:init()

	Particle.super.init(self)
	local x <const> = math.random() * 200
	local y <const> = math.random() * 120
	self.size = 1 + math.floor((math.random() * 5) / 4)
	self.speed = 0.25 + (math.random() * 5)
	self.offset = math.random() * 1
	self.inc = math.min(0.05, self.speed / 32)
	local img <const> = gfx.image.new(self.size, self.size, gfx.kColorWhite)
	self:setImage(img)
	self:moveTo(x, y)
	self:setCenter(0, 0)
	self:setZIndex(30)
	self:add()
	return self

end

function Particle:update()

	Particle.super.update(self)
	local x = self.x + self.speed
	local y = self.y + sin(self.offset)
	self.offset += self.inc
	if self.x > (200 + 4) then
		x = -4
		y = math.random() * 200
	end
	self:moveTo(x, y)

end

