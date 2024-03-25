import "Scripts/Libraries/pico8"
import "Scripts/Libraries/pico8.celeste.lua"
import "Scripts/Objects/Object"
import "Scripts/Objects/Room"
import "Scripts/Objects/Player"
import "Scripts/Objects/PlayerSpawn"
import "Scripts/Objects/FakeWall"
import "Scripts/Objects/Cloud"
import "Scripts/Objects/Particle"
import "Scripts/Objects/Smoke"
import "Scripts/Objects/Fruit"
import "Scripts/Objects/FlyFruit"
import "Scripts/Objects/Hair"
import "Scripts/Objects/LifeUp"
import "Scripts/Objects/RoomTitle"
import "Scripts/Objects/RoomTitleTime"
import "Scripts/Objects/RoomTitleTAS"
import "Scripts/Objects/Spring"
import "Scripts/Objects/Tree"
import "Scripts/Objects/FallFloor"
import "Scripts/Objects/Chest"
import "Scripts/Objects/Key"
import "Scripts/Objects/Balloon"
import "Scripts/Objects/Platform"
import "Scripts/Objects/Message"
import "Scripts/Objects/BigChest"
import "Scripts/Objects/Orb"
import "Scripts/Objects/Flag"
import "Scripts/Objects/FlagScore"
import "Scripts/Objects/FlagRestartButton"
import "Scripts/TAS"

local pd <const> = playdate
local gfx <const> = pd.graphics
local camera <const> = pico8.camera
local rectfill <const> = pico8.rectfill
local music <const> = pico8.music
local sfx <const> = pico8.sfx
local _print <const> = pico8.print
local k_jump <const> = pd.kButtonA
local k_dash <const> = pd.kButtonB

class("Game").extends(gfx.sprite)

function Game:init()

	Game.super.init(self)
	-- self:initOptions()
	self:titleScreen()
	-- self:load()
	-- self:addMenuItems()
	return self

end

function Game:_init(index)
	self.freeze = 0
	self.shake = 0
	self.will_restart = false
	self.delay_restart = 0
	self.level_index = index or 0
	self.level_total = 31
	self.seconds = 0
	self.minutes = 0
	self.frames = 0
	self.deaths = 0
	self.music_timer = 0
	pico8.celeste.sfx_timer = 0
	self.max_djump = 1
	self.got_fruit = {}
    for i = 0, 29 do
    	table.insert(self.got_fruit, false)
    end
	self.room = Room(self.level_index, self)
end

function Game:getTime()

	local s = self.seconds
	local m = self.minutes % 60
	local h = math.floor(self.minutes / 60)
	return (h<10 and "0"..h or h)..":"..(m<10 and "0"..m or m)..":"..(s<10 and "0"..s or s)

end

function Game:getDeaths()

	return self.deaths

end

function Game:getScore()

	local score = 0
	for i = 1, #self.got_fruit do
		if self.got_fruit[i] then
			score += 1
		end
	end
	return score

end

function Game:update()

	self:_update()
	self:_draw()

end

function Game:_update()

	pico8.frames += 1
	self.frames = ((self.frames + 1) % 30)

	-- Timers
	if self.frames == 0 and self.level_index < 30 then
		self.seconds = ((self.seconds + 1) % 60)
		if self.seconds == 0 then
			self.minutes += 1
		end
	end

	if self.music_timer > 0 then
		self.music_timer -= 1
		if self.music_timer <= 0 then
			music(10,0,7)
		end
	end

	if pico8.celeste.sfx_timer > 0 then
		pico8.celeste.sfx_timer -= 1
	end

	-- Cancel if freeze
	if self.freeze > 0 then
		self.freeze -= 1
		return
	end

	-- Screenshake
	if self.shake > 0 then
		self.shake -= 1
		camera()
		if self.shake > 0 then
			camera(-2 + (math.random() * 5), -2 + (math.random() * 5))
		end
	end

	-- Restart (soon)
	if self.will_restart and self.delay_restart > 0 then
		self.delay_restart -= 1
		if self.delay_restart <= 0 then
			self.will_restart = false
			self.room:load()
		end
	end

	-- Update each object
	if self.room.obj and #self.room.obj > 0 then
		for i=1, #self.room.obj do
			for j=1, #self.room.obj[i] do
				local obj = self.room.obj[i][j]
				if obj then
					if obj.spd.x ~= 0 or obj.spd.y ~= 0 then
						obj:move(obj.spd.x, obj.spd.y)
					end
					if obj._update ~= nil then
						obj:_update()
					end
				end
			end
		end
	end

	-- Start game
	if self.room.is_title then
		if not self.start_game and (pico8.btn(k_jump) or pico8.btn(k_dash)) then
			music(-1)
			self.start_game_flash = 50
			self.start_game = true
			sfx(38)
		end
		if self.start_game then
			self.start_game_flash -= 1
			if self.start_game_flash <= -30 then
				self:begin()
			end
		end
	end

