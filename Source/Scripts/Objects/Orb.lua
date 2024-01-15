local pd <const> = playdate
local gfx <const> = pd.graphics
local image_table <const> = gfx.imagetable.new("Assets/tiles")
local img <const> = gfx.image.new(200, 120, gfx.kColorClear)
local appr <const> = pico8.celeste.appr
local sin <const> = pico8.sin
local cos <const> = pico8.cos
local circfill <const> = pico8.circfill

class('Orb').extends(ParentObject)

function Orb:init(x, y, parent)

	Orb.super.init(self, x, y, parent)
	self.spd.y =- 4
	self.solids = false

	self:setImage(image_table:getImage(103))
	self:setZIndex(20)
	self:add()

	self.particles_sprite = gfx.sprite.new(img)
	self.particles_sprite:setZIndex(21)
	self.particles_sprite:setCenter(0, 0)
	self.particles_sprite:moveTo(0, 0)
	self.particles_sprite:add()

end

function Orb:_draw()

	self.spd.y = appr(self.spd.y, 0, 0.5)
	local hit = self:collide(self.parent.player, 0, 0)
	if self.spd.y == 0 and hit ~= nil then
		self.parent.parent.music_timer = 45
		sfx(51)
		self.parent.parent.freeze = 10
		self.parent.parent.shake = 10
		self.parent.parent.max_djump = 2
		self.parent.player.djump = 2
		self:destroy()
	end
	self:moveTo(self.pos.x, self.pos.y)
	local off = self.parent.parent.frames / 30
	gfx.pushContext(img)
		gfx.clear(gfx.kColorClear)
		for i=0,7 do
			circfill(self.pos.x + 4 + cos(off + i/8) * 8, self.pos.y + 4 + sin(off + i/8) * 8,1,7)
		end
	gfx.popContext()
	self.particles_sprite:setImage(img)

end

function Orb:destroy()

	Orb.super.destroy(self)
	self.particles_sprite:remove()

end
