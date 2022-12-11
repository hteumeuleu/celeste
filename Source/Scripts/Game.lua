import "data.lua"
import "globals.lua"
import "pico-8.lua"
import "celeste.lua"

class("Game").extends()

function Game:init()

    Game.super.init(self)
    self:addMenuItems()
    _init()
    return self

end

function Game:update()

    _update()
    _draw()

end

function Game:restart()

    _init()

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