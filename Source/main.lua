import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/crank"

import "Scripts/pico-8.lua"
import "Scripts/celeste.lua"

math.randomseed(playdate.getSecondsSinceEpoch())
playdate.display.setScale(2)

-- playdate.graphics.sprite.setBackgroundDrawingCallback(
-- 	function(x, y, width, height)
-- 		_draw()
-- 	end
-- )

_init()

function playdate.update()

	playdate.timer.updateTimers()
	-- playdate.graphics.sprite.update()
	_update()
    -- playdate.graphics.clear(playdate.graphics.kColorBlack)
	_draw()
	playdate.drawFPS(0, 0)

end