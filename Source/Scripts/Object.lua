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
	self.hitbox = { x=0,y=0,w=8,h=8 }

	self.spd = {x=0,y=0}
	self.rem = {x=0,y=0}

	self:setCenter(0,0)
	self:setZIndex(10)
	self:moveTo(self.pos)
	self:setCollideRect(self.hitbox.x, self.hitbox.y, self.hitbox.w, self.hitbox.h)
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

	local sprites = playdate.graphics.sprite.querySpritesAtPoint(self.pos.x+ox, self.pos.y+oy)
	print("is_solid", ox, oy, #sprites)
	if #sprites == 0 then
		return false
	end
	return true

end

function Object:is_ice(ox, oy)

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
	return playdate.graphics.sprite.kCollisionTypeSlide
end