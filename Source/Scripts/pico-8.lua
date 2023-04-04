local GFX = playdate.graphics
local musicPlayer, fxPlayer
local data = g_data
pico8 = {}

function pauseMusic()

	if musicPlayer ~= nil then
		if musicPlayer:isPlaying() then
			musicPlayer:pause()
		end
	end

end

function unPauseMusic()

	if musicPlayer ~= nil then
		if not musicPlayer:isPlaying() then
			musicPlayer:play()
		end
	end

end

--
-- PICO-8 functions
--
-- function add(t, value, index)

-- 	index = index or #t+1
-- 	table.insert(t, index, value)

-- end

function del(t, value)

	for i=1, #t do
		if t[i] == value then
			table.remove(t, i)
			break
		end
	end

end

-- function flr(num)

-- 	return math.floor(num)

-- end

-- function abs(num)

-- 	return math.abs(num)

-- end

-- function rnd(arg)

-- 	arg = arg or 1.0
-- 	if type(arg) == "table" then
-- 		return arg[math.random(1, #arg)]
-- 	else
-- 		return math.random() * arg
-- 	end

-- end

-- function sin(angle)

-- 	return math.sin(math.rad(angle * -1 * 360.0))

-- end

-- function cos(angle)

-- 	return math.cos(math.rad(angle * -1 * 360.0))

-- end

-- function min(first, second)

-- 	second = second or 0
-- 	return math.min(first, second)

-- end

-- function max(first, second)

-- 	second = second or 0
-- 	return math.max(first, second)

-- end

function rectfill(x0, y0, x1, y1, col)

	local left = math.min(x0, x1)
	local top = math.min(y0, y1)
	local width = math.max(x0, x1) - left + 1
	local height = math.max(y0, y1) - top + 1
	if col == nil then
		GFX.setColor(GFX.kColorBlack)
	elseif col == 7 then
		GFX.setColor(GFX.kColorWhite)
	end
	GFX.fillRect(left, top, width, height)

end

function circfill(x, y, r, col)

	r = r or 4
	if col == nil then
		GFX.setColor(GFX.kColorBlack)
	elseif col == 7 then
		GFX.setColor(GFX.kColorWhite)
	end
	GFX.fillCircleAtPoint(x, y, r)

end

-- function foreach(tbl, func)

-- 	for _, item in ipairs(tbl) do
-- 		func(item)
-- 	end

-- end

-- function btn(i, p)

-- 	if i == nil then
-- 		return
-- 	end
-- 	p = p or 0
-- 	return playdate.buttonIsPressed(i)

-- end

-- spr(n, [x,] [y,] [w,] [h,] [flip_x,] [flip_y])
function spr(n, x, y, w, h, flip_x, flip_y)

	if n > #data.imagetables.tiles or n <= 0 then return end
	n = math.floor(n) or 1
	x = math.floor(x) or 0
	y = math.floor(y) or 0
	w = w or 1.0
	h = h or 1.0
	flip_x = flip_x or false
	flip_y = flip_y or false
	local flip =  GFX.kImageUnflipped
	if flip_x and flip_y then
		 flip = GFX.kImageFlippedXY
	elseif flip_x then
		 flip = GFX.kImageFlippedX
	elseif flip_y then
		 flip = GFX.kImageFlippedY
	end

	local img = data.imagetables.tiles:getImage(n + 1)
	img:draw(x, y, flip)

end

-- function mget(celx, cely)

-- 	return data.map[celx + (cely * 128) + 1]

-- end

function fget(tile, flag)

	local mask_at = data.flags[tile+1]
	if flag == nil then
		return mask_at
	end
	flag = flag or 0x0
	return (mask_at & (1 << flag)) ~= 0

end

-- function map(celx, cely, sx, sy, celw, celh, mask)

-- 	mask = mask or 0x0
--     for cx=0,celw-1 do
--         for cy=0,celh-1 do
--         	local tile = mget(celx + cx, cely + cy)
--         	if tile <= #data.imagetables.tiles then
-- 				if (mask == 0) or (fget(tile, mask)) then
-- 					local img = data.imagetables.tiles:getImage(tile + 1)
-- 					local x = sx + (cx * 8)
-- 					local y = sy + (cy * 8)
-- 					img:draw(x, y)
-- 				end
-- 			end
--         end
--     end

-- end

function pal(c0, c1, p)

	-- TODO

end

local current_music_index = 0

function make_sure_music_is_playing(n)

	if current_music_index ~= n then
		pico8.music(n)
	end

end

pico8.music = function(n, fade_len, channel_mask)

	fade_len = fade_len or 1000
	channel_mask = channel_mask or 1
	current_music_index = n

	if n == -1 and musicPlayer ~= nil and musicPlayer:isPlaying() then
		musicPlayer:stop()
	end

	if data.music[n] ~= nil then
		if musicPlayer == nil then
			musicPlayer = playdate.sound.fileplayer.new(data.music[n])
			musicPlayer:setStopOnUnderrun(false)
		else
			if musicPlayer:isPlaying() then
				musicPlayer:stop()
			end
			musicPlayer:load(data.music[n])
		end
		if musicPlayer ~= nil then
			musicPlayer:play(0)
		end
	end

end

function sfx(n, channel, offset, length)

	channel = channel or -1
	offset = offset or 0
	length = length or 0

	if fxPlayer == nil then
		fxPlayer = playdate.sound.sampleplayer.new(data.sfx[n])
		fxPlayer:setVolume(0.125)
	else
		if fxPlayer:isPlaying() then
			fxPlayer:stop()
		end
		fxPlayer:setSample(playdate.sound.sample.new(data.sfx[n]))
	end
	if fxPlayer ~= nil then
		fxPlayer:play()
	end

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
	if color == 0 then
		GFX.setImageDrawMode(GFX.kDrawModeFillBlack)
	else
		GFX.setImageDrawMode(GFX.kDrawModeFillWhite)
	end
	GFX.drawText(text, x, y)
	GFX.setImageDrawMode(GFX.kDrawModeCopy)

end

function sub(str, pos0, pos1)

	pos0 = pos0 or 1
	if pos1 ~= nil and type(pos1) ~= "number" then
		pos1 = pos0 + 1
	else
		pos1 = pos1 or #str
	end
	return string.sub(str,pos0,pos1)

end

local line_last_x0 = 0
local line_last_y0 = 0
function line(x0, y0, x1, y1, col)

	x1 = x1 or 1
	y1 = y1 or 1
	line_last_x0 = x0
	line_last_y0 = y0
	if col == nil then
		GFX.setColor(GFX.kColorBlack)
	elseif col == 7 then
		GFX.setColor(GFX.kColorWhite)
	end
	GFX.drawLine(x0, y0, x1, y1)

end