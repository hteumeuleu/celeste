local gfx <const> = playdate.graphics
local pattern = gfx.image.new(200, 120, gfx.kColorWhite)
pattern = pattern:fadedImage(0.4, gfx.image.kDitherTypeHorizontalLine):scaledImage(2)

class('Cloud').extends(gfx.sprite)

function Cloud:init()

	Cloud.super.init(self)
	local x <const> = math.floor(math.random()*200)*2
	local y <const> = math.floor(math.random()*120)*2
	local w <const> = math.floor(32+math.random()*32)
	local h <const> = math.floor(4+(1-w/64)*12)
	self.offset = y % 8
	self.speed = (1+math.random()*4)*2
	local img <const> = gfx.image.new(w*2, h*2, gfx.kColorClear)
	gfx.pushContext(img)
		pattern:draw(x * -1, y * -1)
	gfx.popContext()
	self:setImage(img)
	self:moveTo(x, y)
	self:setCenter(0,0)
	self:setZIndex(-1)
	self:add()
	return self

end

function Cloud:update()

	Cloud.super.update(self)
	if self.x > 400 then
		local x = -self.width
		local y = math.floor(math.random()*120)*2
		y += (self.offset - y % 8)
		self:moveTo(x, y)
	else
		self:moveBy(self.speed, 0)
	end

end
