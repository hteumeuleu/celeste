local pd <const> = playdate
local gfx <const> = pd.graphics
local img <const> = gfx.image.new(33, 7)

class('RoomTitleTime').extends(ParentObject)

function RoomTitleTime:init(parent)

	RoomTitleTime.super.init(self, 40, 8, parent)

	self.type_id = 19
	self:clearCollideRect()
	self:setZIndex(40)
	self:add()
	
	return self

end

function RoomTitleTime:_draw()

	local time <const> = self.parent.parent:getTime()

	gfx.pushContext(img)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(0, 0, 33, 7)
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		gfx.drawText(time, 1, 1)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	gfx.popContext()
	self:setImage(img)

end
