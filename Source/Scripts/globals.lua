-- Global settings
math.randomseed(playdate.getSecondsSinceEpoch())
playdate.graphics.setFont(data.font)
playdate.graphics.clear(playdate.graphics.kColorBlack)
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

-- Scene layers
layers = {
	"clouds",
	"bg_terrain",
	"terrain",
	"fg_terrain",
	"hair",
	"credits",
	"level30",
	"cache"
}

for i, layer in ipairs(layers) do
	local image <const> = playdate.graphics.image.new(sceneWidth,sceneHeight, playdate.graphics.kColorClear)
	layers[layer] = playdate.graphics.sprite.new(image)
	layers[layer]:setSize(sceneWidth, sceneHeight)
	layers[layer]:moveTo(kDisplayOffsetX, kDisplayOffsetY)
	layers[layer]:setZIndex(i)
	layers[layer]:add()
end

local pdimg = playdate.graphics.image.new(400,240, playdate.graphics.kColorClear)
playdate.graphics.pushContext(pdimg)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.fillRect(0,0,400,56)
	playdate.graphics.fillRect(0,56,136,128)
	playdate.graphics.fillRect(264,56,136,128)
	playdate.graphics.fillRect(0,184,400,240)
playdate.graphics.popContext()
layers.cache:setImage(pdimg)
layers.cache:setZIndex(30)
layers.cache:moveTo(200,120)

function drawInLayer(layer, func)

	if layers[layer] ~= nil and type(layers[layer]) == "table" then
		local image <const> = layers[layer]:getImage()
		playdate.graphics.pushContext(image)
			func(image)
		playdate.graphics.popContext()
	end

end

-- Screen scaling
function scale(x)

	playdate.display.setScale(x)
	kDisplayOffsetX = playdate.display.getWidth() / 2
	kDisplayOffsetY = playdate.display.getHeight() / 2
	kDrawOffsetX = (playdate.display.getWidth() - sceneWidth) / 2
	kDrawOffsetY = (playdate.display.getHeight() - sceneHeight) / 2

	for i, layer in ipairs(layers) do
		if layers[layer] ~= nil and type(layers[layer]) == "table" then
			layers[layer]:moveTo(kDisplayOffsetX, kDisplayOffsetY)
		end
	end

end
scale(2)

-- layers.level30:setVisible(false)
-- layers.credits:setVisible(false)
-- layers.particles:setVisible(false)
-- layers.fg_terrain:setVisible(false)
-- layers.terrain:setVisible(false)
-- layers.platforms_big_chest:setVisible(false)
-- layers.bg_terrain:setVisible(false)
layers.clouds:setVisible(false)

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
