-- Global settings
math.randomseed(playdate.getSecondsSinceEpoch())
playdate.setCrankSoundsDisabled(true)
playdate.graphics.setFont(data.font)
playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)

-- Variables
local kDisplayOffsetX = 200
local kDisplayOffsetY = 120
kDrawOffsetX = 0
kDrawOffsetY = 0
local sceneWidth = 128
local sceneHeight = 128

-- Scene layers
layers = {
	"bg_terrain",
	"terrain",
	"hair",
	"extra"
}

for i, layer in ipairs(layers) do
	local image <const> = playdate.graphics.image.new(sceneWidth,sceneHeight, playdate.graphics.kColorClear)
	layers[layer] = playdate.graphics.sprite.new(image)
	layers[layer]:setSize(sceneWidth, sceneHeight)
	layers[layer]:moveTo(kDisplayOffsetX, kDisplayOffsetY)
	layers[layer]:setZIndex(10)
	layers[layer]:add()
end

function drawInLayer(layer, func)

	if layers[layer] ~= nil and type(layers[layer]) == "table" then
		local image <const> = layers[layer]:getImage()
		playdate.graphics.pushContext(image)
			func(image)
		playdate.graphics.popContext()
	end

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
