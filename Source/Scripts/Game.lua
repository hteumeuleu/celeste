import "Scripts/data.lua"
import "Scripts/globals.lua"
import "Scripts/pico-8.lua"
import "Scripts/celeste.lua"
import "Scripts/Options"

class("Game").extends()

function Game:init()

	Game.super.init(self)
	self:addMenuItems()
	self._init = _init
	self._update = _update
	self._draw = _draw
	self.options = Options()
	self:_init()
	return self

end

function Game:update()

	if not self.isPaused then
		self:_update()
		self:_draw()
	end

end

function Game:restart()

	self:_init()

end

function Game:pause()

	self.isPaused = true

end

function Game:unpause()

	self.isPaused = false

end

function Game:toggleOptions()

	if self.options:isVisible() then
		self.options:hide()
		self:unpause()
	else
		self:pause()
		local img = playdate.graphics.getDisplayImage()
		self.options:setBackground(img)
		self.options:show()
	end

end

function Game:addMenuItems()

	local menu = playdate.getSystemMenu()
	menu:addMenuItem("Restart", function()
		self:restart()
	end)
	menu:addMenuItem("Options", function()
		self:toggleOptions()
	end)
	menu:addCheckmarkMenuItem("Assist", false, function(value)
		if value then
			max_djump=999
		end
	end)

end