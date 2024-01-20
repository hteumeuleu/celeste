local pd <const> = playdate
local gfx <const> = pd.graphics

pico8 = {}
pico8.frames = 0

pico8.flip = function(flip_x, flip_y)
	local image_flip =  gfx.kImageUnflipped
	if flip_x and flip_y then
		 image_flip = gfx.kImageFlippedXY
	elseif flip_x then
		 image_flip = gfx.kImageFlippedX
	elseif flip_y then
		 image_flip = gfx.kImageFlippedY
	end
	return image_flip
end

pico8.camera = function(x, y)
	x = x or 0
	y = y or 0
	pd.display.setOffset(x, y)
end

pico8.sin = function(angle)
	return math.sin(math.rad(angle * -1 * 360.0))
end

pico8.cos = function(angle)
	return math.cos(math.rad(angle * -1 * 360.0))
end

pico8.del = function(t, value)
	for i=1, #t do
		if t[i] == value then
			table.remove(t, i)
			break
		end
	end
end

pico8.max = function(first, second)
	second = second or 0
	return math.max(first, second)
end

pico8.rnd = function(arg)
	arg = arg or 1.0
	if type(arg) == "table" then
		return arg[math.random(1, #arg)]
	else
		return math.random() * arg
	end
end

pico8.btn = function(i)
	return pd.buttonIsPressed(i)
end

pico8.rectfill = function(x0, y0, x1, y1, col)
	local left <const> = math.min(x0, x1)
	local top <const> = math.min(y0, y1)
	local width <const> = math.max(x0, x1) - left + 1
	local height <const> = math.max(y0, y1) - top + 1
	if col == nil then
		gfx.setColor(gfx.kColorBlack)
	else
		gfx.setColor(gfx.kColorWhite)
	end
	gfx.fillRect(left, top, width, height)
end

pico8.circfill = function(x, y, r, col)
	local r = r or 4
	if col == nil then
		gfx.setColor(gfx.kColorBlack)
	elseif col == 7 then
		gfx.setColor(gfx.kColorWhite)
	end
	gfx.fillCircleAtPoint(x, y, r)
end

pico8.sub = function(str, pos0, pos1)
	pos0 = pos0 or 1
	if pos1 ~= nil and type(pos1) ~= "number" then
		pos1 = pos0 + 1
	else
		pos1 = pos1 or #str
	end
	return string.sub(str, pos0, pos1)
end

pico8._print = function(text, x, y, color)
	x = x or 0
	y = y or 0
	if color == 0 then
		gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
	else
		gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	end
	gfx.drawText(text, x, y)
	gfx.setImageDrawMode(gfx.kDrawModeCopy)
end

local _line_last_x0 = 0
local _line_last_y0 = 0
pico8.line = function(x0, y0, x1, y1, col)
	x1 = x1 or 1
	y1 = y1 or 1
	_line_last_x0 = x0
	_line_last_y0 = y0
	if col == nil then
		gfx.setColor(gfx.kColorBlack)
	elseif col == 7 then
		gfx.setColor(gfx.kColorWhite)
	end
	gfx.drawLine(x0, y0, x1, y1)
end
