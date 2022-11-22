import "map.lua"

math.randomseed(playdate.getSecondsSinceEpoch())

local sprites <const> = playdate.graphics.imagetable.new("Assets/sprites")
local spritesFlags <const> = {
	0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0,
	0x4, 0x2, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x2, 0x0, 0x0, 0x0, 0x0,
	0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x4, 0x4, 0x4, 0x2, 0x2, 0x0, 0x0, 0x0,
	0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x3, 0x4, 0x4, 0x4, 0x2, 0x2, 0x2, 0x2, 0x2,
	0x0, 0x0, 0x13, 0x13, 0x13, 0x13, 0x2, 0x2, 0x3, 0x2, 0x2, 0x2, 0x2, 0x2, 0x2, 0x2,
	0x0, 0x0, 0x13, 0x13, 0x13, 0x13, 0x2, 0x2, 0x4, 0x2, 0x2, 0x2, 0x2, 0x2, 0x2, 0x2,
	0x0, 0x0, 0x13, 0x13, 0x13, 0x13, 0x0, 0x4, 0x4, 0x2, 0x2, 0x2, 0x2, 0x2, 0x2, 0x2,
	0x0, 0x0, 0x13, 0x13, 0x13, 0x13, 0x0, 0x0, 0x0, 0x2, 0x2, 0x2, 0x2, 0x2, 0x2, 0x2
}

local font <const> = playdate.graphics.font.new("Assets/pico")
playdate.graphics.setFont(font)


function add(t, value, index)

	index = index or #t+1
	table.insert(t, index, value)

end

function del(t, value)

	for i=1, #t do
		if t[i] == value then
			table.remove(t, i)
			break
		end
	end

end

function flr(num)

	return math.floor(num)

end

function abs(num)

	return math.abs(num)

end

function rnd(arg)

	arg = arg or 1.0
	if type(arg) == "table" then
		return arg[math.random(1, #arg)]
	else
		return math.random() * arg
	end

end

function sin(angle)

	return math.sin(math.rad(angle * -1 * 360.0))

end

function cos(angle)

	return math.cos(math.rad(angle * -1 * 360.0))

end

function min(first, second)

	second = second or 0
	return math.min(first, second)

end

function max(first, second)

	second = second or 0
	return math.max(first, second)

end

function rectfill(x0, y0, x1, y1, col)

	if col == nil then
		playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)
	end
	playdate.graphics.fillRect(x0, y0, x1-x0, y1-y0)

end

function circfill(x, y, r, col)

	r = r or 4
	if col == nil then
		playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)
	end
	playdate.graphics.fillCircleAtPoint(x, y, r)

end

function foreach(tbl, func)

	for _, item in ipairs(tbl) do
		func(item)
	end

end

function btn(i, p)

	if i == nil then
		return
	end
	p = p or 0
	return playdate.buttonIsPressed(i)

end

-- spr(n, [x,] [y,] [w,] [h,] [flip_x,] [flip_y])
function spr(n, x, y, w, h, flip_x, flip_y)

	if n > #sprites or n < 0 then return end
	n = flr(n) + 1 or 1
	x = x or 0
	y = y or 0
	w = w or 1.0
	h = h or 1.0
	flip_x = flip_x or false
	flip_y = flip_y or false
	local img = sprites:getImage(n)
	local flip =  playdate.graphics.kImageUnflipped
	if flip_x and flip_y then
		 flip = playdate.graphics.kImageFlippedXY
	elseif flip_x then
		 flip = playdate.graphics.kImageFlippedX
	elseif flip_y then
		 flip = playdate.graphics.kImageFlippedY
	end
	img:draw(x, y, flip)

end

function mget(celx, cely)

	local i = (celx % 128) + (cely * 128) + 1
	return mapData[i]

end


function fget(n, f)

	if f ~= nil then
		return spritesFlags[n+1] == f
	else
		return spritesFlags[n+1]
	end

end

function map(celx, cely, sx, sy, celw, celh, layer)

    for cx=0,celw-1 do
        for cy=0,celh-1 do
        	local i = mget(celx + cx, cely + cy) + 1
			local img = sprites:getImage(i)
			local x = sx + (cx * 8)
			local y = sy + (cy * 8)
			if layer ~= nil and fget(i) == layer then
				img:draw(x, y)
			else
				img:draw(x, y)
			end
        end
    end

end

function pal(c0, c1, p)

	-- TODO

end

function music()

    -- TODO

end

function sfx()

    -- TODO

end

function camera(x, y)

	x = x or 0
	y = y or 0
    playdate.display.setOffset(x, y)

end

function count(tbl)

	return #tbl

end

function _print(text, x, y, color)

	x = x or 0
	y = y or 0
	if col == nil then
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
	end
	playdate.graphics.drawText(text, x, y)
	if col == nil then
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
	end

end