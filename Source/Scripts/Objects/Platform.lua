local pd <const> = playdate
local gfx <const> = pd.graphics
local img <const> = gfx.image.new("Assets/platform")
local rnd <const> = pico8.rnd
local x_min <const> = -16 + 36
local x_max <const> = 128 + 36

class('Platform').extends(ParentObject)

function Platform:init(x, y, dir, parent)

	Platform.super.init(self, x-1, y-2, parent)

	self.type = "platform"
	self.type_id = 12
	self.dir = dir or 1
	self.x -= 4
	self.solids = false
	self.hitbox = pd.geometry.rect.new(0, 0, 16, 8)
	self.last = self.pos.x

	self.collisionResponse = gfx.sprite.kCollisionTypeOverlap
	self:setImage(img)
	self:setCollideRect(self.hitbox:offsetBy(1,1))
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

    if not self:check("Player", 0, 0) then
        local hit = self:collide("Player", 0, -1)
    	print("----", "--", "Platform:_update()", hit)
        if hit ~= nil then
        	print("----", "--", "Platform:_update()", "hit", hit.pos, self.pos, self.pos.x - self.last)
            hit:move_x(self.pos.x - self.last, 1)
        end
   	else
    	-- print("----", "!!", "Platform:_update()", "self:check(Player, 0, 0)")
    end

	-- self.diff = self.pos.x - self.last
	-- if self.diff > 1 or self.diff < -1 then
	-- 	self.diff = 0
	-- end
		
	self.last = self.pos.x

end

function Platform:_draw()

	self:moveTo(self.pos.x, self.pos.y)

end

-- function Platform:hit(player)

-- 	if player ~= nil and self.diff then
-- 		player:move_x(self.diff, 1)
-- 	end

-- end

