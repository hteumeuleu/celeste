local pd <const> = playdate
local gfx <const> = pd.graphics
local imageTable <const> = gfx.imagetable.new("Assets/fruit")
local img <const> = imageTable:getImage(1)

class('Fruit').extends(gfx.sprite)

function Fruit:init(x, y)

	Fruit.super.init(self)
	self.start = y
	self.off = 0
	self.hitbox = pd.geometry.rect.new(0, 0, 8, 8)
	self:setImage(img)
	self:setCenter(0, 0)
	self:setGroups({4})
	self:setCollideRect(self.hitbox:offsetBy(1,1))
	self:moveTo(x - 1, y)
	self:setZIndex(20)
	self:add()
	return self

end

function Fruit:update()

	Fruit.super.update(self)
	self.off += 1
	self:moveTo(self.x, self.start + sin(self.off/40) * 2.5)

end

function Fruit:hit(trigger)

	-- if player~=nil then
	-- 	player.djump=max_djump
	-- 	sfx_timer=20
	-- 	sfx(13)
	-- 	got_fruit[1+level_index] = true
	-- 	init_object(lifeup,this.x,this.y)
	-- 	destroy_object(this)
	-- end

end
