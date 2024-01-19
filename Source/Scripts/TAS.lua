local pd <const> = playdate
local gfx <const> = pd.graphics
local file <const> = pd.file
local path <const> = 'TAS/'
local k_left <const> = pd.kButtonLeft
local k_right <const> = pd.kButtonRight
local k_up <const> = pd.kButtonUp
local k_down <const> = pd.kButtonDown
local k_jump <const> = pd.kButtonA
local k_dash <const> = pd.kButtonB
local split <const> = function(s, delimiter)
	result = {}
	for match in (s..delimiter):gmatch("(.-)"..delimiter) do
		table.insert(result, match)
	end
	return result
end

class("TAS").extends(gfx.sprite)

function TAS:init(level_index)

	TAS.super.init(self)
	self.level_index = level_index or 0
	self.balloon_seeds = {}
	self.keypresses = {}
	self:read()

	pico8.btn = function(i)
		if self.keypresses[pico8.frames] ~= nil then
			if i == k_left and self.keypresses[pico8.frames][0] then
				return true
			elseif i == k_right and self.keypresses[pico8.frames][1] then
				return true
			elseif i == k_up and self.keypresses[pico8.frames][2] then
				return true
			elseif i == k_down and self.keypresses[pico8.frames][3] then
				return true
			elseif i == k_jump and self.keypresses[pico8.frames][4] then
				return true
			elseif i == k_dash and self.keypresses[pico8.frames][5] then
				return true
			end
		end
		return false
	end

end

function TAS:read()

	local filename = path .. 'TAS' .. self.level_index + 1 .. '.tas'
	if file.exists(filename) then
		local size = file.getSize(filename)
		local tas_file = file.open(filename, file.kFileRead)
		local tas_content = tas_file:read(size)
		tas_file:close()

		local start_index = string.find(tas_content .. '', ']') + 1
		local end_index = string.find(string.reverse(tas_content), ',')
		if end_index == 1 then
			end_index = #tas_content - 1
		else
			end_index = #tas_content
		end
		local tas_keypresses = string.sub(tas_content, start_index, end_index)
		self.keypresses = split(tas_keypresses, ',')
		printTable(self.keypresses)

		for i=1, #self.keypresses do
			local c = self.keypresses[i]
			self.keypresses[i] = {}
			for j=0,5 do
				if math.floor(c/math.pow(2,j))%2==1 then
					self.keypresses[i][j] = true
				else
					self.keypresses[i][j] = false
				end
			end
		end
	end

end