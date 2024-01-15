local pd <const> = playdate
local gfx <const> = pd.graphics
local image_table <const> = gfx.imagetable.new("Assets/big_chest")
local img <const> = gfx.image.new(200, 120, gfx.kColorClear)
local rnd <const> = pico8.rnd
local line <const> = pico8.line

class('BigChest').extends(ParentObject)

function BigChest:init(x, y, parent)

	BigChest.super.init(self, x, y, parent)
	self.state = 0
	self.hitbox = pd.geometry.rect.new(0, 0, 16, 8)

	self:setImage(image_table:getImage(1))
	self:setCollideRect(self.hitbox:offsetBy(1, 1))
	self:setCollidesWithGroups({1})
	self:setZIndex(20)
	self:moveTo(self.pos.x - 1, self.pos.y)
	self:add()

	self.particles_sprite = gfx.sprite.new(img)
	self.particles_sprite:setZIndex(21)
	self.particles_sprite:setCenter(0, 0)
	self.particles_sprite:moveTo(0, 0)

end

function BigChest:_draw()

	if self.state == 0 then
		local hit = self:collide(self.parent.player, 0, 8)
		if hit ~= nil and hit:is_solid(0, 1) then
			-- music(-1, 500, 7)
			sfx(37)
			self.parent.player.pause_player = true
			hit.spd.x = 0
			hit.spd.y = 0
			self.state = 1
			Smoke(self.pos.x, self.pos.y)
			Smoke(self.pos.x + 8, self.pos.y)
			self.timer = 60
			self.particles = {}
			self.particles_sprite:add()
		end
	elseif self.state == 1 then
		self.timer -= 1
		self.parent.parent.shake = 5
		self.parent.parent.flash_bg = true
		if self.timer <= 45 and #self.particles < 50 then
			table.insert(self.particles, {
				x = 1 + rnd(14),
				y = 0,
				h = 32 + rnd(32),
				spd = 8 + rnd(8)
			})
		end
		if self.timer < 0 then
			self.state = 2
			self.particles = {}
			self.parent.parent.flash_bg = false
			self.parent.parent.new_bg = true
			Orb(self.pos.x + 4, self.pos.y + 4, self.parent)
			self.parent.player.pause_player = false
			self.particles_sprite:remove()
		end
		gfx.pushContext(img)
			gfx.clear(gfx.kColorClear)
			for i=1, #self.particles do
				local p = self.particles[i]
				p.y += p.spd
				line(self.pos.x + p.x, self.pos.y + 8 - p.y, self.pos.x + p.x, math.min(self.pos.y + 8 - p.y + p.h, self.pos.y + 8), 7)
			end
		gfx.popContext()
		self.particles_sprite:setImage(img)
	end
	if self.state ~= 0 then
		self:setImage(image_table:getImage(2))
	end

end
