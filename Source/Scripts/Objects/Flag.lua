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
	self:clearCollideRect()
	self:setImage(image_table:getImage(1))
	self:moveTo(self.pos.x - 1, self.pos.y - 1)
	self:setZIndex(20)
	self:add()

	-- TODO: game_obj:saveScore()

end

function Flag:_draw()

end
