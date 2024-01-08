import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/crank"

import "Scripts/data.lua"
import "Scripts/globals.lua"
import "Scripts/Game"

import "Scripts/pico-8.lua" -- useful for celeste.lua, will remove later
import "Scripts/celeste.lua" -- useful for psfx, will remove later
-- import "Scripts/Options"

local CELESTE <const> = Game()
local showFPS = true

playdate.display.setRefreshRate(30)
playdate.display.setScale(2)
playdate.graphics.clear(playdate.graphics.kColorBlack)

-- playdate.update()
--
function playdate.update()

	playdate.timer.updateTimers()
	playdate.graphics.sprite.update()
	CELESTE:update()
	if showFPS then
		playdate.drawFPS(0, 0)
	end

end

function playdate.cranked()

	-- local ticks = playdate.getCrankTicks(1)
	-- if ticks == 1 then
	-- 	showFPS = not showFPS
	-- 	if showFPS then
	-- 		psfx(55)
	-- 	else
	-- 		psfx(5)
	-- 	end
	-- end

end

-- playdate.gameWillTerminate()
--
function playdate.gameWillTerminate()

	-- g:save()

end

-- playdate.deviceWillSleep()
--
function playdate.deviceWillSleep()

	-- g:save()

end

-- playdate.gameWillPause()
--
function playdate.gameWillPause()

	-- g:updatePauseScreen()

end

-- playdate.keyPressed()
--
function playdate.keyPressed(key)

	-- if key == "m" then
	-- 	g:toggleOptions()
	-- end
	if key == "r" then
		CELESTE:nextRoom()
	end

end
