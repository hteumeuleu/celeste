class("Options").extends(playdate.graphics.sprite)

function Options:init()

	Options.super.init(self)
	self:setSize(80, 48)
	self:moveTo(100,60)
	self:setZIndex(99)
	self:setVisible(false)
	self:initItems()
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

-- initItems()
--
function Options:initItems()

	self.items = {}
	for i=1, 5 do
		local item = {}
		item.name = "Foo" .. i
		item.callback = function()
			print(item.name, i)
		end
		table.insert(self.items, item)
	end

end

-- initImage()
--
function Options:initImage()

	self.img = playdate.graphics.image.new(self.width, self.height, playdate.graphics.kColorClear)
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
		self.gridview:setContentInset(2, 2, 0, 0)
		self.gridview:setHorizontalDividerHeight(4)
		self.gridview:addHorizontalDividerAbove(1, 1)
		self.gridview:addHorizontalDividerAbove(1, #self.items+1)

		-- Background image
		local bg = playdate.graphics.image.new(self.width, self.height, playdate.graphics.kColorBlack)
		playdate.graphics.pushContext(bg)
			playdate.graphics.setColor(playdate.graphics.kColorWhite)
			playdate.graphics.setStrokeLocation(playdate.graphics.kStrokeInside)
			playdate.graphics.drawRect(1, 1, self.width-2, self.height-2)
		playdate.graphics.popContext()
		self.gridview.backgroundImage = bg

		local that = self
		local selectedOffset <const> = 2

		function self.gridview:drawHorizontalDivider(section, x, y, width, height)
		end

		function self.gridview:drawCell(section, row, column, selected, x, y, width, height)

			playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)

			local offset = 10
			if selected then
				offset += selectedOffset
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

	self.gridview:drawInRect(0, 0, self.width, self.height)

end

-- show()
--
function Options:show()

	if self.bg ~= nil then
		self.bg:add()
	end
	self:add()
	self:setVisible(true)

end

-- hide()
--
function Options:hide()

	if self.bg ~= nil then
		self.bg:remove()
	end
	self:remove()
	self:setVisible(false)

end

-- setBackground()
--
function Options:setBackground(img)

	if not self:isVisible() then
		self.bg = playdate.graphics.sprite.new(img)
		self.bg:moveTo(200,120)
		self.bg:setZIndex(98)
		self.bg:add()
	end

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
		self.items[self.gridview:getSelectedRow()].callback()
	end

end