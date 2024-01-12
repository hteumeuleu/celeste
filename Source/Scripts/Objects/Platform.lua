local pd <const> = playdate
local gfx <const> = pd.graphics
local img <const> = gfx.image.new("Assets/platform")
local rnd <const> = pico8.rnd
local x_min <const> = 20
local x_max <const> = 164

class('Platform').extends(ParentObject)

function Platform:init(x, y, dir, parent)

	Platform.super.init(self, x, y, parent)

	self.dir = dir or 1
	self.x -= 4
	self.solids = false
	self.hitbox = pd.geometry.rect.new(1, 1, 16, 4)
	self.last = self.pos.x

	self.collisionResponse = gfx.sprite.kCollisionTypeOverlap
	self:setImage(img)
	self:setCollideRect(self.hitbox)
	self:setGroups({4})
	self:setCollidesWithGroups({1})
	self:setZIndex(0)
	self:add()

end

function Platform:_update()

	self.spd.x = self.dir * 0.65
	if self.pos.x < x_min then
		self.pos.x = x_max
	elseif self.pos.x > x_max then
		self.pos.x = x_min
	end

	self.diff = self.pos.x - self.last
	if self.diff > 1 or self.diff < -1 then
		self.diff = 0
	end

	if self.parent.player ~= nil then
		local player_bottom_y = self.parent.player.y + self.parent.player.hitbox.y + self.parent.player.hitbox.height
		local platform_top_y = self.y + self.hitbox.y
		if player_bottom_y < platform_top_y then
			self.is_solid_sprite = true
		else
			self.is_solid_sprite = false
		end
	end
		
	self.last = self.pos.x

end

function Platform:_draw()

	self:moveTo(self.pos.x - 1, self.pos.y - 2)

end

function Platform:hit(player)

	if player ~= nil and self.diff then
		player:move_x(self.diff, 1)
	end

end

