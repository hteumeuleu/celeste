-- Global settings
math.randomseed(playdate.getSecondsSinceEpoch())
playdate.graphics.setFont(data.font)
playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)
playdate.graphics.sprite.setBackgroundDrawingCallback(
	function(x, y, width, height)
	end
)

-- Variables
local kDisplayOffsetX = 200
local kDisplayOffsetY = 120
kDrawOffsetX = 0
kDrawOffsetY = 0
local sceneWidth = 128
local sceneHeight = 128

function flip(flip_x, flip_y)

	local flip =  playdate.graphics.kImageUnflipped
	if flip_x and flip_y then
		 flip = playdate.graphics.kImageFlippedXY
	elseif flip_x then
		 flip = playdate.graphics.kImageFlippedX
	elseif flip_y then
		 flip = playdate.graphics.kImageFlippedY
	end
	return flip

end

-- Scene sprite
local kSceneImage <const> = playdate.graphics.image.new(sceneWidth,sceneHeight)
local kScene <const> = playdate.graphics.sprite.new(kSceneImage)
kScene:setRedrawsOnImageChange(true)
kScene:moveTo(kDisplayOffsetX, kDisplayOffsetY)
kScene:add()

function drawInScene(func)

	playdate.graphics.pushContext(kSceneImage)
		func()
	playdate.graphics.popContext()

end

-- Screen scaling
function scale(x)

	playdate.display.setScale(x)
	kDisplayOffsetX = playdate.display.getWidth() / 2
	kDisplayOffsetY = playdate.display.getHeight() / 2
	kDrawOffsetX = (playdate.display.getWidth() - sceneWidth) / 2
	kDrawOffsetY = (playdate.display.getHeight() - sceneHeight) / 2
	kScene:moveTo(kDisplayOffsetX, kDisplayOffsetY)

end
scale(2)

-- PICO-8 functions
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

	local left = math.min(x0, x1)
	local top = math.min(y0, y1)
	local width = math.max(x0, x1) - left + 1
	local height = math.max(y0, y1) - top + 1
	drawInScene(function()
		if col == nil then
			playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)
		end
		playdate.graphics.fillRect(left, top, width, height)
	end)

end

function circfill(x, y, r, col)

	r = r or 4
	drawInScene(function()
		if col == nil then
			playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)
		end
		playdate.graphics.fillCircleAtPoint(x, y, r)
	end)

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

	if n > #data.tiles or n <= 0 then return end
	n = flr(n) or 1
	x = flr(x) or 0
	y = flr(y) or 0
	w = w or 1.0
	h = h or 1.0
	flip_x = flip_x or false
	flip_y = flip_y or false
	local flip =  playdate.graphics.kImageUnflipped
	if flip_x and flip_y then
		 flip = playdate.graphics.kImageFlippedXY
	elseif flip_x then
		 flip = playdate.graphics.kImageFlippedX
	elseif flip_y then
		 flip = playdate.graphics.kImageFlippedY
	end

	local img = data.tiles:getImage(n + 1)
	drawInScene(function()
		img:draw(x, y, flip)
	end)

end

function mget(celx, cely)

	return data.map[celx + (cely * 128) + 1]

end

function fget(tile, flag)

	local mask_at = data.flags[tile+1]
	if flag == nil then
		return mask_at
	end
	flag = flag or 0x0
	return (mask_at & (1 << flag)) ~= 0

end

function map(celx, cely, sx, sy, celw, celh, mask)

	mask = mask or 0x0
    for cx=0,celw-1 do
        for cy=0,celh-1 do
        	local tile = mget(celx + cx, cely + cy)
        	if tile <= #data.tiles then
				if (mask == 0) or (fget(tile, mask)) then
					local img = data.tiles:getImage(tile + 1)
					local x = sx + (cx * 8)
					local y = sy + (cy * 8)
					-- Ignore rock background
					-- if fget(tile) ~= 4 then
						drawInScene(function()
							img:draw(x, y)
						end)
					-- end
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
		fxPlayer = playdate.sound.sampleplayer.new(data.sfx[n + 1])
	else
		if fxPlayer:isPlaying() then
			fxPlayer:stop()
		end
		fxPlayer:setSample(data.sfx[n + 1])
	end

	fxPlayer:play()

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
	drawInScene(function()
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
		playdate.graphics.drawText(text, x, y)
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
	end)

end