local pd <const> = playdate
local gfx <const> = pd.graphics

pico8 = pico8 or {}
pico8.celeste = {}

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

pico8.celeste.spikes_at = function(x,y,w,h,xspd,yspd)
	local i, j
	for i=math.max(0,math.floor(x/8)),math.min(15,(x+w-1)/8) do
		for j=math.max(0,math.floor(y/8)),math.min(15,(y+h-1)/8) do

			local tile = nil
			local rect = pd.geometry.rect.new(i*8, j*8, 8, 8)
			local query = gfx.sprite.querySpritesInRect(rect)
			if #query > 1 then
				for i=1, #query do
					local other = query[i]
					if other.spike == true and other.spr ~= nil then
						tile = other.spr
					print("spr:", rect, other.spr)
					end
					-- printTable(other)
				end
			end
			-- local tile=tile or tile_at(i,j)
			-- print(tile, (y+h-1)%8, ">=6", y+h, "==", j*8+8, yspd)
			if tile==17 and ((y+h-1)%8>=6 or y+h==j*8+8) and yspd>=0 then
				return true
			elseif tile==27 and y%8<=2 and yspd<=0 then
				return true
			elseif tile==43 and x%8<=2 and xspd<=0 then
				return true
			elseif tile==59 and ((x+w-1)%8>=6 or x+w==i*8+8) and xspd>=0 then
				return true
			end
		end
	end
	return false
end
