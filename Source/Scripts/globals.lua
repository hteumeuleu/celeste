-- Variables
local kDisplayOffsetX = 200
local kDisplayOffsetY = 120
kDrawOffsetX = 0
kDrawOffsetY = 0
local sceneWidth = 128
local sceneHeight = 128
local data = g_data

-- Global settings
math.randomseed(playdate.getSecondsSinceEpoch())
playdate.setCrankSoundsDisabled(true)
playdate.graphics.setFont(data.font)
playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)

-- Scene layers
layers = {
	"bg_terrain",
	"terrain",
	"hair",
	"extra"
}

for i=1, #layers do
	local layer = layers[i]
	local image <const> = playdate.graphics.image.new(sceneWidth,sceneHeight, playdate.graphics.kColorClear)
	layers[layer] = playdate.graphics.sprite.new(image)
	layers[layer]:setSize(sceneWidth, sceneHeight)
	layers[layer]:moveTo(kDisplayOffsetX, kDisplayOffsetY)
	layers[layer]:setZIndex(10)
	layers[layer]:add()
end

-- Returns Playdate’s flip value from two booleans
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

function maybe()
	return (math.random()*1)<0.5
end

function sin(angle)
	return math.sin(math.rad(angle * -1 * 360.0))
end

function sign(v)
	return v>0 and 1 or v<0 and -1 or 0
end

function appr(val, target, amount)
	return val > target 
		and math.max(val - amount, target) 
		or math.min(val + amount, target)
end