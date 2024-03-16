local pd <const> = playdate
local gfx <const> = pd.graphics
local image_table <const> = gfx.imagetable.new("Assets/flag")

class('Flag').extends(ParentObject)

function Flag:init(x, y, parent)

	Flag.super.init(self, x+5, y, parent)
	self.type_id = 17
	self.score = 0
	self.show = false
	-- for i=1, #self.parent.parent.got_fruit do
	-- 	if got_fruit[i] then
	-- 		self.score += 1
	-- 	end
	-- end
	self:setCollideRect(self.hitbox:offsetBy(1,1))
	self:setImage(image_table:getImage(1))
	self:moveTo(self.pos.x - 1, self.pos.y - 1)
	self:setZIndex(20)
	self:add()

	FlagRestartButton(0, 0, self)

	-- TODO: game_obj:saveScore()

end

function Flag:_draw()

	self.spr = math.floor((self.parent.parent.frames / 5) % 3) + 1
	self:setImage(image_table:getImage(self.spr))

	if self.show then
		if not self.flagScore then
			self.flagScore = FlagScore(72, 6, self)
		end
	elseif self:collide("Player", 0, 0) ~= nil then
		psfx(55)
		sfx_timer = 30
		self.show = true
	end

end
