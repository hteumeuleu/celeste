import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/crank"

import "Scripts/data.lua"
import "Scripts/pico-8.lua"
import "Scripts/celeste.lua"

_init()

function playdate.update()

	playdate.timer.updateTimers()
	playdate.graphics.sprite.update()
	_update()
	_draw()
	playdate.drawFPS(0, 0)

end