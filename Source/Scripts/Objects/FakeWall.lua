local pd <const> = playdate
local gfx <const> = pd.graphics
local img <const> = gfx.image.new("Assets/fake-wall")
local sign = function(v) return v>0 and 1 or v<0 and -1 or 0 end

class('FakeWall').extends(ParentObject)

function FakeWall:init(x, y, parent)

	FakeWall.super.init(self, x, y, parent)
	self.hitbox = pd.geometry.rect.new(0, 0, 16, 16)
	self.solid = true
	self:setImage(img)
	self:setCollideRect(self.hitbox)
	self:setCollidesWithGroups({1})
	self:setZIndex(20)
	self:add()
	return self

end

function FakeWall:update()

	FakeWall.super.update(self)
	self:setCollideRect(pd.geometry.rect.new(-1, -1, 18, 18))
	local _, _, collisions, length = self:checkCollisions(0, 0)
	if length == 1 then
		local other = collisions[1].other
		if other.dash_effect_time > 0 then
			other.spd.x = -sign(other.spd.x) * 1.5
			other.spd.y = -1.5
			other.dash_time = -1
			self:hit()
		end
	end
	self:setCollideRect(pd.geometry.rect.new(0, 0, 16, 16))

end

function FakeWall:hit()

	sfx_timer=20
	sfx(16)
	self:remove()
	gfx.sprite.addDirtyRect(self.x, self.y, self.width, self.height)
    Smoke(self.x, self.y)
    Smoke(self.x + 8, self.y)
    Smoke(self.x, self.y + 8)
    Smoke(self.x + 8, self.y + 8)
    Fruit(self.x + 4, self.y + 4, self)

end

