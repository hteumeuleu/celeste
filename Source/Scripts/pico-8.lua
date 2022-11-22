import "map.lua"

math.randomseed(playdate.getSecondsSinceEpoch())

local sprites <const> = playdate.graphics.imagetable.new("Assets/sprites")
local mask <const> = {
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

local fx <const> = {}
for i=0, 64 do
	local sample = playdate.sound.sample.new("Sounds/sfx" .. i .. ".wav")
	table.insert(fx, sample)
end

local m <const> = {}
m[1] = {21, 10}
m[2] = {10, 22, 12}
m[3] = {10, 22, 12}
m[4] = {10, 11, 12}
m[5] = {20, 19, 18}
m[6] = {10, 22, 12}
m[7] = {10, 22, 12}
m[8] = {10, 17, 18}
m[11] = {24, 25, 26}
m[12] = {24, 25, 26}
m[13] = {28, 27, 26}
m[14] = {29, 27, 26}
m[15] = {31, 33, 26}
m[16] = {31, 26, 33}
m[17] = {30, 26, 34}
m[18] = {32, 26, 36}
m[21] = {30, 26, 34}

local kDisplayOffsetX = 0
local kDisplayOffsetY = 0

function scale(x)

	kDisplayOffsetX = math.max(0, (400 - (128 * x)) / 2)
	kDisplayOffsetY = math.max(0, (240 - (128 * x)) / 2)
	playdate.display.setScale(x)
	playdate.display.setOffset(kDisplayOffsetX, kDisplayOffsetY)

end
scale(2)

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
	n = flr(n) or 1
	x = flr(x) or 0
	y = flr(y) or 0
	w = w or 1.0
	h = h or 1.0
	flip_x = flip_x or false
	flip_y = flip_y or false
	local img = sprites:getImage(n + 1)
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

	local i = celx + (cely * 128)
	return mapData[i + 1]

end

function fget(tile, flag)

	flag = flag or 0x0
	local mask_at = mask[tile+1]
	if flag == mask_at then
		return true
	elseif flag == 1 and (mask_at == 19 or mask_at == 3) then
		return true
	elseif flag == 2 and (mask_at == 19 or mask_at == 3) then
		return true
	elseif flag == 16 and (mask_at == 19) then
		return true
	else
		return false
	end

end

function map(celx, cely, sx, sy, celw, celh, mask)

	mask = mask or 0x0
    for cx=0,celw-1 do
        for cy=0,celh-1 do
        	local tile = mget(celx + cx, cely + cy)
        	if tile < #sprites then
				local img = sprites:getImage(tile + 1)
				local x = sx + (cx * 8)
				local y = sy + (cy * 8)
				if (mask == 0) or (fget(tile, mask)) then
					img:draw(x, y)
				end
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

function sfx(n, channel, offset, length)

	channel = channel or -1
	offset = offset or 0
	length = length or 0

	if fxPlayer == nil then
		fxPlayer = playdate.sound.sampleplayer.new(fx[n + 1])
	else
		if fxPlayer:isPlaying() then
			fxPlayer:stop()
		end
		fxPlayer:setSample(fx[n + 1])
	end

	fxPlayer:play()

    -- TODO

end

function camera(x, y)

	x = x or 0
	y = y or 0
    playdate.display.setOffset(kDisplayOffsetX + x, kDisplayOffsetY + y)

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