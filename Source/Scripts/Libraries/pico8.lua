local pd <const> = playdate
local gfx <const> = pd.graphics

pico8 = {}
pico8.celeste = {}

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

pico8.celeste.clamp = function(val, a, b)
	return math.max(a, math.min(b, val))
end

pico8.celeste.appr = function(val,target,amount)
	return val > target 
		and math.max(val - amount, target) 
		or math.min(val + amount, target)
end

pico8.celeste.sign = function(v)
	return v > 0 and 1 or v < 0 and -1 or 0
end

pico8.celeste.maybe = function()
	return (math.random() * 1) < 0.5
end
