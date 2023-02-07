class('Object').extends(playdate.graphics.sprite)

globalObjectsTable = {}

function Object:init(x, y)

	Object.super.init(self)
	-- self.type = type
	self.collideable = true
	self.solids = true
	-- self.spr = type.tile
	self.flip = {x=false,y=false}

	self.pos = playdate.geometry.point.new(x, y)
	self.hitbox = playdate.geometry.rect.new(0, 0, 8, 8)

	self.spd = playdate.geometry.vector2D.new(0, 0)
	self.rem = playdate.geometry.vector2D.new(0, 0)

	self:setCenter(0,0)
	self:setZIndex(10)
	self:moveTo(self.pos)
	self:setCollideRect(self.hitbox)
	self:add()
	table.insert(globalObjectsTable, self)

	return self

end

function Object:update()

	Object.super.update(self)

end

function Object:draw(x, y, width, height)
end

function Object:destroy()

	table.remove(globalObjectsTable, self)
	self:remove()

end

function Object:is_solid(ox, oy)

	local rect = self:getCollideRect():offsetBy(self.pos.x+ox, self.pos.y+oy)
	local spritesInRect = playdate.graphics.sprite.querySpritesInRect(rect)
	if #spritesInRect > 0 then
		for _, s in ipairs(spritesInRect) do
			if s ~= self and s.is_solid then
				return true
			end
		end
	end
	return false

end

function Object:is_ice(ox, oy)

	local rect = self:getCollideRect():offsetBy(self.pos.x+ox, self.pos.y+oy)
	local spritesInRect = playdate.graphics.sprite.querySpritesInRect(rect)
	if #spritesInRect > 0 then
		for _, s in ipairs(spritesInRect) do
			if s ~= self and s.is_ice then
				return true
			end
		end
	end
	return false

end

function Object:collide(type,ox,oy)

end

function Object:check(type,ox,oy)

end

function Object:move(ox,oy)

	local amount
	-- [x] get move amount
	self.rem.x += ox
	amount = math.floor(self.rem.x + 0.5)
	self.rem.x -= amount
	self:move_x(amount,0)

	-- [y] get move amount
	self.rem.y += oy
	amount = math.floor(self.rem.y + 0.5)
	self.rem.y -= amount
	self:move_y(amount)

	self:moveWithCollisions(self.pos.x, self.pos.y)

end

function Object:move_x(amount,start)

	if self.solids then
		local step = sign(amount)
		for i=start,math.abs(amount) do
			if not self:is_solid(step,0) then
				self.pos.x += step
			else
				self.spd.x = 0
				self.rem.x = 0
				break
			end
		end
	else
		self.pos.x += amount
	end

end

function Object:move_y(amount)

	if self.solids then
		local step = sign(amount)
		for i=0,math.abs(amount) do
		 if not self:is_solid(0,step) then
				self.pos.y += step
			else
				self.spd.y = 0
				self.rem.y = 0
				break
			end
		end
	else
		self.pos.y += amount
	end

end

function Object:getFlipValue(flip_x, flip_y)

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

function Object:collisionResponse(other)
	print(self.pos, other.pos)
	return playdate.graphics.sprite.kCollisionTypeSlide
end