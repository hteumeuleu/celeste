local pd <const> = playdate
local gfx <const> = pd.graphics
local image_table <const> = gfx.imagetable.new("Assets/fruit")
local img <const> = gfx.image.new(30, 10)
local sin <const> = pico8.sin
local max <const> = pico8.max
local appr <const> = pico8.celeste.appr
local sign <const> = pico8.celeste.sign
local flip <const> = pico8.flip

class('FlyFruit').extends(ParentObject)

function FlyFruit:init(x, y, parent)

	FlyFruit.super.init(self, x, y, parent)
	self.type_id = 7
	self.start = y
	self.fly = false
	self.step = 0.5
	self.solids = false
	self.sfx_delay = 8
	self:setImage(img)
	self:setGroups({4})
	self:setCollideRect(self.hitbox:offsetBy(11,1))
	self:setCollidesWithGroups({1})
	self:moveTo(x - 11, y)
	self:setZIndex(20)
	self:add()
	return self

end

function FlyFruit:_update()

	-- Fly away
	if self.fly then
		if self.sfx_delay > 0 then
			self.sfx_delay -= 1
			if self.sfx_delay <= 0 then
				self.parent.parent.sfx_timer = 20
				sfx(14)
			end
		end
		self.spd.y = appr(self.spd.y, -3.5, 0.25)
		if self.pos.y < -16 then
			self:destroy()
		end
	-- Wait
	else
		if self.parent.has_dashed then
			self.fly = true
		end
		self.step += 0.05
		self.spd.y = sin(self.step) * 0.5
	end
	-- Collect
	if self:collide(self.parent.player, 0, 0) then
		self:hit(self.parent.player)
	end

end

function FlyFruit:_draw()

	local off = 0
	if not self.fly then
		local dir <const> = sin(self.step)
		if dir < 0 then
			off = 1 + max(0, sign(self.pos.y - self.start))
		end
	else
		off = (off + 0.25) % 3
	end

	local drawFruit=function(img)
		gfx.pushContext(img)
			gfx.clear(gfx.kColorClear)
			local pdtilewing = image_table:getImage(math.floor(3 + off))
			local pdtilefruit = image_table:getImage(2)
			pdtilewing:draw(3, -1, flip(true, false))
			pdtilewing:draw(17, -1)
			pdtilefruit:draw(10, 0)
		gfx.popContext()
	end

	drawFruit(img)
	self:setImage(img)
	self:moveTo(self.pos.x - 11, self.pos.y - 1)

end

function FlyFruit:hit(player)

	if player ~= nil then
		player.djump = self.parent.parent.max_djump
		sfx_timer = 20
		sfx(13)
		self.parent.got_fruit = true
		LifeUp(self.x, self.y, self.parent)
		self:destroy()
	end

end