end

function Game:begin()
	self.frames = 0
	self.seconds = 0
	self.minutes = 0
	self.music_timer = 0
	self.start_game = false
	music(0,0,7)
	self.level_index = 0
	self.room = Room(self.level_index, self)
end

function Game:_draw()

	if self.freeze > 0 then
		return
	end

	-- Draw objects
	if self.room.obj and #self.room.obj > 0 then
		for i=1, #self.room.obj do
			for j=1, #self.room.obj[i] do
				local obj = self.room.obj[i][j]
				if obj and obj._draw ~= nil then
					obj:_draw()
				end
			end
		end
	end

	-- Black bars on final level
	if self.level_index == (self.level_total - 1) then

		if self.extraLayer == nil then
			self.extraLayer = gfx.sprite.new(gfx.image.new(200, 128, gfx.kColorClear))
			self.extraLayer:setCenter(0, 0)
			self.extraLayer:moveTo(0, 0)
			self.extraLayer:setZIndex(40)
			self.extraLayer:setIgnoresDrawOffset(true)
			self.extraLayer:add()
		end
		local img <const> = self.extraLayer:getImage()
		img:clear(gfx.kColorClear)
		gfx.pushContext(img)
			local player = self.room.player
			local diff = -16
			if player ~= nil then
            	diff = math.min(24, 40 - math.abs(player.pos.x + 4 - 100))
			end
			diff += 34
			rectfill(0, 0, diff, 128)
			rectfill(200 - diff, 0, 200, 128)
		gfx.popContext()

	end

end

function Game:nextRoom()

	self.level_index += 1
	if self.level_index > self.level_total then
		self.level_index = 0
	end
	self.room = Room(self.level_index, self)

end

function Game:titleScreen()

	self:_init(31)
	music(40, 0, 7)
	if self.extraLayer == nil then
		self.extraLayer = gfx.sprite.new(gfx.image.new(200, 128, gfx.kColorClear))
		self.extraLayer:setCenter(0, 0)
		self.extraLayer:moveTo(0, 0)
		self.extraLayer:setZIndex(40)
		self.extraLayer:setIgnoresDrawOffset(true)
		self.extraLayer:add()
	end
	local image <const> = self.extraLayer:getImage()
	image:clear(gfx.kColorClear)
	gfx.pushContext(image)
		_print("a+b",58+36,80-4,5)
		_print("maddy thorson",40+36,96-4,5)
		_print("noel berry",46+36,102-4,5)
	gfx.popContext()

end

function Game:restart()

	-- self:initOptions()
	self:_init(31)

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

function Game:addMenuItems()

	local menu = playdate.getSystemMenu()
	menu:addMenuItem("Assist Mode", function()
		self:toggleOptions()
	end)
	menu:addMenuItem("Reset", function()
		self:restart()
	end)

end

function Game:usedAssistMode()

	return false -- self.options:usedAnOption()

end

-- serialize()
--
function Game:serialize()

	local status = {}
	status.fruits = self.got_fruit
	status.room = pd.geometry.point.new(self.level_index%8, self.level_index/8)
	status.deaths = self.deaths
	status.seconds = self.seconds
	status.minutes = self.minutes
	status.assist = self:usedAssistMode()
	status.fullscreen = true
	return status

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
	if pd.isSimulator then
		prettyPrint = true
	end
	if (self.level_index >= self.level_total) then
		pd.datastore.delete("game")
	else
		pd.datastore.write(self:serialize(), "game", prettyPrint)
	end

end

-- load()
--
function Game:load()

	-- local save = playdate.datastore.read("game")
	-- if save then
	-- 	if save.assist == true then
	-- 		self.options.usedAssistMode = true
	-- 	end
	-- 	_load(save)
	-- else
	-- 	self.options.usedAssistMode = false
	-- end

end

-- saveScore()
--
function Game:saveScore()

	-- local serialized = self:serialize()
	-- -- Create new entry
	-- local save = {}
	-- save.fruits = 0
	-- for i=1, #serialized.fruits do
	-- 	if serialized.fruits[i] == true then
	-- 		save.fruits += 1
	-- 	end
	-- end
	-- save.deaths = serialized.deaths
	-- save.minutes = serialized.minutes
	-- save.seconds = serialized.seconds
	-- save.assist = serialized.assist
	-- save.date = playdate.epochFromTime(playdate.getTime())
	-- -- Load previous scores
	-- local scores = playdate.datastore.read("scores")
	-- if scores then
	-- 	table.insert(scores, save)
	-- else
	-- 	scores = {save}
	-- end
	-- playdate.datastore.write(scores, "scores")

