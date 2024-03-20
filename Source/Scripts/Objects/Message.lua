local pd <const> = playdate
local gfx <const> = pd.graphics
local img <const> = gfx.image.new(115, 23, gfx.kColorClear)
local rectfill <const> = pico8.rectfill
local sub <const> = pico8.sub
local _print <const> = pico8._print

class('Message').extends(ParentObject)

function Message:init(x, y, parent)

	Message.super.init(self, x, y, parent)

	self.type_id = 13
	self.text = "-- celeste mountain --#this memorial to those# perished on the climb"
	self.index = 0
	self.last = 0
	self.off = pd.geometry.vector2D.new(2, 2)

	self:setSize(16, 16)
	self.hitbox = pd.geometry.rect.new(0, 0, 16, 16)
	self:setCollideRect(self.hitbox)
	self:add()

	self.panel = gfx.sprite.new(gfx.image.new(115, 23, gfx.kColorClear))
	self.panel.was_drawn = false
	self.panel:setImage(img)
	self.panel:setZIndex(40)
	self.panel:setCenter(0, 0)
	self.panel:moveTo(42, 90)
	self.panel:add()

end

function Message:_draw()

	if self:collide("Player", 4, 0) ~= nil then
		if self.index < #self.text then
			self.index += 0.5
			if self.index >= self.last + 1 then
				self.last += 1
				sfx(35)
				local img <const> = self.panel:getImage()
				gfx.pushContext(img)
					local i = self.index
					if sub(self.text, i, i) ~= "#" then
						rectfill(self.off.x - 2, self.off.y - 2, self.off.x + 7, self.off.y + 6, 7)
						_print(sub(self.text, i, i), self.off.x, self.off.y, 0)
						self.off.x += 5
					else
						self.off.x = 2
						self.off.y += 7
					end
				gfx.popContext()
				self.panel:setImage(img)
				self.panel:add()
				self.panel.was_drawn = true
			end
		end
	else
		if self.panel.was_drawn then
			self.panel:remove()
			self.panel:setImage(gfx.image.new(115, 23, gfx.kColorClear))
			self.index = 0
			self.last = 0
			self.off = pd.geometry.vector2D.new(2, 2)
		end
	end

end
