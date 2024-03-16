local pd <const> = playdate
local gfx <const> = pd.graphics

class('FlagRestartButton').extends(ParentObject)

function FlagRestartButton:init(x, y, parent)

	FlagRestartButton.super.init(self, x, y, parent)
	self:initImage()
	-- self:setSize(33, 11)
	self:moveTo(200 - self.width, 120 - self.height)
	self:setZIndex(100)
	self:setUpdatesEnabled(false)
	self:clearCollideRect()
	self:add()
	self:addInputHandlers()

end

function FlagRestartButton:addInputHandlers()

	local myInputHandlers = {
		AButtonDown = function()
			print('AButtonDown')
			-- game_just_restarted = false
			-- if self.timer == nil then
			-- 	local self.timerDuration = 2000
			-- 	shake = 30 * (self.timerDuration / 1000)
			-- 	self.timer = playdate.timer.performAfterDelay(self.timerDuration, function()
			-- 		game_just_restarted = true
			-- 		game_obj:restart()
			-- 		self.timer = nil
			-- 		shake = 1
			-- 	end)
			-- 	self.timer.updateCallback = function()
			-- 		layers.restart:setImage(get_restart_button_image())
			-- 	end
			-- end
		end,
		AButtonUp = function()
			print('AButtonUp')
			-- if game_just_restarted then
			-- 	playdate.inputHandlers.pop()
			-- end
			-- if self.timer ~= nil then
			-- 	self.timer:remove()
			-- 	self.timer = nil
			-- 	layers.restart:setImage(get_restart_button_image())
			-- end
			-- shake = 1
			-- game_just_restarted = false
		end,
	}
	playdate.inputHandlers.push(myInputHandlers)

end

function FlagRestartButton:initImage()

	local img <const> = gfx.image.new(33, 11, gfx.kColorClear)
	gfx.pushContext(img)
		local circledText = "a"
		if self.timer ~= nil then
			local steps = 3
			local stepMinThreshold = 300
			local stepDuration = math.floor((self.timer.duration - stepMinThreshold) / steps)
			local currentStep = math.max(1, steps - math.floor((self.timer.currentTime - stepMinThreshold) / stepDuration))
			if self.timer.currentTime > stepMinThreshold then
				circledText = currentStep .. ""
			end
		end
		gfx.setColor(gfx.kColorWhite)
		gfx.fillCircleInRect(1, 1, 9, 9)
		gfx.setColor(gfx.kColorBlack)
		gfx.fillCircleInRect(2, 2, 7, 7)
		gfx.setImageDrawMode(gfx.kDrawModeNXOR)
			gfx.drawText(circledText, 4, 3)
			gfx.drawText("reset", 12, 3)
		gfx.setImageDrawMode(gfx.kDrawModeCopy)
	gfx.popContext()
	self:setImage(img)

end
