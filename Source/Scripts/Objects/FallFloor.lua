local pd <const> = playdate
local gfx <const> = pd.graphics
local image_table <const> = gfx.imagetable.new("Assets/tiles")
local psfx <const> = pico8.celeste.psfx

class('FallFloor').extends(ParentObject)

function FallFloor:init(x, y, parent)

	FallFloor.super.init(self, x, y, parent)

	self.type_id = 4
	self.state = 0
	self.previous_state = 0
	self.is_solid_sprite = true
	self.spr = 24
	self.delay = 0
	local img <const> = image_table:getImage(math.floor(self.spr))
	self:setImage(img)
	self:setZIndex(20)
	self:setGroups({3})
	self:setCollidesWithGroups({1})
	self:add()

end

function FallFloor:_update()

	self.previous_state = self.state
	-- Shaking
	if self.state == 1 then
		self.delay -= 1
		if self.delay <= 0 then
			self.state = 2
			self.delay = 60 --how long it hides for
			self.collideable = false
			self:setCollisionsEnabled(false)
		end
	-- invisible, waiting to reset
	elseif self.state == 2 then
		self.delay -= 1
		if self.delay <= 0 and not self:collide("Player", 0, 0) ~= nil then
			psfx(7)
			self.state = 0
			self.collideable = true
			self:setCollisionsEnabled(true)
			Smoke(self.pos.x, self.pos.y, self.parent)
		end
	end

end

function FallFloor:_draw()

	if self.previous_state ~= self.state or self.state > 0 then
		self.spr = 0
		if self.state ~= 2 then
			if self.state ~= 1 then
				self.spr = 24
			else
				self.spr = 24 + (15 - self.delay) / 5
			end
		end
		local img <const> = image_table:getImage(math.floor(self.spr))
		self:setImage(img)
	end

end

function FallFloor:hit(player)

	if self.state == 0 then
		psfx(15)
		self.state = 1
		self.delay = 15 --how long until it falls
		Smoke(self.pos.x, self.pos.y, self.parent)

		local above = self:collide("Spring", 0, -1)
		if above ~= nil then
			above:_break()
		end
	end

end
