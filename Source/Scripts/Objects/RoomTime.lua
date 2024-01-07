local pd <const> = playdate
local gfx <const> = pd.graphics
local img <const> = gfx.image.new(33, 7)

class('RoomTime').extends(ParentObject)

function RoomTime:init(time)

	RoomTime.super.init(self, 40, 8)

	gfx.pushContext(img)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(0, 0, 33, 7)
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		gfx.drawText(time, 1, 1)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	gfx.popContext()
	self:clearCollideRect()
	self:setImage(img)
	self:setZIndex(40)
	self:add()
	
	return self

end
