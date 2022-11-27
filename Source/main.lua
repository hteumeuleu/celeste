import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/crank"

import "Scripts/Game"
local g = Game()

--
-- Hair mask test (working!)
--
-- local player = playdate.graphics.sprite.new(data.imagetables.player:getImage(3))
-- player:moveTo(100, 60)
-- player:add()
-- local mask = playdate.graphics.image.new(32, 32, playdate.graphics.kColorClear)
-- playdate.graphics.pushContext(mask)
-- 	local sprite_img_mask = data.imagetables.player:getImage(10)
-- 	playdate.graphics.setColor(playdate.graphics.kColorWhite)
-- 	-- playdate.graphics.fillRect(0, 0, 7, 8)
-- 	sprite_img_mask:draw(7,0)
-- playdate.graphics.popContext()
-- local hair_img = playdate.graphics.image.new(32, 32, playdate.graphics.kColorClear)
-- playdate.graphics.pushContext(hair_img)
-- 	playdate.graphics.setStencilImage(mask)
-- 	-- Outline
-- 	playdate.graphics.setColor(playdate.graphics.kColorWhite)
-- 	playdate.graphics.setLineWidth(1)
-- 	playdate.graphics.setStrokeLocation(playdate.graphics.kStrokeOutside)
-- 	playdate.graphics.drawCircleAtPoint(3, 4, 2)
-- 	playdate.graphics.drawCircleAtPoint(8, 4, 3)
-- 	-- Fill
-- 	playdate.graphics.setColor(playdate.graphics.kColorBlack)
-- 	playdate.graphics.fillCircleAtPoint(3, 4, 2)
-- 	playdate.graphics.fillCircleAtPoint(8, 4, 3)
-- 	playdate.graphics.clearStencil()
-- playdate.graphics.popContext()
-- local sample = playdate.graphics.sprite.new(hair_img)
-- sample:moveTo(100, 40)
-- sample:add()
-- local hair = playdate.graphics.sprite.new(hair_img)
-- hair:moveTo(104, 71)
-- hair:setZIndex(2)
-- hair:add()

function playdate.update()

	playdate.timer.updateTimers()
	playdate.graphics.sprite.update()
	g:update()
	playdate.drawFPS(0, 0)

end

-- playdate.gameWillTerminate()
--
function playdate.gameWillTerminate()

	g:save()

end

-- playdate.deviceWillSleep()
--
function playdate.deviceWillSleep()

	g:save()

end

function playdate.keyPressed(key)

	if key == "m" then
		g:toggleOptions()
	end

end