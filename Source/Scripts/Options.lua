class("Options").extends(playdate.graphics.sprite)

function Options:init()

	Options.super.init(self)
	self.usedAssistMode = false
	self:initItems()
	self:setSize(80, 50)
	self:moveTo(100,60)
	self:setZIndex(99)
	self:hide()
	self:initGridView()
	self:initImage()
	return self

end

-- update()
--
function Options:update()

	Options.super.update(self)
	if self.gridview and self.gridview.needsdisplay then
		self:forceUpdate()
	end

end

-- forceUpdate()
--
function Options:forceUpdate()

	if self.gridview then
		playdate.graphics.pushContext(self.img)
			playdate.graphics.setClipRect(0, 0, self.width, self.height)
				self:drawGrid()
			playdate.graphics.clearClipRect()
		playdate.graphics.popContext()
		self:setImage(self.img)
	end

end

function Options:usedAnOption()

	return (self.usedAssistMode == true)

end

-- initItems()
--
function Options:initItems()

	self.items = {}
	local saved = self:load() or {}

	-- Skip level
	local item = {}
	item.name = "Skip level"
	item.value = saved.skip or 0
	item.callback = function(item)
		self.usedAssistMode = true
		if get_level_index() == 30 then
			item.value = 0
			title_screen()
		elseif get_level_index() == 31 then
			item.value = 0
			begin_game()
		else
			item.value += 1
			next_room()
		end
		self:hide()
	end
	table.insert(self.items, item)
	self.items.skip = item
	-- Game Speed
	item = {}
	item.name = "Game Speed"
	item.value = tonumber(saved.speed) or 30
	if item.value == 15 then
		item.name = "Game Speed:0.5"
		playdate.display.setRefreshRate(item.value)
	end
	item.callback = function(item)
		self.usedAssistMode = true
		if item.value == 30 then
			item.value = 15
			item.name = "Game Speed:0.5"
		else
			item.value = 30
			item.name = "Game Speed"
		end
		self:forceUpdate()
		playdate.display.setRefreshRate(item.value)
	end
	table.insert(self.items, item)
	self.items.speed = item
	-- Air Dashes
	item = {}
	item.name = "Dashes"
	item.value = (saved.dashes == true)
	if item.value then
		max_djump = 9999
		item.value = true
		item.name = "Dashes:Infinite"
	end
	item.callback = function(item)
		self.usedAssistMode = true
		if item.value then
			max_djump = 1
			item.value = false
			item.name = "Dashes"
		else
			max_djump = 9999
			item.value = true
			item.name = "Dashes:Infinite"
		end
		self:forceUpdate()
	end
	table.insert(self.items, item)
	self.items.dashes = item
	-- Invincibility
	item = {}
	item.name = "Invincibility"
	item.value = (saved.invicibility == true)
	if item.value then
		item.name = "Invincibility:on"
	end
	item.callback = function(item)
		self.usedAssistMode = true
		if item.value then
			item.value = false
			item.name = "Invincibility"
		else
			item.value = true
			item.name = "Invincibility:on"
		end
		self:forceUpdate()
	end
	table.insert(self.items, item)
	self.items.invicibility = item
	-- Back
	item = {}
	item.name = "Back"
	item.callback = function(item)
		self:hide()
	end
	table.insert(self.items, item)

end

function Options:get(name)

	if self.items ~= nil and self.items[name] ~= nil and self.items[name].value ~= nil then
		return self.items[name].value
	end
	return nil

end

function Options:set(name, value)

	if self.items[name] ~= nil then
		self.items[name].value = value
		return true
	end
	return false

end

-- initImage()
--
function Options:initImage()

	self.img = playdate.graphics.image.new(self.width, self.height, playdate.graphics.kColorClear)
	self.bg = self:getBackgroundImage()
	playdate.graphics.pushContext(self.img)
		if self.gridview then
			self:drawGrid()
		end
	playdate.graphics.popContext()
	self:setImage(self.img)

end

