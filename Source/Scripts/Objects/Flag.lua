local pd <const> = playdate
local gfx <const> = pd.graphics
local image_table <const> = gfx.imagetable.new("Assets/flag")

class('Flag').extends(ParentObject)

function Flag:init(x, y, parent)

	Flag.super.init(self, x, y, parent)
	self.type_id = 17

end
