local pd <const> = playdate
local gfx <const> = pd.graphics
local image_table <const> = gfx.imagetable.new("Assets/player")
local flip <const> = pico8.flip

class('PlayerSpawn').extends(ParentObject)

-- PlayerSpawn
--
function PlayerSpawn:init(x, y, parent)

	PlayerSpawn.super.init(self, x, y, parent)


	sfx(4)
	self.spr = 3
	self.target = pd.geometry.point.new(self.pos.x, self.pos.y)
	self.pos.y = 128
	self.spd.y = -4
	self.state = 0
	self.delay = 0
	self.solids = false
	-- create_hair(this) -- TODO

	self:setZIndex(20)
	self:clearCollideRect()
	self:add()

end

function PlayerSpawn:_update()

	-- Jumping up
	if self.state == 0 then
		print("--", self.y, self.pos.y, self.target.y + 16)
		if self.pos.y < self.target.y + 16 then
			self.state = 1
			self.delay = 3
		end
	-- Falling
	elseif self.state == 1 then
		self.spd.y += 0.5
		if self.spd.y > 0 and self.delay > 0 then
			self.spd.y = 0
			self.delay -= 1
		end
		if self.spd.y > 0 and self.pos.y > self.target.y then
			self.pos.y = self.target.y
			self.spd = { x = 0, y = 0 }
			self.state = 2
			self.delay = 5
			self.parent.parent.shake = 5
			Smoke(self.pos.x, self.pos.y + 4)
			sfx(5)
		end
	-- Landing
	elseif self.state == 2 then
		self.delay -= 1
		self.spr = 6
		if self.delay < 0 then
			self:destroy()
			Player(self.pos.x, self.pos.y, self.parent)
		end
	end

end

function PlayerSpawn:_draw()

	-- print("PlayerSpawn", self.state, self.target, self.pos)
	local img <const> = image_table:getImage(math.floor(self.spr))
	self:setImage(img, flip(self.flip.x, self.flip.y))
	self:moveTo(self.pos.x - 1, self.pos.y - 1)

	-- draw_hair(this,1) -- TODO
end
