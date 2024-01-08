local pd <const> = playdate
local gfx <const> = pd.graphics
local image_table <const> = gfx.imagetable.new("Assets/fruit")
local img <const> = image_table:getImage(2)
local sin <const> = pico8.sin
local max <const> = pico8.max
local appr <const> = pico8.celeste.appr
local sign <const> = pico8.celeste.sign

class('FlyFruit').extends(ParentObject)

function FlyFruit:init(x, y, parent)

	FlyFruit.super.init(self, x, y, parent)
	self.start = y
	self.fly = false
	self.step = 0.5
	self.solids = false
	self.sfx_delay = 8
	self:setImage(img)
	self:setGroups({4})
	self:setCollideRect(self.hitbox:offsetBy(1,1))
	self:setCollidesWithGroups({1})
	self:moveTo(x - 1, y)
	self:setZIndex(20)
	self:add()
	return self

end

function FlyFruit:_update()

	print("FlyFruit")
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
	self:moveTo(self.pos.x, self.pos.y)

end

function FlyFruit:hit(player)

	if player ~= nil then
		player.djump = player.max_djump
		sfx_timer = 20
		sfx(13)
		-- got_FlyFruit[1+level_index] = true
		LifeUp(self.x, self.y)
		self:destroy()
	end

end
