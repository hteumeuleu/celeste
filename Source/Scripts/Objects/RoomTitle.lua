local pd <const> = playdate
local gfx <const> = pd.graphics
local img <const> = gfx.image.new(80, 12)

class('RoomTitle').extends(ParentObject)

function RoomTitle:init(title, parent)

	RoomTitle.super.init(self, 60, 58, parent)

	self.type_id = 19
	self.delay = 5
	self.title = title or ""

	gfx.pushContext(img)
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, 80, 12)
		gfx.drawTextInRect(self.title, 0, 4, 80, 5, _, _, kTextAlignment.center)
	gfx.popContext()
	self:clearCollideRect()
	self:setImage(img)
	self:setZIndex(20)
	self:add()

	if not parent.tas then
		if self.parent.parent.level_index ~= (self.parent.parent.level_total - 1) then
			self.roomTitleTime = RoomTitleTime(self.parent)
		end
	else
		RoomTitleTAS(self.parent)
	end

	return self

end

function RoomTitle:_draw()

	self.delay -= 1
	if self.delay < -30 then
		self:destroy()
	end

end

function RoomTitle:destroy()

	RoomTitle.super.destroy(self)
	if self.roomTitleTime then
		self.roomTitleTime:destroy()
	end
	-- if layers.assist and game_obj then
	-- 	layers.assist:remove()
	-- end

end
