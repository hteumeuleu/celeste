local pd <const> = playdate
local gfx <const> = pd.graphics
local font <const> = gfx.getFont()
printTable(font)
local _print <const> = pico8.print

class('Text').extends(ParentObject)

function Text:init(x, y, innerText)

	Text.super.init(self, x, y)

	local w <const> = font:getTextWidth(innerText)
	local h <const> = font:getHeight()
	local img <const> = gfx.image.new(w, h)
	gfx.pushContext(img)
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		font:drawText(innerText, 0, 0)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	gfx.popContext()
	self:setImage(img)

	self:clearCollideRect()
	self:setZIndex(20)
	self:moveTo(self.pos.x, self.pos.y)
	self:add()

end
