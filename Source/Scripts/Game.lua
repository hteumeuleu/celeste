class('Game').extends()

local data <const> = g_data

function Game:init()

	Game.super.init(self)
	self:scale(2)
	self.player = Player(20, 62)
	self.platform = Platform(60, 62, -1)
	-- map
	local tilemap = playdate.graphics.tilemap.new()
	tilemap:setImageTable(data.imagetables.tiles)
	tilemap:setTiles(data.rooms.test, 25)
	local wallSprites = playdate.graphics.sprite.addWallSprites(tilemap, data.emptyIDs, 0, -4)
	for _, s in ipairs(wallSprites) do
		s:setGroups({2})
		s:setCenter(0,0)
		s:moveBy(s.width/2*-1, s.height/2*-1)
		s.is_solid = true
		s.is_ground = true
		s.is_ice = false
		s.collisionResponse = function(other)
			return playdate.graphics.sprite.kCollisionTypeSlide
		end
	end
	playdate.graphics.sprite.setBackgroundDrawingCallback(
		function(x, y, width, height)
			tilemap:draw(0,-4)
		end
	)
	-- return
	return self

end

-- scale()
--
function Game:scale(n)

	playdate.display.setScale(n)
	local kDisplayOffsetX = playdate.display.getWidth() / 2
	local kDisplayOffsetY = playdate.display.getHeight() / 2
	kDrawOffsetX = (playdate.display.getWidth() - 128) / 2
	kDrawOffsetY = (playdate.display.getHeight() - 128) / 2

	if data.cache ~= nil then
		data.cache:moveTo(kDisplayOffsetX, kDisplayOffsetY)
	end
	if self.options ~= nil then
		self.options:moveTo(kDisplayOffsetX, kDisplayOffsetY)
	end
	for i, layer in ipairs(layers) do
		if layers[layer] ~= nil and type(layers[layer]) == "table" then
			layers[layer]:moveTo(kDisplayOffsetX, kDisplayOffsetY)
		end
	end

end

function Game:update()

	for _, o in ipairs(globalObjectsTable) do
		if o.move and o.spd then
			o:move(o.spd.x, o.spd.y)
		end
	end

end

function Game:draw()

	for _, o in ipairs(globalObjectsTable) do
		if o.draw then
			o:draw()
		end
	end

end
