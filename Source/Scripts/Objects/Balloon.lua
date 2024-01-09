local pd <const> = playdate
local gfx <const> = pd.graphics
local image_table <const> = gfx.imagetable.new("Assets/balloon")
local img <const> = gfx.image.new(10, 17, gfx.kColorClear)
local img_balloon <const> = image_table:getImage(1)
local flip <const> = pico8.flip
local sin <const> = pico8.sin
local rnd <const> = pico8.rnd

class('Balloon').extends(ParentObject)

function Balloon:init(x, y, parent)

	Balloon.super.init(self, x, y, parent)

	self.offset = rnd(1)
	self.start = self.pos.y
	self.timer = 0
	self.spr = 22
	self.hitbox = playdate.geometry.rect.new(-1, -1, 10, 10)

	self:_draw()
	self:setGroups({4})
	self:setCollideRect(self.hitbox:offsetBy(1,1))
	self:setCollidesWithGroups({1})
	self:setZIndex(20)
	self:add()

end

function Balloon:_update()

	if self.spr == 22 then
		self.offset += 0.01
		self.pos.y = self.start + sin(self.offset) * 2
	elseif self.timer > 0 then
		self.timer -= 1
	else
		psfx(7)
		Smoke(self.pos.x, self.pos.y)
		self.spr = 22
	end

end

function Balloon:_draw()

	if self.spr == 22 then
		local function drawBalloon(img)
			gfx.pushContext(img)
				gfx.clear(gfx.kColorClear)
				local img_string = image_table:getImage(math.floor(2 + (self.offset * 8) % 3))
				img_balloon:draw(0,0)
				img_string:draw(0,8)
			gfx.popContext()
		end
		drawBalloon(img)
		self:setImage(img)
		self:setVisible(true)
		self:setCollisionsEnabled(true)
		self:moveTo(self.pos.x - 1, self.pos.y - 1)
	else
		self:setVisible(false)
		self:setCollisionsEnabled(false)
	end

end

function Balloon:hit(player)

	if player ~= nil and player.djump ~= nil and player.djump < player.max_djump then
		psfx(6)
		Smoke(self.pos.x, self.pos.y)
		player.djump = player.max_djump
		self.spr = 0
		self.timer = 60
	end

end
