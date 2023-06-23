import "Scripts/Libraries/LDtk"
import "Scripts/Cloud"

class('Room').extends()

local gfx <const> = playdate.graphics
local ldtk <const> = LDtk
ldtk.load("Levels/celeste-classic.ldtk", false)
local offset <const> = playdate.geometry.point.new(-8, -8)

-- Room
--
function Room:init(index)

	Room.super.init(self)
	self.index = index
	if self.index == nil or self.index < 0 or self.index > 10 then
		self.index = 0
	end
	self.name = "Level_" .. self.index
	self:load()
	return self

end

-- load()
--
-- based on SquidGodDev’s video tutorial.
function Room:load()

	gfx.sprite.removeAll()

	local level_name = self.name

	for layer_name, layer in pairs(ldtk.get_layers(level_name)) do
		if layer.tiles then
			local tilemap = ldtk.create_tilemap(level_name, layer_name)
			local layerSprite = gfx.sprite.new()

			if layer_name == "Background" then
				local tilemapImage <const> = gfx.image.new(layer.rect.width, layer.rect.height)
				playdate.graphics.pushContext(tilemapImage)
					tilemap:draw(0, 0)
				playdate.graphics.popContext()
				local stylizedImage <const> = gfx.image.new(layer.rect.width, layer.rect.height)
				gfx.pushContext(stylizedImage)
					-- First we draw the tilemap in black (inverted).
					-- This creates visual depth and shows the background is in front of the clouds.
					tilemapImage:invertedImage():draw(0, 0)
					-- Then we draw the tilemap with the diagonal line effect.
					-- The fade is done at 0.5x scale to match the original game’s size and get a better visual (in my opinion).
					tilemapImage:scaledImage(0.5):fadedImage(0.3, gfx.image.kDitherTypeDiagonalLine):scaledImage(2):draw(0,0)
				gfx.popContext()
				layerSprite:setImage(stylizedImage)
			else
				layerSprite:setTilemap(tilemap)
			end

			layerSprite:setCenter(0, 0)
			layerSprite:moveTo(layer.rect.x + offset.x, layer.rect.y + offset.y)
			layerSprite:setZIndex(layer.zIndex)
			layerSprite:add()

			if layer_name == "Foreground" then
				local emptyTiles = ldtk.get_empty_tileIDs(level_name, "Solid", layer_name)
				if emptyTiles then
					gfx.sprite.addWallSprites(tilemap, emptyTiles, layer.rect.x + offset.x, layer.rect.y + offset.y)
				end
			end
		end
	end

	-- Level outer walls
	-- gfx.sprite.addEmptyCollisionSprite(0, 0, 400, 10)
	-- gfx.sprite.addEmptyCollisionSprite(0, 230, 400, 10)
	-- gfx.sprite.addEmptyCollisionSprite(0, 10, 10, 220)
	-- gfx.sprite.addEmptyCollisionSprite(390, 10, 10, 220)

	-- Entities
	-- for index, entity in ipairs(LDtk.get_entities(level_name)) do
	-- 	if entity.name == "Light" then
	-- 		local light = Light(entity.position.x + offset.x, entity.position.y + offset.y)
	-- 		self.total += 1
	-- 		light:attachLevel(self)
	-- 	elseif entity.name == "Battery" then
	-- 		self.battery = Battery(entity.position.x + offset.x, entity.position.y + offset.y)
	-- 	elseif entity.name == "Crate" then
	-- 		Crate(entity.position.x + offset.x, entity.position.y + offset.y)
	-- 	elseif entity.name == "Player" then
	-- 		self.player = Player(entity.position.x + offset.x, entity.position.y + offset.y)
	-- 		self.player:attachLevel(self)
	-- 	elseif entity.name == "Text" then
	-- 		local offGridOffset = playdate.geometry.point.new(tonumber(entity.fields.offsetX), tonumber(entity.fields.offsetY))
	-- 		Text(entity.position.x + offset.x + offGridOffset.x, entity.position.y + offset.y + offGridOffset.y, entity.size.width, entity.size.height, entity.fields.text, tonumber(entity.fields.alignment))
	-- 	end
	-- end

	-- White flash effect
	local animator = playdate.graphics.animator.new(500, 1, 0,  playdate.easingFunctions.outQuad, 200)
	local white = gfx.image.new(400, 240, gfx.kColorWhite)
	local flash = gfx.sprite.new(white)
	flash:setCenter(0, 0)
	flash:moveTo(0, 0)
	flash:setZIndex(999)
	flash:add()
	flash.update = function(that)
		if not animator:ended() then
			that:setImage(white:fadedImage(animator:currentValue(), gfx.image.kDitherTypeAtkinson))
		end
	end

	-- Clouds
	self:initClouds()

end

function Room:initClouds()

	local max_clouds = 4
	if playdate.isSimulator then
		max_clouds = 16
	end
	self.clouds = {}
	for i=0, max_clouds do
		table.insert(self.clouds, Cloud())
	end

end