-- initGridView()
--
function Options:initGridView()

	if not self.gridview and #self.items > 0 then
		self.gridview = playdate.ui.gridview.new(0, 8)
		self.gridview:setNumberOfSections(1)
		self.gridview:setNumberOfColumns(1)
		self.gridview:setNumberOfRows(#self.items)
		self.gridview:setCellPadding(0, 0, 0, 0)
		self.gridview:setContentInset(0, 0, 0, 0)
		self.gridview:setHorizontalDividerHeight(3)
		self.gridview:addHorizontalDividerAbove(1, 1)
		self.gridview:addHorizontalDividerAbove(1, #self.items+1)

		local that = self

		function self.gridview:drawHorizontalDivider(section, x, y, width, height)
		end

		function self.gridview:drawCell(section, row, column, selected, x, y, width, height)

			playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)

			local offset = 9
			if selected then
				offset += 1
				-- Draw arrow
				data.imagetables.arrow:draw(x+3, y+1)
			end

			-- Draw text
			if that.items[row] ~= nil then
				local fontHeight = data.font:getHeight()
				playdate.graphics.drawTextInRect(that.items[row].name, x+offset, y+((height-fontHeight)/2), width-offset, fontHeight, nil, "…")
			end

			playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)

		end
	end
end

-- drawGrid()
--
function Options:drawGrid()

	playdate.graphics.clear(playdate.graphics.kColorClear)
	self.bg:draw(0,0)
	self.gridview:drawInRect(2, 2, self.width-4, self.height-4)

end

-- getBackgroundImage()
--
function Options:getBackgroundImage()

	local bg = playdate.graphics.image.new(self.width, self.height, playdate.graphics.kColorBlack)
	playdate.graphics.pushContext(bg)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.setStrokeLocation(playdate.graphics.kStrokeInside)
		playdate.graphics.drawRect(1, 1, self.width-2, self.height-2)
	playdate.graphics.popContext()
	return bg

end

-- show()
--
function Options:show()

	self:add()
	self:setVisible(true)
	if self.showCallback ~= nil then
		self:showCallback()
	end


end

-- hide()
--
function Options:hide()

	self:save()
	self:remove()
	self:setVisible(false)
	if self.hideCallback ~= nil then
		self:hideCallback()
	end

end

function Options:setShowCallback(f)

	self.showCallback = f

end

function Options:setHideCallback(f)

	self.hideCallback = f

end

-- up()
--
-- Moves the selection up one item in the list.
function Options:up()

	if #self.items > 0 then
		self.gridview:selectPreviousRow(true)
		self:setSelection(self.gridview:getSelectedRow())
		self:forceUpdate()
	end

end

-- down()
--
-- Moves the selection down one item in the list.
function Options:down()

	if #self.items > 0 then
		self.gridview:selectNextRow(true)
		self:setSelection(self.gridview:getSelectedRow())
		self:forceUpdate()
	end

end

-- setSelection(index)
--
-- Set the `index` value as the selected item inside the grid view
-- and scrolls the grid view to show it.
function Options:setSelection(index)

	if index >= 1 and index <= #self.items then
		self.gridview:setSelection(1, index, 1)
		self.gridview:scrollToCell(1, index, 1, false)
	end

end

-- doSelectionCallback()
--
-- Calls the currently selected row callback function.
function Options:doSelectionCallback()

	if #self.items > 0 then
		local item = self.items[self.gridview:getSelectedRow()]
		item.callback(item)
	end

end

-- serialize()
--
function Options:serialize()

	local data = {}
	data.used = self.usedAssistMode
	data.skip = self:get("skip")
	data.speed = self:get("speed")
	data.dashes = self:get("dashes")
	data.invicibility = self:get("invicibility")
	return data

end

-- hasSave()
--
function Options:hasSave()

	return playdate.datastore.read("options") ~= nil

end

-- save()
--
function Options:save()

	local prettyPrint = false
	if playdate.isSimulator then
		prettyPrint = true
	end
	playdate.datastore.write(self:serialize(), "options", prettyPrint)

end

-- load()
--
function Options:load()

	local save = playdate.datastore.read("options")
	if save and (save.used == "true") then
		self.usedAssistMode = save.used
	end
	return save

end