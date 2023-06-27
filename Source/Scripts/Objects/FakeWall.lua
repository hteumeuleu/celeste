local pd <const> = playdate
local gfx <const> = pd.graphics
local img <const> = gfx.image.new("Assets/fake-wall")

class('FakeWall').extends(gfx.sprite)

function FakeWall:init(x, y)

	FakeWall.super.init(self)
	self.hitbox = pd.geometry.rect.new(-2,-2,36,36)
	self:setImage(img)
	self:setCenter(0, 0)
	self:setCollideRect(self.hitbox)
	self:moveTo(x, y)
	self:setZIndex(20)
	self:add()
	return self

end

-- function FakeWall:update()

-- 	FakeWall.super.update(self)

-- end

function FakeWall:hit(trigger)

	sfx(16)
	self:remove()
	gfx.sprite.addDirtyRect(self.x, self.y, self.width, self.height)
    Smoke(self.x, self.y)
    Smoke(self.x + 16, self.y)
    Smoke(self.x, self.y + 16)
    Smoke(self.x + 16, self.y + 16)
    Fruit(self.x + 8, self.y + 8)

end

