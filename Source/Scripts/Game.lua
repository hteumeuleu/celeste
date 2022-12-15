import "Scripts/data.lua"
import "Scripts/globals.lua"
import "Scripts/pico-8.lua"
import "Scripts/celeste.lua"

class("Game").extends()

function Game:init()

    Game.super.init(self)
    self:addMenuItems()
    self._init = _init
    self._update = _update
    self._draw = _draw
    self:_init()
    return self

end

function Game:update()

    self:_update()
    self:_draw()

end

function Game:restart()

    self:_init()

end

function Game:addMenuItems()

    local menu = playdate.getSystemMenu()
    menu:addMenuItem("Restart", function()
        self:restart()
    end)
    menu:addCheckmarkMenuItem("Assist", false, function(value)
        if value then
            max_djump=999
        end
    end)

end