end

function Game:getTime(marg, sarg)

	seconds=sarg or self.seconds
	minutes=marg or self.minutes
	local s=seconds
	local m=minutes%60
	local h=math.floor(minutes/60)
	return (h<10 and "0"..h or h)..":"..(m<10 and "0"..m or m)..":"..(s<10 and "0"..s or s)

end

-- updatePauseScreen()
--
function Game:updatePauseScreen()

	local image <const> = gfx.image.new(400, 240)
	local offset = 72
	local status = self:serialize()
	local is_start_screen = (self.level_index == self.level_total)
	local scores = pd.datastore.read("scores")
	local has_scores = (scores ~= nil)
	gfx.pushContext(image)
		-- Draw dark overlay
		local overlay <const> = gfx.image.new(400, 240, gfx.kColorBlack)
		overlay:drawFaded(0, 0, 0.5, gfx.image.kDitherTypeBayer2x2)
		if (not is_start_screen and not (self.level_index == self.level_total - 1)) or (is_start_screen and has_scores) then
			local boxImage <const> = gfx.image.new(64, 50)
			gfx.pushContext(boxImage)
				-- Draw box
				local box = pd.geometry.rect.new(0, 0, 64, 42)
				gfx.setColor(gfx.kColorWhite)
				gfx.fillRect(box)
				local inside = pd.geometry.rect.new(box.x + 1, box.y + 13, box.width - 2, box.height - 14)
				gfx.setColor(gfx.kColorBlack)
				gfx.fillRect(inside)
				-- Draw room title
				local fontHeight <const> = gfx.getFont():getHeight()
				local room_title = self.room.title
				if (is_start_screen and has_scores) then
					room_title = "Best Score"
				end
				gfx.drawTextInRect(room_title, 1, 4, 62, fontHeight, nil, nil, kTextAlignment.center)
				-- Draw fruit and score
				local fruit = gfx.imagetable.new("Assets/fruit"):getImage(1)
				fruit:draw(23, 15)
				local score = 0
				local time = self:getTime(status.minutes, status.seconds)
				local deaths = status.deaths
				local assist = status.assist
				for i=1,#status.fruits do
					if status.fruits[i] then
						score+=1
					end
				end
				if (is_start_screen and has_scores) then
	-- 				local best = scores[1]
	-- 				if #scores > 1 then
	-- 					for i=2, #scores do
	-- 						local current = scores[i]
	-- 						if tonumber(current.minutes) < tonumber(best.minutes) or (best.assist == true and current.assist == false) then
	-- 							best = current
	-- 						elseif tonumber(current.minutes) == tonumber(best.minutes) then
	-- 							if tonumber(current.seconds) < tonumber(best.seconds) then 
	-- 								best = current
	-- 							elseif tonumber(current.seconds) == tonumber(best.seconds) then 
	-- 								if tonumber(current.deaths) < tonumber(best.deaths) then
	-- 									best = current
	-- 								elseif tonumber(current.deaths) == tonumber(best.deaths) then
	-- 						   			if tonumber(current.fruits) > tonumber(best.fruits) then
	-- 										best = current
	-- 									end
	-- 								end
	-- 							end
	-- 						end
	-- 					end
	-- 				end
	-- 				score = best.fruits
	-- 				deaths = best.deaths
	-- 				assist = best.assist
	-- 				time = get_time(tonumber(best.minutes), tonumber(best.seconds))
				end
				gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
					gfx.drawText("x" .. score, 33, 19)
					gfx.drawTextInRect(time, 2, 27, 60, fontHeight, nil, nil, kTextAlignment.center)
					gfx.drawTextInRect("deaths:"..deaths, 2, 34, 60, fontHeight, nil, nil, kTextAlignment.center)
				gfx.setImageDrawMode(gfx.kDrawModeCopy)
				if assist then
					local assistBox = playdate.geometry.rect.new(0, 42, 64, 6)
					gfx.setColor(gfx.kColorWhite)
					gfx.fillRect(assistBox)
					gfx.drawTextInRect("+assist mode", 8, 42, 49, fontHeight, nil, nil, kTextAlignment.center)
				end
			gfx.popContext()
			if (is_start_screen and has_scores) then
				offset = 100
			end
			boxImage:drawScaled(offset + (200-128)/2, (240-90)/2, 2)
		else
			offset = 100
		end
	gfx.popContext()
	pd.setMenuImage(image, offset)

end
