local pd <const> = playdate
local gfx <const> = pd.graphics
local image_table <const> = gfx.imagetable.new("Assets/tiles")
local img <const> = image_table:getImage(1)
local sin <const> = pico8.sin

class('Spring').extends(ParentObject)

function Spring:init(x, y, parent)

	Spring.super.init(self, x, y, parent)

	self.spr = 18
	self.hide_in = 0
	self.hide_for = 0
	self.delay = 0
	self:setGroups({4})
	self:setCollidesWithGroups({1})
	self:setZIndex(10)
	self:add()

end

function Spring:_draw()

	local img <const> = image_table:getImage(math.floor(self.spr) + 1)
	self:setImage(img)

end

function Spring:_update()

	if self.hide_for > 0 then
		self.hide_for -= 1
		if self.hide_for <= 0 then
			self.spr = 18
			self.delay = 0
		end
	elseif self.delay > 0 then
		self.delay -= 1
		if self.delay <= 0 then
			self.spr = 18
		end
	end
	-- begin hiding
	if self.hide_in > 0 then
		self.hide_in -= 1
		if self.hide_in <= 0 then
			self.hide_for = 60
			self.spr = 0
		end
	end

end

function Spring:hit(player)

	if player ~= nil and self.spr == 18 then
		if player.spd.y >= 0 then
			self.spr = 19
			player.pos.y = self.pos.y - 4
			player.spd.x *= 0.2
			player.spd.y = -3
			player.djump = player.max_djump
			self.delay = 10
			Smoke(self.pos.x, self.pos.y)

			-- TODO: breakable below us
			-- local below=this.collide(fall_floor,0,1)
			-- if below~=nil then
			-- 	break_fall_floor(below)
			-- end

			psfx(8)
		end
	end

end
