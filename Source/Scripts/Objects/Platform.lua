local pd <const> = playdate
local gfx <const> = pd.graphics
local img <const> = gfx.image.new("Assets/platform")
local rnd <const> = pico8.rnd
local x_min <const> = -16 + 36
local x_max <const> = 128 + 36

class('Platform').extends(ParentObject)

function Platform:init(x, y, dir, parent)

	Platform.super.init(self, x-4, y-1, parent)

	self.type = "platform"
	self.type_id = 12
	self.dir = dir or 1
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
        if hit ~= nil then
            hit:move_x(self.pos.x - self.last, 1)
        end
    end
		
	self.last = self.pos.x

end

function Platform:_draw()

	self:moveTo(self.pos.x-1, self.pos.y-1)

end
