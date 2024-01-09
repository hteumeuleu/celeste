local pd <const> = playdate
local gfx <const> = pd.graphics
local img <const> = gfx.image.new("Assets/tree")

class('Tree').extends(gfx.sprite)

function Tree:init(x, y)

	Tree.super.init(self, x, y)
	self:setCenter(0, 0)
	self:moveTo(x - 1, y - 1)
	self:setImage(img)
	self:add()

end
