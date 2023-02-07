class('Platform').extends(Object)

local data <const> = g_data

function Platform:init(x,y,dir)

	Platform.super.init(self,x,y)
	self.dir = dir
	self.pos.x -= 4
	self.solids = false
	self.hitbox = playdate.geometry.rect.new(1, 1, 16, 4)
	self.last = self.pos.x
	self.diff = 0
	-- set image
	local pdimg <const> = data.imagetables.platform
	self:setImage(pdimg)
	-- sprite settings
	self:setCollideRect(self.hitbox)
	self:setGroups({4})
	self:setZIndex(20)
	self:setCollidesWithGroups({1})
	self:draw()
	return self

end

function Platform:update()

	Platform.super.update(self)
	self.spd.x = self.dir*0.65
	if self.pos.x < -16 then
		self.pos.x = 200
	elseif self.pos.x>200 then
		self.pos.x = -16
	end
	self.diff = self.pos.x - self.last
	if self.diff > 1 or self.diff < -1 then
		self.diff = 0
	end
	self.last = self.pos.x

end

function Platform:hit(other)

	print("hit")
	other:move_x(self.diff,1)

end

function Platform:collisionResponse(other)

	print(other.y, self.y)
	if other.y >= self.y then
		return playdate.graphics.sprite.kCollisionTypeOverlap
	end
	return playdate.graphics.sprite.kCollisionTypeOverlap

end