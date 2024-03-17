local pd <const> = playdate
local gfx <const> = pd.graphics

class('FlagScore').extends(ParentObject)

function FlagScore:init(x, y, parent)

	FlagScore.super.init(self, x, y, parent)
	self:clearCollideRect()
	self:setZIndex(19)

	-- TODO
	local time = self.parent.parent:getTime()
	local deaths = self.parent.parent:getDeaths()
	local score = self.parent.parent:getScore()
	local usedAssistMode = self.parent.parent:usedAssistMode()

	local img <const> = gfx.image.new(64, 40)
	gfx.pushContext(img)
		local rectHeight = 31
		if usedAssistMode then
			rectHeight = 36
		end
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(0, 0, 64, rectHeight)
		gfx.setColor(gfx.kColorWhite)
		gfx.drawRect(0, 0, 64, rectHeight)
		if usedAssistMode then
			gfx.fillRect(0, 29, 64, 6)
		end
		local fruit_image_table <const> = gfx.imagetable.new("Assets/fruit")
		local fruit <const> = fruit_image_table:getImage(1)
		fruit:draw(22, 3)
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
			gfx.drawText("x"..score, 32, 7)
			gfx.drawTextInRect(time, 2, 15, 60, 20, nil, nil, kTextAlignment.center)
			gfx.drawTextInRect("deaths:"..deaths, 2, 22, 60, 20, nil, nil, kTextAlignment.center)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
		if usedAssistMode then
			gfx.drawTextInRect("+assist mode", 2, 30, 60, 20, nil, nil, kTextAlignment.center)
		end
	gfx.popContext()
	self:setImage(img)

	self:add()

end
