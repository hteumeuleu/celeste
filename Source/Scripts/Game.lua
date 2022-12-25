class('Game').extends()

function Game:init()

	Game.super.init(self)
	self.player = Player(20, 92)
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

function Game:update()

	self.player:move(self.player.spd.x, self.player.spd.y)
	-- self.player:update()

end

function Game:draw()

	self.player:draw()

end
