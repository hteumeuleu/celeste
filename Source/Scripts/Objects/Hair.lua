local pd <const> = playdate
local gfx <const> = pd.graphics
local image_table <const> = gfx.imagetable.new("Assets/player-mask")
local min <const> = math.min
local max <const> = math.max
local flip <const> = pico8.flip
local clamp <const> = pico8.celeste.clamp
local k_down <const> = pd.kButtonDown
local i = 0

class('Hair').extends(gfx.sprite)

-- Hair
--
function Hair:init(player)

	Hair.super.init(self, player.pos.x, player.pos.y)

	self.hair = {}
	for i=0, 4 do
		table.insert(self.hair, { x = player.pos.x, y = player.pos.y, size = max(1, min(2,3 - i)) })
	end

	self:setCenter(0, 0)
	self:setZIndex(21)
	self:add()

end

-- Draw()
--
function Hair:_draw(player, facing)

	local lastX = player.pos.x + 4 - facing*2
	local lastY = player.pos.y + (pico8.btn(k_down) and 4 or 3)
	local coords = {}
	for i=1, #self.hair do
		local h = self.hair[i]
		local x = h.x
		local y = h.y
		x += (lastX - x) / 1.5
		y += (lastY + 0.5 - y) / 1.5
		table.insert(coords, { x = x, y = y, s = h.size })
		h.x = x
		h.y = y
		lastX = x
		lastY = y
	end
	-- First, calculate new coords
	local x1 = 128
	local x2 = 0
	local y1 = 128
	local y2 = 0
	for i=1, #coords do
		local c = coords[i]
		local s = c.s

		local newX1 = c.x - s
		if newX1 < x1 then
			x1 = newX1
		end

		local newX2 = c.x + s
		if newX2 > x2 then
			x2 = newX2
		end

		local newY1 = c.y - s
		if newY1 < y1 then
			y1 = newY1
		end

		local newY2 = c.y + s
		if newY2 > y2 then
			y2 = newY2
		end
	end
	x1 = clamp(x1, 0, 128) - 1
	x2 = clamp(x2, 0, 128) + 1
	y1 = clamp(y1, 0, 128) - 1
	y2 = clamp(y2, 0, 128) + 1
	local w <const> = x2 - x1
	local h <const> = y2 - y1

	-- Adjust hair sprite to new coordinates and size
	self:setSize(w, h)
	self:moveTo(x1, y1)

	-- Difference between hair sprite and player sprite
	local diff = {}
	diff.x = math.floor(player.pos.x - x1)
	diff.y = math.floor(player.pos.y - y1)
	local mask_x = diff.x
	if facing == -1 then
		mask_x -= 1
	end
	local mask_y = diff.y
	local mask_w = max(32, w)
	local mask_h = max(32, h)

	-- Create mask image for hair
	-- (will be used as a stencil so needs to be at least 32x32)
	local pdmask = gfx.image.new(mask_w, mask_h, gfx.kColorClear)
	gfx.pushContext(pdmask)
		-- Fill the image with white except where the mask will be
		gfx.setColor(gfx.kColorWhite)
		gfx.fillRect(0, 0, mask_w, mask_h)
		local pdmask_spr_index = math.floor(player.spr)
		local pdmask_img = image_table:getImage(pdmask_spr_index)
		pdmask_img:draw(mask_x, mask_y, flip(facing, false))
	gfx.popContext()

	-- Create new image for drawing hair
	local pdimg = gfx.image.new(math.max(32,w), math.max(32,h), gfx.kColorClear)
	gfx.pushContext(pdimg)
		-- Add mask
		gfx.setStencilImage(pdmask)
		-- Draw white outline of hair
		gfx.setColor(gfx.kColorWhite)
		gfx.setLineWidth(1)
		gfx.setStrokeLocation(gfx.kStrokeOutside)
		for i=1, #coords do
			local c = coords[i]
			gfx.drawCircleAtPoint(c.x - x1, c.y - y1, c.s)
		end
		-- Draw black fill of hair
		gfx.setColor(gfx.kColorBlack)
		for i=1, #coords do
			local c = coords[i]
			gfx.fillCircleAtPoint(c.x - x1, c.y - y1, c.s)
		end
		-- Clear mask's stencil
		gfx.clearStencil()
	gfx.popContext()

	if player.djump then
		local has_orb_effect = (player.djump >= 2 and math.floor((player.parent.parent.frames/3)%2) == 0)
		-- if reduce_flashing then
		-- 	has_orb_effect = false
		-- end
		if player.djump == 0 or has_orb_effect then
			local newimg = pdimg:copy()
			newimg:clear(gfx.kColorClear)
			gfx.pushContext(newimg)
				gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
				pdimg:draw(0,0)
				gfx.setImageDrawMode(gfx.kDrawModeCopy)
			gfx.popContext()
			pdimg = newimg
		end
	end

	self:setImage(pdimg)

end
