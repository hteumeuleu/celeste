local pd <const> = playdate
local gfx <const> = pd.graphics
local img <const> = gfx.image.new(13, 7)

class('RoomTitleTAS').extends(ParentObject)

function RoomTitleTAS:init(parent)

	RoomTitleTAS.super.init(self, 40, 8, parent)

	self.type_id = 19
	self:clearCollideRect()
	self:setZIndex(40)
	self:add()
	
	return self

end

function RoomTitleTAS:_draw()

	local time = 0
	if self.parent.player ~= nil then
		time = pico8.celeste.clamp(pico8.frames, 0, 999)
	end
	gfx.pushContext(img)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(0, 0, 13, 7)
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
		gfx.drawText(time, 1, 1)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	gfx.popContext()
	self:setImage(img)

end
