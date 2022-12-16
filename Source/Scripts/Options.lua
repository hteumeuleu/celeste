class("Options").extends(playdate.graphics.sprite)

function Options:init()

	Options.super.init(self)
	self:setSize(64, 40)
	self:create()
	self:show()
	return self

end

function Options:create()

	local w = 64
	local h = 40
	local img = playdate.graphics.image.new(w, h, playdate.graphics.kColorBlack)
	playdate.graphics.pushContext(img)
		playdate.graphics.setStrokeLocation(playdate.graphics.kStrokeInside)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.drawRect(0,0,w,h)
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
		playdate.graphics.drawText("Options", 8, 8)
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
	playdate.graphics.popContext()
	self:setImage(img)
	self:setCenter(0.5,0.5)
	self:moveTo(100,60)
	self:setZIndex(99)
	self:setVisible(false)

end

function Options:show()

	if self.bg ~= nil then
		self.bg:add()
	end
	self:add()
	self:setVisible(true)

end

function Options:hide()

	if self.bg ~= nil then
		self.bg:remove()
	end
	self:remove()
	self:setVisible(false)

end

function Options:setBackground(img)

	if not self:isVisible() then
		self.bg = playdate.graphics.sprite.new(img)
		self.bg:moveTo(200,120)
		self.bg:setZIndex(98)
		self.bg:add()
	end

end