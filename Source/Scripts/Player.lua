class('Player').extends(Object)

local max_djump=1
local has_dashed=false
local freeze=0
local shake=0

function Player:init(x,y)

	Player.super.init(self,x,y)
	self.spr = 1
	self.p_jump=false
	self.p_dash=false
	self.grace=0
	self.jbuffer=0
	self.djump=max_djump
	self.dash_time=0
	self.dash_effect_time=0
	self.dash_target={x=0,y=0}
	self.dash_accel={x=0,y=0}
	self.hitbox = {x=1,y=3,w=6,h=5}
	self.spr_off=0
	self.was_on_ground=false
	self:setCollideRect(self.hitbox.x+1, self.hitbox.y+1, self.hitbox.w, self.hitbox.h)
	self:setGroups({1})
	self:draw()
	return self

end

function Player:update()

	Player.super.update(self)

	-- key shorthand
	local k_left=playdate.kButtonLeft
	local k_right=playdate.kButtonRight
	local k_up=playdate.kButtonUp
	local k_down=playdate.kButtonDown
	local k_jump=playdate.kButtonA
	local k_dash=playdate.kButtonB

	-- print(#self.collisions)

	-- input left/right
	local input = playdate.buttonIsPressed(k_right) and 1 or (playdate.buttonIsPressed(k_left) and -1 or 0)

	-- spikes collide
	-- if spikes_at(self.x+self.hitbox.x,self.y+self.hitbox.y,self.hitbox.w,self.hitbox.h,self.spd.x,self.spd.y) then
	-- 	self:kill()
	-- end

	-- bottom death
	if self.pos.y>128 then
		self:kill()
	end

	-- local on_ground=self:is_solid(0,1)
	-- local on_ice=self:is_ice(0,1)
	local on_ground=false
	local on_ice=false
	local sprites_below=playdate.graphics.sprite.querySpritesAtPoint(self.pos.x+self.hitbox.x, self.pos.y+self.hitbox.y+self.hitbox.h)
	if #sprites_below > 0 then
		for _, s in ipairs(sprites_below) do
			if s.is_solid then
				on_ground = true
			end
			if s.is_ice then
				on_ice = true
			end
		end
	end

	-- smoke particles
	if on_ground and not self.was_on_ground then
		-- init_object(smoke,self.x,self.y+4)
	end

	-- input jump
	local jump = playdate.buttonIsPressed(k_jump) and not self.p_jump
	self.p_jump = playdate.buttonIsPressed(k_jump)
	if (jump) then
		self.jbuffer=4
	elseif self.jbuffer>0 then
		self.jbuffer-=1
	end

	-- input dash
	local dash = playdate.buttonIsPressed(k_dash) and not self.p_dash
	self.p_dash = playdate.buttonIsPressed(k_dash)

	if on_ground then
		self.grace=6
		if self.djump<max_djump then
			psfx(54)
			self.djump=max_djump
		end
	elseif self.grace > 0 then
		self.grace-=1
	end

	self.dash_effect_time -=1
	if self.dash_time > 0 then
		-- init_object(smoke,self.x,self.y)
		self.dash_time-=1
		self.spd.x=appr(self.spd.x,self.dash_target.x,self.dash_accel.x)
		self.spd.y=appr(self.spd.y,self.dash_target.y,self.dash_accel.y)
	else
		-- move
		local maxrun=1
		local accel=0.6
		local deccel=0.15

		if not on_ground then
			accel=0.4
		elseif on_ice then
			accel=0.05
			if input==(self.flip.x and -1 or 1) then
				accel=0.05
			end
		end

		if math.abs(self.spd.x) > maxrun then
			self.spd.x=appr(self.spd.x,sign(self.spd.x)*maxrun,deccel)
		else
			self.spd.x=appr(self.spd.x,input*maxrun,accel)
		end

		--facing
		if self.spd.x~=0 then
			self.flip.x=(self.spd.x<0)
		end

		-- gravity
		local maxfall=2
		local gravity=0.21

		if math.abs(self.spd.y) <= 0.15 then
			gravity*=0.5
		end

		-- wall slide
		local sprites_at_input=playdate.graphics.sprite.querySpritesAtPoint(self.pos.x+self.hitbox.x+self.width*input, self.pos.y+self.hitbox.y)
		local is_solid_input_0=false
		local is_ice_input_0=false
		if #sprites_at_input > 0 then
			for _, s in ipairs(sprites_at_input) do
				if s.is_solid then
					is_solid_input_0 = true
				end
				if s.is_ice then
					is_ice_input_0 = true
				end
			end
		end
		if input~=0 and is_solid_input_0 and not is_ice_input_0 then
			maxfall=0.4
			if (math.random()*10)<2 then
				-- init_object(smoke,self.x+input*6,self.y)
			end
		end

		if not on_ground then
			self.spd.y=appr(self.spd.y,maxfall,gravity)
		end

		-- jump
		if self.jbuffer>0 then
			if self.grace>0 then
				-- normal jump
				psfx(1)
				self.jbuffer=0
				self.grace=0
				self.spd.y=-2
				-- init_object(smoke,self.x,self.y+4)
			else
				-- wall jump
				local sprites_at_minus_three=playdate.graphics.sprite.querySpritesAtPoint(self.pos.x+self.hitbox.x+self.width*-3, self.pos.y+self.hitbox.y)
				local sprites_at_three=playdate.graphics.sprite.querySpritesAtPoint(self.pos.x+self.hitbox.x+self.width*3, self.pos.y+self.hitbox.y)
				local is_solid_minusthree_0=false
				local is_solid_three_0=false
				if #sprites_at_minus_three > 0 then
					for _, s in ipairs(sprites_at_minus_three) do
						if s.is_solid then
							is_solid_minusthree_0 = true
						end
					end
				end
				if #sprites_at_three > 0 then
					for _, s in ipairs(sprites_at_three) do
						if s.is_solid then
							is_solid_three_0 = true
						end
					end
				end
				local wall_dir=(is_solid_minusthree_0 and -1 or is_solid_three_0 and 1 or 0)
				if wall_dir~=0 then
					psfx(2)
					self.jbuffer=0
					self.spd.y=-2
					self.spd.x=-wall_dir*(maxrun+1)
					if not self:is_ice(wall_dir*3,0) then
						-- init_object(smoke,self.x+wall_dir*6,self.y)
					end
				end
			end

			-- dash
			local d_full=5
			local d_half=d_full*0.70710678118

			if self.djump>0 and dash then
				-- init_object(smoke,self.x,self.y)
				self.djump-=1
				self.dash_time=4
				has_dashed=true
				self.dash_effect_time=10
				local v_input=(playdate.buttonIsPressed(k_up) and -1 or (playdate.buttonIsPressed(k_down) and 1 or 0))
				if input~=0 then
					if v_input~=0 then
					   self.spd.x=input*d_half
					   self.spd.y=v_input*d_half
					else
					   self.spd.x=input*d_full
					   self.spd.y=0
					end
				elseif v_input~=0 then
					self.spd.x=0
					self.spd.y=v_input*d_full
				else
					self.spd.x=(self.flip.x and -1 or 1)
					self.spd.y=0
				end

				psfx(3)
				freeze=2
				shake=6
				self.dash_target.x=2*sign(self.spd.x)
				self.dash_target.y=2*sign(self.spd.y)
				self.dash_accel.x=1.5
				self.dash_accel.y=1.5

				if self.spd.y<0 then
					self.dash_target.y*=.75
				end

				if self.spd.y~=0 then
					self.dash_accel.x*=0.70710678118
				end
				if self.spd.x~=0 then
					self.dash_accel.y*=0.70710678118
				end
			elseif dash and self.djump<=0 then
				psfx(9)
				-- init_object(smoke,self.x,self.y)
			end
		end
	end

	-- animation
	self.spr_off+=0.25
	if not on_ground then
		if is_solid_input_0 then
			self.spr=5
		else
			self.spr=3
		end
	elseif playdate.buttonIsPressed(k_down) then
		self.spr=6
	elseif playdate.buttonIsPressed(k_up) then
		self.spr=7
	elseif (self.spd.x==0) or (not playdate.buttonIsPressed(k_left) and not playdate.buttonIsPressed(k_right)) then
		self.spr=1
	else
		self.spr=1+self.spr_off%4
	end

	 -- next level
	if self.pos.y<-4 and level_index()<30 then
		self.pos.y = 0
		self.pos.x = 0
		next_room()
	end

	-- was on the ground
	self.was_on_ground=on_ground

end

function Player:draw(x, y)

	Player.super.draw(self, x, y, width, height)

	-- clamp in screen
	if self.pos.x<-1 or self.pos.x>121 then
		self.pos.x=clamp(self.pos.x,-1,121)
		self.spd.x=0
	end

	-- update image
	local pdimg <const> = data.imagetables.player:getImage(math.floor(self.spr))
	self:setImage(pdimg, self:getFlipValue(self.flip.x,self.flip.y))

	-- move sprite
	_, _, self.collisions, _ = self:moveWithCollisions(self.pos.x-1, self.pos.y-1-4)

end

function Player:kill()

end