local pd <const> = playdate
local gfx <const> = pd.graphics
local image_table <const> = gfx.imagetable.new("Assets/key")
local img <const> = image_table:getImage(1)
local flip <const> = pico8.flip
local sin <const> = pico8.sin

class('Key').extends(ParentObject)

function Key:init(x, y, parent)

	Key.super.init(self, x, y, parent)

	self.type_id = 10
	self.spr = 8

	self.collisionResponse = gfx.sprite.kCollisionTypeOverlap
	self:setCollideRect(self.hitbox:offsetBy(1,1))
	self:setCollidesWithGroups({1})
	self:setImage(img)
	self:setZIndex(20)
	self:moveTo(self.pos.x - 1, self.pos.y - 1)
	self:add()

end

function Key:_update()

	local was = math.floor(self.spr)
	self.spr = 9 + (sin(self.parent.parent.frames / 30) + 0.5) * 1
	local is = math.floor(self.spr)
	if is == 10 and is ~= was then
		self.flip.x = not self.flip.x
	end
	if self:check(self.parent.player, 0, 0) then
		self:hit()
	end

end

function Key:_draw()

	local img <const> = image_table:getImage(math.floor(self.spr) - 7)
	self:setImage(img, flip(self.flip.x, self.flip.y))

end

function Key:hit()

	sfx(23)
	self.parent.parent.sfx_timer = 10
	self.parent.has_key = true
	self:destroy()

end
