local pd <const> = playdate
local gfx <const> = pd.graphics
local sign <const> = pico8.celeste.sign
local del <const> = pico8.del

class('ParentObject').extends(gfx.sprite)

-- ParentObject
--
function ParentObject:init(x, y, parent)

	ParentObject.super.init(self)
	self.parent = parent or nil

	self.collideable = true
	self.solids = true

	self.flip = { x = false, y = false }

	self.pos = pd.geometry.point.new(x, y)
	self.hitbox = pd.geometry.rect.new(0, 0, 8, 8)

	self.spd = pd.geometry.vector2D.new(0, 0)
	self.rem = pd.geometry.vector2D.new(0, 0)

	self:setCenter(0, 0)
	self:setCollideRect(self.hitbox)
	self:moveTo(self.pos.x, self.pos.y)

	return self

end

-- add
--
function ParentObject:add()

	ParentObject.super.add(self)
	if self.parent ~= nil and self.type_id ~= nil then
		if self.parent.obj[self.type_id] == nil then
			self.parent.obj[self.type_id] = {}
		end
		table.insert(self.parent.obj[self.type_id], self)
	end

end

-- destroy
--
function ParentObject:destroy()

	self:remove()
	if self.parent ~= nil and self.type_id ~= nil and self.parent.obj[self.type_id] ~= nil then
		del(self.parent.obj[self.type_id], self)
	end

end

function ParentObject:is_solid(ox, oy)

	if (#self.parent.obj[12] > 0) then
	    if oy > 0 and not self:check("Platform", ox, 0) and self:check("Platform", ox, oy) then
	        return true
	    end
    end
    return pico8.celeste.solid_at(self.pos.x + self.hitbox.x + ox, self.pos.y + self.hitbox.y + oy, self.hitbox.width, self.hitbox.height, self)
     or self:check("FallFloor", ox, oy)
     or self:check("FakeWall", ox, oy)

end

function ParentObject:is_ice(ox, oy)

	local rect <const> = playdate.geometry.rect.new(self.pos.x + self.hitbox.x + ox, self.pos.y + self.hitbox.y + oy, self.hitbox.width, self.hitbox.height)
	local sprites_in_rect <const> = gfx.sprite.querySpritesInRect(rect)
	for i=1, #sprites_in_rect do
		local s = sprites_in_rect[i]
		if s ~= self and s.is_ice_sprite == true then
			return true
		end
	end
	return false

end

function ParentObject:move(ox, oy)

	-- [x] get move amount
	if ox ~= 0 then
		self.rem.x += ox
		local amount = math.floor(self.rem.x + 0.5)
		self.rem.x -= amount
		self:move_x(amount, 0)
	end

	-- [y] get move amount
	if oy ~= 0 then
		self.rem.y += oy
		local amount = math.floor(self.rem.y + 0.5)
		self.rem.y -= amount
		self:move_y(amount)
	end

end

function ParentObject:move_x(amount, start)

	if self.solids then
		local step = 0
		if amount > 0 then
			step = 1
		elseif amount < 0 then
			step = -1
		end

		local count = amount
		if count < 0 then
			count = count * -1
		end

		for i=start, count do
			if not self:is_solid(step, 0) then
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

function ParentObject:move_y(amount, start)

	if self.solids then

		local step <const> = sign(amount)
		local count <const> = math.abs(amount)
		for i=0, count do
			if not self:is_solid(0, step) then
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

function ParentObject:collide(type, ox, oy)

    local other
    local obj = self
    for i=1,#self.parent.obj do
    	for j=1, #self.parent.obj[i] do
            other=self.parent.obj[i][j]
            if other ~=nil and other.className == type and other ~= obj and other.collideable and
                other.pos.x+other.hitbox.x+other.hitbox.width > obj.pos.x+obj.hitbox.x+ox and 
                other.pos.y+other.hitbox.y+other.hitbox.height > obj.pos.y+obj.hitbox.y+oy and
                other.pos.x+other.hitbox.x < obj.pos.x+obj.hitbox.x+obj.hitbox.width+ox and 
                other.pos.y+other.hitbox.y < obj.pos.y+obj.hitbox.y+obj.hitbox.height+oy then
                return other
            end
        end
    end
    return nil

end

function ParentObject:check(other, ox, oy)

	return self:collide(other, ox, oy) ~= nil

end
