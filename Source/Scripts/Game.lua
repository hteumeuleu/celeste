import "Scripts/data.lua"
import "Scripts/globals.lua"
import "Scripts/pico-8.lua"
import "Scripts/celeste.lua"
import "Scripts/Options"

class("Game").extends()

function Game:init()

	Game.super.init(self)
	self._init = _init
	self._update = _update
	self._draw = _draw
	self:scale(2)
	self:addMenuItems()
	self:initOptions()
	self:_init(self)
	return self

end

function Game:update()

	if not self.isPaused then
		self:_update()
		self:_draw()
	end

end

function Game:restart()

	self:_init(self)

end

function Game:pause()

	self.isPaused = true

end

function Game:unpause()

	self.isPaused = false

end

function Game:initOptions()

	self.options = Options()

	local myInputHandlers = {
		AButtonUp = function()
			self.options:doSelectionCallback()
		end,
		BButtonUp = function()
			self:toggleOptions()
		end,
		upButtonDown = function()
			self.options:up()
		end,
		downButtonDown = function()
			self.options:down()
		end,
	}

	self.options:setHideCallback(function()
		self:unpause()
		playdate.inputHandlers.pop()
	end)
	self.options:setShowCallback(function()
		self:pause()
		playdate.inputHandlers.push(myInputHandlers, true)
	end)

end

function Game:toggleOptions()

	if self.options:isVisible() then
		self.options:hide()
	else
		self.options:show()
	end

end



-- scale()
--
function Game:scale(n)

	playdate.display.setScale(n)
	local kDisplayOffsetX = playdate.display.getWidth() / 2
	local kDisplayOffsetY = playdate.display.getHeight() / 2
	kDrawOffsetX = (playdate.display.getWidth() - 128) / 2
	kDrawOffsetY = (playdate.display.getHeight() - 128) / 2

	if data.cache ~= nil then
		data.cache:moveTo(kDisplayOffsetX, kDisplayOffsetY)
	end
	if self.options ~= nil then
		self.options:moveTo(kDisplayOffsetX, kDisplayOffsetY)
	end
	for i, layer in ipairs(layers) do
		if layers[layer] ~= nil and type(layers[layer]) == "table" then
			layers[layer]:moveTo(kDisplayOffsetX, kDisplayOffsetY)
		end
	end

end

function Game:addMenuItems()

	local menu = playdate.getSystemMenu()
	menu:addCheckmarkMenuItem("Fullscreen", true, function(value)
		if value then
			self:scale(2)
		else
			self:scale(1)
		end
	end)
	menu:addMenuItem("Assist Mode", function()
		self:toggleOptions()
	end)
	menu:addMenuItem("Reset", function()
		self:restart()
	end)

end