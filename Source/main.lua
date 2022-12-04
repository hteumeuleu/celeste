import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/crank"

import "Scripts/Game"
import "Scripts/Object"
import "Scripts/Player"
import "Scripts/data.lua"
import "Scripts/pico-8.lua"
import "Scripts/celeste.lua"

-- _init()

g_game = Game()

function playdate.update()

	playdate.timer.updateTimers()
	playdate.graphics.sprite.update()
	g_game:update()
	g_game:draw()
	-- _update()
	-- _draw()
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