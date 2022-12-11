import "data.lua"
import "globals.lua"
import "pico-8.lua"
import "celeste.lua"

class("Game").extends()

function Game:init()

    Game.super.init(self)
    _init()
    return self

end

function Game:update()

    _update()
    _draw()

end