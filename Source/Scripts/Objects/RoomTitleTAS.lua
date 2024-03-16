local pd <const> = playdate
local gfx <const> = pd.graphics
local img <const> = gfx.image.new(32, 11)

class('RoomTitleTAS').extends(ParentObject)

function RoomTitleTAS:init(parent)

	RoomTitleTAS.super.init(self, 8, 8, parent)

	self.type_id = 19
	self:clearCollideRect()
	self:setZIndex(40)
	self:add()
	
	return self

end

function RoomTitleTAS:_draw()

	-- Draw frames
	local frames = 0
	if self.parent.player ~= nil then
		frames = pico8.celeste.clamp(pico8.frames, 0, 999)
	end
	gfx.pushContext(img)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, 13, 7)
		gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
		gfx.drawText(frames, 1, 1)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	gfx.popContext()

	-- Draw keys
	if self.parent.tas ~= nil then
		gfx.pushContext(img)
			gfx.setColor(gfx.kColorWhite)
			gfx.fillRect(14, 0, 18, 9)
			gfx.setColor(gfx.kColorBlack)
			gfx.fillRect(15, 3, 3, 3) -- left
			gfx.fillRect(17, 1, 3, 4) -- up
			gfx.fillRect(17, 5, 3, 3) -- down
			gfx.fillRect(19, 3, 3, 3) -- right
			gfx.fillRect(24, 3, 3, 3) -- jump
			gfx.fillRect(28, 3, 3, 3) -- dash

			if self.parent.player ~= nil and self.parent.tas.keypresses[pico8.frames] ~= nil then
				gfx.setColor(gfx.kColorWhite)
				if self.parent.tas.keypresses[pico8.frames][0] then
					gfx.drawPixel(16, 4) -- left
				end
				if self.parent.tas.keypresses[pico8.frames][1] then
					gfx.drawPixel(20, 4) -- right
				end
				if self.parent.tas.keypresses[pico8.frames][2] then
					gfx.drawPixel(18, 2) -- up
				end
				if self.parent.tas.keypresses[pico8.frames][3] then
					gfx.drawPixel(18, 6) -- down
				end
				if self.parent.tas.keypresses[pico8.frames][4] then
					gfx.drawPixel(25, 4) -- jump
				end
				if self.parent.tas.keypresses[pico8.frames][5] then
					gfx.drawPixel(29, 4) -- dash
				end
			end
		gfx.popContext()
	end

	self:setImage(img)

end
