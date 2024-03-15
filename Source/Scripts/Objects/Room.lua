import "Scripts/Libraries/LDtk"

local pd <const> = playdate
local gfx <const> = pd.graphics
local ldtk <const> = LDtk
ldtk.load("Levels/celeste-classic.ldtk", false)
local offset <const> = pd.geometry.point.new(-4, -4)

class('Room').extends()

-- Room
--
function Room:init(index, parent)

	Room.super.init(self)
	self.parent = parent or nil
	self.index = index
	if self.index == nil or self.index < 0 or self.index >= self.parent.level_total then
		self.index = 0
	end
	self.level = (1 + self.index) * 100
	self.name = "Level_" .. self.index
	self.title = self.level .. " m"
	if self.index == 11 then
		self.title = "old site"
	elseif self.index == 30 then
		self.title = "summit"
	end
	self.got_fruit = false
	self.tas = TAS(self.index)
	self:load()
	return self

end

-- load()
--
-- based on SquidGodDev’s video tutorial.
function Room:load()

	gfx.sprite.removeAll()

	self.obj = {}
	for i = 1, 19 do
		self.obj[i] = {}
	end
	self.has_key = false
	self.has_dashed = false
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
					tilemapImage:fadedImage(0.3, gfx.image.kDitherTypeDiagonalLine):draw(0,0)
				gfx.popContext()
				layerSprite:setImage(stylizedImage)
			elseif layer_name == "Foreground" then
				layerSprite:setTilemap(tilemap)
				self.tilemap = tilemap
			end

			layerSprite:setCenter(0, 0)
			layerSprite:moveTo(layer.rect.x + offset.x, layer.rect.y + offset.y)
			layerSprite:setZIndex(layer.zIndex)
			layerSprite:add()

			local addWallSprites = function(tileID, is_solid, is_ice, is_spike, dir, spr)
				local emptyTiles = ldtk.get_empty_tileIDs(level_name, tileID, layer_name)
				if emptyTiles then
					local wallSprites <const> = gfx.sprite.addWallSprites(tilemap, emptyTiles, layer.rect.x + offset.x, layer.rect.y + offset.y)
					for _, wallSprite in ipairs(wallSprites) do
						wallSprite:setCenter(0, 0)
						wallSprite:moveBy((wallSprite.width/2)*-1, (wallSprite.height/2)*-1)
						wallSprite:setCollidesWithGroups({1})
						wallSprite:setGroups({5})
						if is_solid then
							wallSprite.is_solid_sprite = true
						end
						if is_ice then
							wallSprite.is_ice_sprite = true
						end
						if is_spike then
							wallSprite.spike = true
							wallSprite.dir = dir
							wallSprite.spr = spr
						end
					end
				end
			end

			-- Foreground (walls and spikes) collision sprites
			if layer_name == "Foreground" then
				addWallSprites("Ice", true, true, false, nil, nil)
				addWallSprites("Solid", true, false, false, nil, nil)
				addWallSprites("SpikeUp", false, false, true, "up", 17)
				addWallSprites("SpikeDown", false, false, true, "down", 27)
				addWallSprites("SpikeRight", false, false, true, "up", 43)
				addWallSprites("SpikeLeft", false, false, true, "left", 59)
			end
		end
	end

	-- Entities
	for index, entity in ipairs(LDtk.get_entities(level_name)) do
		local x <const> = entity.position.x + offset.x
		local y <const> = entity.position.y + offset.y
		if entity.name == "Player" then
			PlayerSpawn(x, y, self)
		elseif entity.name == "FakeWall" and not self.got_fruit then
			FakeWall(x, y, self)
		elseif entity.name == "FallFloor" then
			FallFloor(x, y, self)
		elseif entity.name == "Fruit" and not self.got_fruit then
			Fruit(x, y, self)
		elseif entity.name == "FlyFruit" and not self.got_fruit then
			FlyFruit(x, y, self)
		elseif entity.name == "Spring" then
			Spring(x, y, self)
		elseif entity.name == "Balloon" then
			Balloon(x, y, self)
		elseif entity.name == "PlatformLeft" then
			Platform(x, y, -1, self)
		elseif entity.name == "PlatformRight" then
			Platform(x - 8, y, 1, self)
		elseif entity.name == "Chest" and not self.got_fruit then
			Chest(x, y, self)
		elseif entity.name == "Key" and not self.got_fruit then
			Key(x, y, self)
		elseif entity.name == "Message" then
			Message(x, y, self)
		elseif entity.name == "BigChest" then
			BigChest(x, y, self)
		elseif entity.name == "Flag" then
			Flag(x, y, self)
		elseif entity.name == "Tree" then
			Tree(x, y)
		end
	end

	-- Room Title and Timer
	RoomTitle(self.title, self)

	-- Clouds
	self:initClouds()

	-- Particles
	self:initParticles()

end

function Room:restart()

	self.parent.will_restart = true
	self.parent.delay_restart = 15

end


function Room:initClouds()

	local max_clouds = 16
	if not pd.isSimulator then
		max_clouds = 8
	end
	self.clouds = {}
	for i=0, max_clouds do
		table.insert(self.clouds, Cloud())
	end

end

function Room:initParticles()

	local max_particles = 24
	if not pd.isSimulator then
		max_particles = 18
	end
	self.particles = {}
	for i=0, max_particles do
		table.insert(self.particles, Particle())
	end

end
