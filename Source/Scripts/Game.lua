import "Scripts/data.lua"
import "Scripts/globals.lua"
import "Scripts/pico-8.lua"
import "Scripts/celeste.lua"
import "Scripts/Options"

class("Game").extends()

local GFX = playdate.graphics
local data = g_data

function Game:init()

	Game.super.init(self)
	self._init = _init
	self._update = _update
	self._draw = _draw
	self:initOptions()
	self:_init(self)
	self:load()
	self:addMenuItems()
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

	self._scaleValue = n
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
	if data.frame ~= nil and n == 1 then
		data.frame:moveTo(kDisplayOffsetX, kDisplayOffsetY)
		data.frame:add()
	elseif data.frame ~= nil then
		data.frame:remove()
	end
	for i, layer in ipairs(layers) do
		if layers[layer] ~= nil then
			layers[layer]:moveTo(kDisplayOffsetX, kDisplayOffsetY)
		end
	end

end

-- isFullScreen()
--
function Game:isFullScreen()

	return (self._scaleValue == 2)

end

function Game:addMenuItems()

	local menu = playdate.getSystemMenu()
	menu:addCheckmarkMenuItem("Fullscreen", self:isFullScreen(), function(value)
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

function Game:usedAssistMode()

	return self.options:usedAnOption()

end

-- serialize()
--
function Game:serialize()

	return serialize() -- see celeste.lua

end

-- hasSave()
--
function Game:hasSave()

	return playdate.datastore.read("game") ~= nil

end

-- save()
--
function Game:save()

	local prettyPrint = false
	if playdate.isSimulator then
		prettyPrint = true
	end
	playdate.datastore.write(self:serialize(), "game", prettyPrint)

end

-- load()
--
function Game:load()

	local save = playdate.datastore.read("game")
	if save then
		if save.assist == true then 
			self.options.usedAssistMode = true
		end
		if save.fullscreen == true then 
			self:scale(2)
		else
			self:scale(1)
		end
		_load(save)
	else
		self.options.usedAssistMode = false
		self:scale(2)
	end

end

-- updatePauseScreen()
--
function Game:updatePauseScreen()

	local image <const> = GFX.image.new(400, 240)
	local offset = 72
	local status = self:serialize()
	printTable(status)
	GFX.pushContext(image)
		-- Draw dark overlay
		local overlay <const> = GFX.image.new(400, 240, GFX.kColorBlack)
		overlay:drawFaded(0, 0, 0.5, GFX.image.kDitherTypeBayer2x2)
		if not (status.room.x == 7 and status.room.y == 3) then
			local boxImage <const> = GFX.image.new(64, 50)
			GFX.pushContext(boxImage)
				-- Draw box
				local box = playdate.geometry.rect.new(0, 0, 64, 42)
				GFX.setColor(GFX.kColorWhite)
				GFX.fillRect(box)
				local inside = playdate.geometry.rect.new(box.x + 1, box.y + 13, box.width - 2, box.height - 14)
				GFX.setColor(GFX.kColorBlack)
				GFX.fillRect(inside)
				-- Draw room title
				local fontHeight <const> = data.font:getHeight()
				GFX.drawTextInRect(get_room_title(), 1, 4, 62, fontHeight, nil, nil, kTextAlignment.center)
				-- Draw fruit and score
				local fruit = data.imagetables.fruit:getImage(1)
				fruit:draw(23, 15)
				local score = 0
				for i=1,#status.fruits do
					if status.fruits[i] then
						score+=1
					end
				end
				GFX.setImageDrawMode(GFX.kDrawModeFillWhite)
					GFX.drawText("x" .. score, 33, 19)
					GFX.drawTextInRect(get_time(), 2, 27, 60, fontHeight, nil, nil, kTextAlignment.center)
					GFX.drawTextInRect("deaths:"..status.deaths, 2, 34, 60, fontHeight, nil, nil, kTextAlignment.center)
				GFX.setImageDrawMode(GFX.kDrawModeCopy)
				if status.assist then
					local assistBox = playdate.geometry.rect.new(0, 42, 64, 6)
					GFX.setColor(GFX.kColorWhite)
					GFX.fillRect(assistBox)
					GFX.drawTextInRect("+assist mode", 8, 42, 49, fontHeight, nil, nil, kTextAlignment.center)
				end
			GFX.popContext()
			boxImage:drawScaled(offset + (200-128)/2, (240-90)/2, 2)
		else
			offset = 100
		end
	GFX.popContext()
	playdate.setMenuImage(image, offset)

end
