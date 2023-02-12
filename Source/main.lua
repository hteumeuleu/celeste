import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/crank"

import "Scripts/Game"
local g = Game()

-- playdate.update()
--
function playdate.update()

	playdate.timer.updateTimers()
	playdate.graphics.sprite.update()
	g:update()
	-- playdate.drawFPS(0, 0)

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

-- playdate.gameWillPause()
--
function playdate.gameWillPause()

	g:updatePauseScreen()

end

-- playdate.keyPressed()
--
function playdate.keyPressed(key)

	if key == "m" then
		g:toggleOptions()
	end

end