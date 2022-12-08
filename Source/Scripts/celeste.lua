-- globals --
-------------

local room = { x=0, y=0 }
local objects = {}
local types = {}
local freeze=0
local shake=0
local will_restart=false
local delay_restart=0
local got_fruit={}
local has_dashed=false
local sfx_timer=0
local has_key=false
local pause_player=false
local flash_bg=false
local music_timer=0
local room_just_changed=true

local k_left=playdate.kButtonLeft
local k_right=playdate.kButtonRight
local k_up=playdate.kButtonUp
local k_down=playdate.kButtonDown
local k_jump=playdate.kButtonA
local k_dash=playdate.kButtonB

-- entry point --
-----------------

function _init()
	title_screen()
end

function title_screen()
	got_fruit = {}
	for i=0,29 do
		add(got_fruit,false)
	end
	frames=0
	deaths=0
	max_djump=1
	start_game=false
	start_game_flash=0
	music(40,0,7)
	load_room(7,3)
end

function begin_game()
	frames=0
	seconds=0
	minutes=0
	music_timer=0
	start_game=false
	music(0,0,7)
	load_room(0,0)
end

function level_index()
	return room.x%8+room.y*8
end

function is_title()
	return level_index()==31
end

-- effects --
-------------

clouds = {}
for i=0,16 do
	add(clouds,{
		x=rnd(128),
		y=rnd(128),
		spd=1+rnd(4),
		w=32+rnd(32)
	})
end

particles = {}
for i=0,24 do
	add(particles,{
		x=rnd(128),
		y=rnd(128),
		s=0+flr(rnd(5)/4),
		spd=0.25+rnd(5),
		off=rnd(1),
		c=6+flr(0.5+rnd(1))
	})
end

for i, item in ipairs(particles) do
	local img <const> = playdate.graphics.image.new(item.s + 1, item.s + 1, playdate.graphics.kColorWhite)
	item.spr = playdate.graphics.sprite.new(img)
	item.spr:setZIndex(30)
end

dead_particles = {}

-- player entity --
-------------------

player =
{
	tile=2,
	init=function(this)
		this.p_jump=false
		this.p_dash=false
		this.grace=0
		this.jbuffer=0
		this.djump=max_djump
		this.dash_time=0
		this.dash_effect_time=0
		this.dash_target={x=0,y=0}
		this.dash_accel={x=0,y=0}
		this.hitbox = {x=1,y=3,w=6,h=5}
		this.spr_off=0
		this.was_on_ground=false
		if this.pdspr ~= nil then
			this.pdspr.type = "player"
			this.pdspr:setCollideRect(this.hitbox.x+1, this.hitbox.y+1, this.hitbox.w, this.hitbox.h)
			this.pdspr:setCollidesWithGroups({2,3,4,5,6})
			this.pdspr:setZIndex(20)
			this.pdspr:setGroups({1})
			this.pdspr.collisionResponse=function(other)
				return playdate.graphics.sprite.kCollisionTypeOverlap
			end
		end
		create_hair(this)
	end,
	update=function(this)
		if (pause_player) then return end

		-- collisions
		local _, _, collisions_at_x_y, length = this.pdspr:checkCollisions(kDrawOffsetX+this.x, kDrawOffsetY+this.y)
		if length > 0 then
			for _, col in ipairs(collisions_at_x_y) do
				if col.other.type == "spikes" then
					-- spikes collide
					if spikes_at(this.x+this.hitbox.x,this.y+this.hitbox.y,this.hitbox.w,this.hitbox.h,this.spd.x,this.spd.y) then
						kill_player(this)
					end
				elseif col.other.type == "fall_floor" and col.spriteRect.y + col.spriteRect.height <= col.otherRect.y + col.otherRect.height then
					break_fall_floor(col.other.obj)
				elseif (col.other.type == "fruit" or col.other.type == "fly_fruit") and col.other.hit ~= nil then
					col.other:hit(col.sprite.obj)
				elseif col.other.type == "balloon" and col.other.hit ~= nil then
					col.other:hit(col.sprite.obj)
				end
			end
		end

		local input = btn(k_right) and 1 or (btn(k_left) and -1 or 0)

		-- bottom death
		if this.y>128 then
			kill_player(this)
		end

		-- ground and ice collisions
		local on_ground=false
		local on_ice=false
		local _, _, collisions_at_0_1, length = this.pdspr:checkCollisions(kDrawOffsetX+this.x+0, kDrawOffsetY+this.y+1)
		if length > 0 then
			for _, col in ipairs(collisions_at_0_1) do
				if col.spriteRect.y + col.spriteRect.height <= col.otherRect.y then
					if col.other.class == "solid" then
						on_ground=true
					end
					if col.other.type == "ice" then
						on_ice=true
					end
				end
			end
		end

		-- smoke particles
		if on_ground and not this.was_on_ground then
			init_object(smoke,this.x,this.y+4)
		end

		local jump = btn(k_jump) and not this.p_jump
		this.p_jump = btn(k_jump)
		if (jump) then
			this.jbuffer=4
		elseif this.jbuffer>0 then
			this.jbuffer-=1
		end

		local dash = btn(k_dash) and not this.p_dash
		this.p_dash = btn(k_dash)

		if on_ground then
			this.grace=6
			if this.djump<max_djump then
				psfx(54)
				this.djump=max_djump
			end
		elseif this.grace > 0 then
			this.grace-=1
		end

		this.dash_effect_time -=1
		if this.dash_time > 0 then
			init_object(smoke,this.x,this.y)
			this.dash_time-=1
			this.spd.x=appr(this.spd.x,this.dash_target.x,this.dash_accel.x)
			this.spd.y=appr(this.spd.y,this.dash_target.y,this.dash_accel.y)
		else
			-- move
			local maxrun=1
			local accel=0.6
			local deccel=0.15

			if not on_ground then
				accel=0.4
			elseif on_ice then
				accel=0.05
				if input==(this.flip.x and -1 or 1) then
					accel=0.05
				end
			end

			if abs(this.spd.x) > maxrun then
				this.spd.x=appr(this.spd.x,sign(this.spd.x)*maxrun,deccel)
			else
				this.spd.x=appr(this.spd.x,input*maxrun,accel)
			end

			--facing
			if this.spd.x~=0 then
				this.flip.x=(this.spd.x<0)
			end

			-- gravity
			local maxfall=2
			local gravity=0.21

			if abs(this.spd.y) <= 0.15 then
				gravity*=0.5
			end

			-- wall slide
			local is_solid_at_input_0=false
			local _, _, collisions_at_input_0, length = this.pdspr:checkCollisions(kDrawOffsetX+this.x+input, kDrawOffsetY+this.y+0)
			if length > 0 then
				for _, col in ipairs(collisions_at_input_0) do
					if col.other.class == "solid" then
						is_solid_at_input_0=true
					end
				end
			end
			-- if input~=0 and this.is_solid(input,0) and not this.is_ice(input,0) then
			if input~=0 and is_solid_at_input_0 then
				maxfall=0.4
				if rnd(10)<2 then
					init_object(smoke,this.x+input*6,this.y)
				end
			end

			if not on_ground then
				this.spd.y=appr(this.spd.y,maxfall,gravity)
			end

			-- jump
			if this.jbuffer>0 then
				if this.grace>0 then
					-- normal jump
					psfx(1)
					this.jbuffer=0
					this.grace=0
					this.spd.y=-2
					init_object(smoke,this.x,this.y+4)
				else
					-- wall jump
					local wall_dir=0
					local _, _, collisions_at_m3_0, length = this.pdspr:checkCollisions(kDrawOffsetX+this.x-3, kDrawOffsetY+this.y+0)
					if length > 0 then
						for _, col in ipairs(collisions_at_m3_0) do
							if col.other.class == "solid" then
								wall_dir=-1
							end
						end
					end
					local _, _, collisions_at_3_0, length = this.pdspr:checkCollisions(kDrawOffsetX+this.x+3, kDrawOffsetY+this.y+0)
					if length > 0 then
						for _, col in ipairs(collisions_at_3_0) do
							if col.other.class == "solid" then
								wall_dir=1
							end
						end
					end
					-- local wall_dir=(this.is_solid(-3,0) and -1 or this.is_solid(3,0) and 1 or 0)
					if wall_dir~=0 then
						psfx(2)
						this.jbuffer=0
						this.spd.y=-2
						this.spd.x=-wall_dir*(maxrun+1)
						if not this.is_ice(wall_dir*3,0) then
							init_object(smoke,this.x+wall_dir*6,this.y)
						end
					end
				end
			end

			-- dash
			local d_full=5
			local d_half=d_full*0.70710678118

			if this.djump>0 and dash then
				init_object(smoke,this.x,this.y)
				this.djump-=1
				this.dash_time=4
				has_dashed=true
				this.dash_effect_time=10
				local v_input=(btn(k_up) and -1 or (btn(k_down) and 1 or 0))
				if input~=0 then
					if v_input~=0 then
					   this.spd.x=input*d_half
					   this.spd.y=v_input*d_half
					else
					   this.spd.x=input*d_full
					   this.spd.y=0
					end
				elseif v_input~=0 then
					this.spd.x=0
					this.spd.y=v_input*d_full
				else
					this.spd.x=(this.flip.x and -1 or 1)
					this.spd.y=0
				end

				psfx(3)
				freeze=2
				shake=6
				this.dash_target.x=2*sign(this.spd.x)
				this.dash_target.y=2*sign(this.spd.y)
				this.dash_accel.x=1.5
				this.dash_accel.y=1.5

				if this.spd.y<0 then
					this.dash_target.y*=.75
				end

				if this.spd.y~=0 then
					this.dash_accel.x*=0.70710678118
				end
				if this.spd.x~=0 then
					this.dash_accel.y*=0.70710678118
				end
			elseif dash and this.djump<=0 then
				psfx(9)
				init_object(smoke,this.x,this.y)
			end
		end

		-- animation
		this.spr_off+=0.25
		if not on_ground then
			if is_solid_at_input_0 then
				this.spr=5
			else
				this.spr=3
			end
		elseif btn(k_down) then
			this.spr=6
		elseif btn(k_up) then
			this.spr=7
		elseif (this.spd.x==0) or (not btn(k_left) and not btn(k_right)) then
			this.spr=1
		else
			this.spr=1+this.spr_off%4
		end

		 -- next level
		if this.y<-4 and level_index()<30 then
			this.y = 0
			this.x = 0
			next_room()
		end

		-- was on the ground
		this.was_on_ground=on_ground

	end, --<end update loop

	draw=function(this)

		-- clamp in screen
		if this.x<-1 or this.x>121 then
			this.x=clamp(this.x,-1,121)
			this.spd.x=0
		end

		-- Playdate sprite drawing
		if this.pdspr ~= nil then
			local pdimg <const> = data.imagetables.player:getImage(flr(this.spr))
			pdimg:setInverted(this.djump == 0)
			this.pdspr:setImage(pdimg, flip(this.flip.x,this.flip.y))
			this.pdspr:moveTo(kDrawOffsetX + this.x - 1, kDrawOffsetY + this.y - 1)
		end

		set_hair_color(this.djump)
		draw_hair(this,this.flip.x and -1 or 1)
		unset_hair_color()
	end,
}

psfx=function(num)
	if sfx_timer<=0 then
		sfx(num)
	end
end

create_hair=function(obj)
	obj.hair={}
	for i=0,4 do
		add(obj.hair,{x=obj.x,y=obj.y,size=max(1,min(2,3-i))})
	end
end

set_hair_color=function(djump)
	if djump ~= 0 then
		hair_color = playdate.graphics.kColorBlack
	else
		hair_color = playdate.graphics.kColorWhite
	end

end

draw_hair=function(obj,facing)
	local last={x=obj.x+4-facing*2,y=obj.y+(btn(k_down) and 4 or 3)}
	local coords={}
	foreach(obj.hair,function(h)
		h.x+=(last.x-h.x)/1.5
		h.y+=(last.y+0.5-h.y)/1.5
		add(coords,{x=h.x,y=h.y,s=h.size})
		last=h
	end)
	-- Playdate sprite drawing
	local x1 = 128
	local x2 = 0
	local y1 = 128
	local y2 = 0
	foreach(coords,function(c)
		x1 = math.min(x1, c.x - c.s)
		x2 = math.max(x2, c.x + c.s)
		y1 = math.min(y1, c.y - c.s)
		y2 = math.max(y2, c.y + c.s)
	end)
	x1 = clamp(x1, 0, 128) - 1
	x2 = clamp(x2, 0, 128) + 1
	y1 = clamp(y1, 0, 128) - 1
	y2 = clamp(y2, 0, 128) + 1
	local w <const> = x2 - x1
	local h <const> = y2 - y1
	layers.hair:setSize(w, h)
	layers.hair:setCenter(0, 0)
	layers.hair:moveTo(x1 + kDrawOffsetX, y1 + kDrawOffsetY)
	local pdimg <const> = playdate.graphics.image.new(w, h, playdate.graphics.kColorClear)
	playdate.graphics.pushContext(pdimg)
		-- Draw outline of hair
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		playdate.graphics.setLineWidth(1)
		playdate.graphics.setStrokeLocation(playdate.graphics.kStrokeOutside)
		foreach(coords,function(c)
			playdate.graphics.drawCircleAtPoint(c.x - x1, c.y - y1, c.s)
		end)
		-- Draw fill of hair
		playdate.graphics.setColor(hair_color)
		foreach(coords,function(c)
			playdate.graphics.fillCircleAtPoint(c.x - x1, c.y - y1, c.s)
		end)
	playdate.graphics.popContext()
	layers.hair:setImage(pdimg)
end

unset_hair_color=function()
	hair_color = playdate.graphics.kColorBlack
end

player_spawn = {
	tile=1,
	init=function(this)
		sfx(4)
		this.spr=3
		this.target= {x=this.x,y=this.y}
		this.y=128
		this.spd.y=-4
		this.state=0
		this.delay=0
		this.solids=false
		create_hair(this)
		if this.pdspr ~= nil then
			this.pdspr.type = "player_spawn"
			this.pdspr:setZIndex(20)
			this.pdspr:clearCollideRect()
		end
	end,
	update=function(this)
		-- jumping up
		if this.state==0 then
			if this.y < this.target.y+16 then
				this.state=1
				this.delay=3
			end
		-- falling
		elseif this.state==1 then
			this.spd.y+=0.5
			if this.spd.y>0 and this.delay>0 then
				this.spd.y=0
				this.delay-=1
			end
			if this.spd.y>0 and this.y > this.target.y then
				this.y=this.target.y
				this.spd = {x=0,y=0}
				this.state=2
				this.delay=5
				shake=5
				init_object(smoke,this.x,this.y+4)
				sfx(5)
			end
		-- landing
		elseif this.state==2 then
			this.delay-=1
			this.spr=6
			if this.delay<0 then
				destroy_object(this)
				init_object(player,this.x,this.y)
			end
		end
	end,
	draw=function(this)
		if this.pdspr ~= nil then
			local pdimg <const> = data.imagetables.player:getImage(flr(this.spr))
			pdimg:setInverted(max_djump == 0)
			this.pdspr:setImage(pdimg, flip(this.flip.x,this.flip.y))
			this.pdspr:moveTo(kDrawOffsetX + this.x - 1, kDrawOffsetY + this.y - 1)
		end

		set_hair_color(max_djump)
		draw_hair(this,1)
		unset_hair_color()
	end
}
add(types,player_spawn)

spring = {
	tile=18,
	init=function(this)
		this.hide_in=0
		this.hide_for=0
		if this.pdspr ~= nil then
			this.pdspr.type = "spring"
		end
	end,
	update=function(this)
		if this.hide_for>0 then
			this.hide_for-=1
			if this.hide_for<=0 then
				this.spr=18
				this.delay=0
			end
		elseif this.spr==18 then
			local hit = this.collide(player,0,0)
			if hit ~=nil and hit.spd.y>=0 then
				this.spr=19
				hit.y=this.y-4
				hit.spd.x*=0.2
				hit.spd.y=-3
				hit.djump=max_djump
				this.delay=10
				init_object(smoke,this.x,this.y)

				-- breakable below us
				local below=this.collide(fall_floor,0,1)
				if below~=nil then
					break_fall_floor(below)
				end

				psfx(8)
			end
		elseif this.delay>0 then
			this.delay-=1
			if this.delay<=0 then
				this.spr=18
			end
		end
		-- begin hiding
		if this.hide_in>0 then
			this.hide_in-=1
			if this.hide_in<=0 then
				this.hide_for=60
				this.spr=0
			end
		end
	end,
	draw=function(this)
		if this.pdspr ~= nil then
			local pdimg <const> = data.imagetables.tiles:getImage(flr(this.spr) + 1)
			this.pdspr:setImage(pdimg)
			this.pdspr:moveTo(kDrawOffsetX + this.x, kDrawOffsetY + this.y)
		end
	end
}
add(types,spring)

function break_spring(obj)
	obj.hide_in=15
end

balloon = {
	tile=22,
	init=function(this)
		this.offset=rnd(1)
		this.start=this.y
		this.timer=0
		this.hitbox={x=-1,y=-1,w=10,h=10}
		if this.pdspr ~= nil then
			this.pdspr.type="balloon"
			local pdimg <const> = playdate.graphics.image.new(10, 17, playdate.graphics.kColorClear)
			playdate.graphics.pushContext(pdimg)
				local pdtileballoon = data.imagetables.balloon:getImage(1)
				local pdtilestring = data.imagetables.balloon:getImage(flr(2+(this.offset*8)%3))
				pdtileballoon:draw(0,0)
				pdtilestring:draw(0,8)
			playdate.graphics.popContext()
			this.pdspr:setImage(pdimg)
			this.pdspr:setGroups({4})
			this.pdspr:setZIndex(20)
			this.pdspr:setCollideRect(this.hitbox.x+1, this.hitbox.y+1, this.hitbox.w, this.hitbox.h)
			this.pdspr.hit=function(arg)
				if arg~=nil and arg.djump~=nil and arg.djump<max_djump then
					psfx(6)
					init_object(smoke,this.x,this.y)
					arg.djump=max_djump
					this.spr=0
					this.timer=60
				end
			end
		end
	end,
	update=function(this)
		if this.spr==22 then
			this.offset+=0.01
			this.y=this.start+sin(this.offset)*2
		elseif this.timer>0 then
			this.timer-=1
		else
			psfx(7)
			init_object(smoke,this.x,this.y)
			this.spr=22
		end
	end,
	draw=function(this)
		if this.spr==22 then
			local function drawBalloon(img)
				playdate.graphics.pushContext(img)
					playdate.graphics.clear(playdate.graphics.kColorClear)
					local pdtilestring = data.imagetables.balloon:getImage(flr(2+(this.offset*8)%3))
					local pdtileballoon = data.imagetables.balloon:getImage(1)
					pdtileballoon:draw(0,0)
					pdtilestring:draw(0,8)
				playdate.graphics.popContext()
			end
			if this.pdspr ~= nil then
				local pdimg <const> = this.pdspr:getImage()
				drawBalloon(pdimg)
				this.pdspr:setImage(pdimg)
				this.pdspr:add()
			end
			this.pdspr:moveTo(kDrawOffsetX + this.x - 1, kDrawOffsetY + this.y - 1)
		else
			this.pdspr:remove()
		end
	end
}
add(types,balloon)

fall_floor = {
	tile=23,
	init=function(this)
		this.state=0
		this.solid=true
		if this.pdspr ~= nil then
			this.pdspr.class = "solid"
			this.pdspr.type = "fall_floor"
			this.pdspr:setZIndex(20)
			this.pdspr:setGroups({3})
			this.pdspr.collisionResponse=function(other)
				return playdate.graphics.sprite.kCollisionTypeOverlap
			end
		end
	end,
	update=function(this)
		-- shaking
		if this.state==1 then
			this.delay-=1
			if this.delay<=0 then
				this.state=2
				this.delay=60--how long it hides for
				this.collideable=false
				this.pdspr:setCollisionsEnabled(false)
			end
		-- invisible, waiting to reset
		elseif this.state==2 then
			this.delay-=1
			if this.delay<=0 and not this.check(player,0,0) then
				psfx(7)
				this.state=0
				this.collideable=true
				this.pdspr:setCollisionsEnabled(true)
				init_object(smoke,this.x,this.y)
			end
		end
	end,
	draw=function(this)
		local spr_index = 0
		if this.state~=2 then
			if this.state~=1 then
				spr_index = 24
			else
				spr_index = 24+(15-this.delay)/5
			end
		end
		if this.pdspr ~= nil then
			local pdimg <const> = data.imagetables.tiles:getImage(flr(spr_index))
			this.pdspr:setImage(pdimg)
			this.pdspr:moveTo(kDrawOffsetX + this.x, kDrawOffsetY + this.y)
		end
	end
}
add(types,fall_floor)

function break_fall_floor(obj)
	if obj.state==0 then
		psfx(15)
		obj.state=1
		obj.delay=15--how long until it falls
		init_object(smoke,obj.x,obj.y)
		local hit=obj.collide("spring",0,-1)
		if hit~=nil then
			break_spring(hit)
		end
	end
end

smoke={
	init=function(this)
		this.spr=29
		this.spd.y=-0.1
		this.spd.x=0.3+rnd(0.2)
		this.x+=-1+rnd(2)
		this.y+=-1+rnd(2)
		this.flip.x=maybe()
		this.flip.y=maybe()
		this.solids=false
	end,
	update=function(this)
		this.spr+=0.2
		if this.spr>=32 then
			destroy_object(this)
		end
	end,
	draw=function(this)
		local pdimg <const> = data.imagetables.tiles:getImage(flr(this.spr)+1)
		if not this.pdspr then
			this.pdspr = playdate.graphics.sprite.new()
			this.pdspr:setCenter(0,0)
			this.pdspr:setZIndex(20)
			this.pdspr:add()
		end
		this.pdspr:setImage(pdimg, flip(this.flip.x, this.flip.y))
		this.pdspr:moveTo(kDrawOffsetX + this.x, kDrawOffsetY + this.y)
	end
}

fruit={
	tile=26,
	if_not_fruit=true,
	init=function(this)
		this.start=this.y
		this.off=0
		if this.pdspr ~= nil then
			local pdimg <const> = data.imagetables.fruit:getImage(1)
			this.pdspr:setImage(pdimg)
			this.pdspr.type="fruit"
			this.pdspr:setGroups({4})
			this.pdspr:setZIndex(20)
			this.pdspr:setCollideRect(this.hitbox.x+1,this.hitbox.y+1,this.hitbox.w,this.hitbox.h)
			this.pdspr.hit=function(player)
				-- collect
				if player~=nil then
					player.djump=max_djump
					sfx_timer=20
					sfx(13)
					got_fruit[1+level_index()] = true
					init_object(lifeup,this.x,this.y)
					destroy_object(this)
				end
			end
		end
	end,
	update=function(this)
		this.off+=1
		this.y=this.start+sin(this.off/40)*2.5
	end,
	draw=function(this)
		if this.pdspr ~= nil then
			this.pdspr:moveTo(kDrawOffsetX + this.x - 1, kDrawOffsetY + this.y - 1)
		end
	end
}
add(types,fruit)

fly_fruit={
	tile=28,
	if_not_fruit=true,
	init=function(this)
		this.start=this.y
		this.fly=false
		this.step=0.5
		this.solids=false
		this.sfx_delay=8
		if this.pdspr ~= nil then
			this.pdspr.type="fly_fruit"
			this.pdspr:setZIndex(20)
			this.pdspr:setCollideRect(this.hitbox.x+11, this.hitbox.y+1, this.hitbox.w, this.hitbox.h)
			this.pdspr:setGroups({4})
			this.pdspr.hit=function(player)
				-- collect
				if player~=nil then
					player.djump=max_djump
					sfx_timer=20
					sfx(13)
					got_fruit[1+level_index()] = true
					init_object(lifeup,this.x,this.y)
					destroy_object(this)
				end
			end
		end
	end,
	update=function(this)
		--fly away
		if this.fly then
			if this.sfx_delay>0 then
				this.sfx_delay-=1
				if this.sfx_delay<=0 then
					sfx_timer=20
					sfx(14)
				end
			end
			this.spd.y=appr(this.spd.y,-3.5,0.25)
			if this.y<-16 then
				destroy_object(this)
			end
		-- wait
		else
			if has_dashed then
				this.fly=true
			end
			this.step+=0.05
			this.spd.y=sin(this.step)*0.5
		end
	end,
	draw=function(this)
		local off=0
		if not this.fly then
			local dir=sin(this.step)
			if dir<0 then
				off=1+max(0,sign(this.y-this.start))
			end
		else
			off=(off+0.25)%3
		end
		local drawFruit=function(img)
			playdate.graphics.pushContext(img)
				playdate.graphics.clear(playdate.graphics.kColorClear)
				local pdtilewing = data.imagetables.fruit:getImage(flr(3+off))
				local pdtilefruit = data.imagetables.fruit:getImage(2)
				pdtilewing:draw(4,-1,flip(true, false))
				pdtilewing:draw(16,-1)
				pdtilefruit:draw(10,0)
			playdate.graphics.popContext()
		end
		if this.pdspr ~= nil then
			local pdimg <const> = playdate.graphics.image.new(30, 10)
			drawFruit(pdimg)
			this.pdspr:setImage(pdimg)
			this.pdspr:moveTo(kDrawOffsetX + this.x - 11, kDrawOffsetY + this.y - 1)
		end
	end
}
add(types,fly_fruit)

lifeup = {
	init=function(this)
		this.spd.y=-0.25
		this.duration=30
		this.x-=2
		this.y-=4
		this.flash=0
		this.solids=false
	end,
	update=function(this)
		this.duration-=1
		if this.duration<= 0 then
			destroy_object(this)
		end
	end,
	draw=function(this)
		this.flash+=0.5

		if not this.pdspr then
			local pdimg <const> = playdate.graphics.image.new(64, 24)
			playdate.graphics.pushContext(pdimg)
				_print("1000",0,0,7+this.flash%2)
			playdate.graphics.popContext()
			this.pdspr = playdate.graphics.sprite.new(pdimg)
			this.pdspr:setCenter(0,0)
			this.pdspr:setZIndex(20)
			this.pdspr:add()
		end
		this.pdspr:moveTo(kDrawOffsetX + this.x-2, kDrawOffsetY + this.y)
	end
}

fake_wall = {
	tile=64,
	if_not_fruit=true,
	init=function(this)
		this.hitbox={x=0,y=0,w=16,h=16}
		if this.pdspr ~= nil then
			local pdimg <const> = playdate.graphics.image.new(16, 16)
			playdate.graphics.pushContext(pdimg)
				local pdtile = data.imagetables.tiles:getImage(64 + 1)
				pdtile:draw(0,0)
				pdtile = data.imagetables.tiles:getImage(65 + 1)
				pdtile:draw(8,0)
				pdtile = data.imagetables.tiles:getImage(80 + 1)
				pdtile:draw(0,8)
				pdtile = data.imagetables.tiles:getImage(81 + 1)
				pdtile:draw(8,8)
			playdate.graphics.popContext()
			this.pdspr:setImage(pdimg)
			this.pdspr:setZIndex(20)
			this.pdspr:setCollideRect(this.hitbox.x, this.hitbox.y, this.hitbox.w, this.hitbox.h)
		end
	end,
	update=function(this)
		this.hitbox={x=-1,y=-1,w=18,h=18}
		local hit = this.collide(player,0,0)
		if hit~=nil and hit.dash_effect_time>0 then
			hit.spd.x=-sign(hit.spd.x)*1.5
			hit.spd.y=-1.5
			hit.dash_time=-1
			sfx_timer=20
			sfx(16)
			destroy_object(this)
			init_object(smoke,this.x,this.y)
			init_object(smoke,this.x+8,this.y)
			init_object(smoke,this.x,this.y+8)
			init_object(smoke,this.x+8,this.y+8)
			init_object(fruit,this.x+4,this.y+4)
		end
		this.hitbox={x=0,y=0,w=16,h=16}
	end,
	draw=function(this)
		if this.pdspr ~= nil then
			this.pdspr:moveTo(kDrawOffsetX + this.x, kDrawOffsetY + this.y)
		end
	end
}
add(types,fake_wall)

key={
	tile=8,
	if_not_fruit=true,
	update=function(this)
		local was=flr(this.spr)
		this.spr=9+(sin(frames/30)+0.5)*1
		local is=flr(this.spr)
		if is==10 and is~=was then
			this.flip.x=not this.flip.x
		end
		if this.check(player,0,0) then
			sfx(23)
			sfx_timer=10
			destroy_object(this)
			has_key=true
		end
	end,
	draw=function(this)
		local pdimg <const> = data.imagetables.key:getImage(flr(this.spr) - 7)
		if not this.pdspr then
			this.pdspr = playdate.graphics.sprite.new(pdimg)
			this.pdspr:setCenter(0,0)
			this.pdspr:setZIndex(20)
			this.pdspr:add()
		end
		this.pdspr:setImage(pdimg, flip(this.flip.x,this.flip.y))
		this.pdspr:moveTo(kDrawOffsetX + this.x - 1, kDrawOffsetY + this.y - 1)
	end
}
add(types,key)

chest={
	tile=20,
	if_not_fruit=true,
	init=function(this)
		if this.x == 120 then
			this.x = 116
		end
		this.x-=1
		this.start=this.x
		this.timer=20
	end,
	update=function(this)
		if has_key then
			this.timer-=1
			this.x=this.start-1+rnd(3)
			if this.timer<=0 then
				sfx_timer=20
				sfx(16)
				init_object(fruit,this.x,this.y-4)
				destroy_object(this)
			end
		end
	end,
	draw=function(this)
		local pdimg <const> = data.imagetables.chest
		if not this.pdspr then
			this.pdspr = playdate.graphics.sprite.new(pdimg)
			this.pdspr:setCenter(0,0)
			this.pdspr:setZIndex(20)
			this.pdspr:add()
		end
		this.pdspr:setImage(pdimg)
		this.pdspr:moveTo(kDrawOffsetX + this.x, kDrawOffsetY + this.y)
	end
}
add(types,chest)

platform={
	init=function(this)
		this.x-=4
		this.solids=false
		this.hitbox.w=16
		this.last=this.x
	end,
	update=function(this)
		this.spd.x=this.dir*0.65
		if this.x<-16 then
			this.x=128
		elseif this.x>128 then
			this.x=-16
		end
		if not this.check(player,0,0) then
			local hit=this.collide(player,0,-1)
			if hit~=nil then
				hit.move_x(this.x-this.last,1)
			end
		end
		this.last=this.x
	end,
	draw=function(this)
		local pdimg <const> = data.imagetables.platform
		if not this.pdspr then
			this.pdspr = playdate.graphics.sprite.new(pdimg)
			this.pdspr:setCenter(0,0)
			this.pdspr:setZIndex(20)
			this.pdspr:add()
		end
		this.pdspr:setImage(pdimg)
		this.pdspr:moveTo(kDrawOffsetX + this.x-1, kDrawOffsetY + this.y-2)
	end
}

message={
	tile=86,
	last=0,
	draw=function(this)
		this.text="-- celeste mountain --#this memorial to those# perished on the climb"
		if this.check(player,4,0) then
			if this.index<#this.text then
			 this.index+=0.5
				if this.index>=this.last+1 then
					this.last+=1
					sfx(35)
				end
			end
			this.off={x=2,y=2}
			local pdimg <const> = playdate.graphics.image.new(115, 23)
			if not this.pdspr then
				this.pdspr = playdate.graphics.sprite.new(pdimg)
				this.pdspr:setCenter(0,0)
				this.pdspr:setZIndex(20)
			end
			playdate.graphics.pushContext(pdimg)
				for i=1,this.index do
					if sub(this.text,i,i)~="#" then
						rectfill(this.off.x-2,this.off.y-2,this.off.x+7,this.off.y+6,7)
						_print(sub(this.text,i,i),this.off.x,this.off.y,0)
						this.off.x+=5
					else
						this.off.x=2
						this.off.y+=7
					end
				end
			playdate.graphics.popContext()
			this.pdspr:setImage(pdimg)
			this.pdspr:moveTo(kDrawOffsetX + 6, kDrawOffsetY + 94)
			this.pdspr:add()
		else
			if this.pdspr ~= nil then
				this.pdspr:remove()
			end
			this.index=0
			this.last=0
		end
	end
}
add(types,message)

big_chest={
	tile=96,
	init=function(this)
		this.state=0
		this.hitbox.w=16
	end,
	draw=function(this)
		local pdimg <const> = playdate.graphics.image.new(18, 16, playdate.graphics.kColorClear)
		if not this.pdspr then
			this.pdspr = playdate.graphics.sprite.new(pdimg)
			this.pdspr:setCenter(0,0)
			this.pdspr:setZIndex(20)
		end
		if this.state==0 then
			local hit=this.collide(player,0,8)
			if hit~=nil and hit.is_solid(0,1) then
				music(-1,500,7)
				sfx(37)
				pause_player=true
				hit.spd.x=0
				hit.spd.y=0
				this.state=1
				init_object(smoke,this.x,this.y)
				init_object(smoke,this.x+8,this.y)
				this.timer=60
				this.particles={}
			end
			playdate.graphics.pushContext(pdimg)
				local pdtile = data.imagetables.big_chest:getImage(1)
				pdtile:draw(0,0)
			playdate.graphics.popContext()
		elseif this.state==1 then
			this.timer-=1
			shake=5
			flash_bg=true
			if this.timer<=45 and #this.particles<50 then
				add(this.particles,{
					x=1+rnd(14),
					y=0,
					h=32+rnd(32),
					spd=8+rnd(8)
				})
			end
			if this.timer<0 then
				this.state=2
				this.particles={}
				flash_bg=false
				new_bg=true
				init_object(orb,this.x+4,this.y+4)
				pause_player=false
			end
			foreach(this.particles,function(p)
				p.y+=p.spd
				line(this.x+p.x,this.y+8-p.y,this.x+p.x,min(this.y+8-p.y+p.h,this.y+8),7)
			end)
		end
		if this.state~=0 then
			playdate.graphics.pushContext(pdimg)
				local pdtile = data.imagetables.big_chest:getImage(2)
				pdtile:draw(0,0)
			playdate.graphics.popContext()
		end
		this.pdspr:setImage(pdimg)
		this.pdspr:moveTo(kDrawOffsetX + this.x-1, kDrawOffsetY + this.y)
		this.pdspr:add()
	end
}
add(types,big_chest)

tree={
	tile=44,
	init=function(this)
		if this.pdspr ~= nil then
			local pdimg <const> = data.imagetables.tree
			this.pdspr:setImage(pdimg)
			this.pdspr:setZIndex(20)
			this.pdspr:clearCollideRect()
			this.pdspr:moveTo(kDrawOffsetX + this.x-1, kDrawOffsetY + this.y -1)
		end
	end,
	draw=function(this)
	end,
}
add(types,tree)

orb={
	init=function(this)
		this.spd.y=-4
		this.solids=false
		this.particles={}
	end,
	draw=function(this)
		this.spd.y=appr(this.spd.y,0,0.5)
		local hit=this.collide(player,0,0)
		if this.spd.y==0 and hit~=nil then
			music_timer=45
			sfx(51)
			freeze=10
			shake=10
			destroy_object(this)
			max_djump=2
			hit.djump=2
		end
		local pdimg <const> = playdate.graphics.image.new(8, 8, playdate.graphics.kColorClear)
		if not this.pdspr then
			playdate.graphics.pushContext(pdimg)
				local pdtile = data.imagetables.tiles:getImage(103)
				pdtile:draw(0,0)
			playdate.graphics.popContext()
			this.pdspr = playdate.graphics.sprite.new(pdimg)
			this.pdspr:setCenter(0,0)
			this.pdspr:setZIndex(20)
			this.pdspr:add()
		end
		this.pdspr:moveTo(kDrawOffsetX + this.x,kDrawOffsetY + this.y)
		local off=frames/30
		for i=0,7 do
			circfill(this.x+4+cos(off+i/8)*8,this.y+4+sin(off+i/8)*8,1,7)
		end
	end
}

flag = {
	tile=118,
	init=function(this)
		this.x+=5
		this.score=0
		this.show=false
		for i=1,#got_fruit do
			if got_fruit[i] then
				this.score+=1
			end
		end
	end,
	draw=function(this)
		this.spr=118+(frames/5)%3
		if not this.show then
			if layers.time ~= nil then
				layers.time:remove()
			end
			if layers.score ~= nil then
				layers.score:remove()
			end
		end
		if this.show then
			if not layers.score then
				local pdimg = playdate.graphics.image.new(64, 29)
				playdate.graphics.pushContext(pdimg)
					playdate.graphics.setColor(playdate.graphics.kColorBlack)
					playdate.graphics.fillRect(0, 0, 64, 29)
					local fruit = data.imagetables.fruit:getImage(1)
					fruit:draw(22, 3)
					_print("x"..this.score,32,7,7)
					_print(get_time(),17,15)
					_print("deaths:"..deaths,16,22,7)
				playdate.graphics.popContext()
				layers.score = playdate.graphics.sprite.new(pdimg)
				layers.score:setCenter(0,0)
				layers.score:setZIndex(20)
				layers.score:moveTo(kDrawOffsetX + 32, 2)
				layers.score:add()
			end
		elseif this.check(player,0,0) then
			sfx(55)
			sfx_timer=30
			this.show=true
		end
		local pdimg <const> = data.imagetables.flag:getImage(flr(this.spr) - 117)
		if not this.pdspr then
			this.pdspr = playdate.graphics.sprite.new(pdimg)
			this.pdspr:setCenter(0,0)
			this.pdspr:setZIndex(20)
			this.pdspr:add()
		end
		this.pdspr:setImage(pdimg)
		this.pdspr:moveTo(kDrawOffsetX + this.x - 1, kDrawOffsetY + this.y - 1)
	end
}
add(types,flag)

room_title = {
	init=function(this)
		this.delay=5
	end,
	draw=function(this)
		this.delay-=1
		if this.delay<-30 then
			destroy_object(this)
			layers.time:remove()
		elseif this.delay<0 then
			local pdimg <const> = playdate.graphics.image.new(80, 12)
			playdate.graphics.pushContext(pdimg)
				playdate.graphics.setColor(playdate.graphics.kColorWhite)
				playdate.graphics.fillRect(0, 0, 80, 12)
				playdate.graphics.drawRect(0, 0, 80, 12)
				if room.x==3 and room.y==1 then
					_print("old site",24,4,0)
				elseif level_index()==30 then
					_print("summit",28,4,0)
				else
					local level=(1+level_index())*100
					_print(level.." m",28+(level<1000 and 2 or 0),4,0)
				end
			playdate.graphics.popContext()
			if not this.pdspr then
				this.pdspr = playdate.graphics.sprite.new(pdimg)
				this.pdspr:setCenter(0,0)
				this.pdspr:setZIndex(20)
				this.pdspr:add()
			end
			this.pdspr:setImage(pdimg)
			this.pdspr:moveTo(kDrawOffsetX + 24, kDrawOffsetY + 58)

			draw_time(4,8)
		end
	end
}

-- object functions --
-----------------------

function init_object(type,x,y)

	if type.if_not_fruit~=nil and got_fruit[1+level_index()] then
		return
	end
	local obj = {}
	obj.type = type
	obj.collideable=true
	obj.solids=true

	obj.spr = type.tile
	obj.flip = {x=false,y=false}

	obj.x = x
	obj.y = y
	obj.hitbox = { x=0,y=0,w=8,h=8 }

	if obj.spr ~= nil then
		local pdimg <const> = data.imagetables.tiles:getImage(math.floor(obj.spr) + 1)
		obj.pdspr = playdate.graphics.sprite.new()
		obj.pdspr.obj = obj
		obj.pdspr:setCenter(0,0)
		obj.pdspr:setImage(pdimg, flip(obj.flip.x,obj.flip.y))
		obj.pdspr:setCollideRect(obj.hitbox.x, obj.hitbox.y, obj.hitbox.w, obj.hitbox.h)
		obj.pdspr:add()
	end

	obj.spd = {x=0,y=0}
	obj.rem = {x=0,y=0}

	obj.is_solid=function(ox,oy)
		if oy>0 and not obj.check(platform,ox,0) and obj.check(platform,ox,oy) then
			return true
		end
		return solid_at(obj.x+obj.hitbox.x+ox,obj.y+obj.hitbox.y+oy,obj.hitbox.w,obj.hitbox.h)
			or obj.check(fall_floor,ox,oy)
			or obj.check(fake_wall,ox,oy)
	end

	obj.is_ice=function(ox,oy)
		return ice_at(obj.x+obj.hitbox.x+ox,obj.y+obj.hitbox.y+oy,obj.hitbox.w,obj.hitbox.h)
	end

	obj.collide=function(type,ox,oy)
		local other
		for i=1,#objects do
			other=objects[i]
			if other ~=nil and other.type == type and other ~= obj and other.collideable and
				other.x+other.hitbox.x+other.hitbox.w > obj.x+obj.hitbox.x+ox and 
				other.y+other.hitbox.y+other.hitbox.h > obj.y+obj.hitbox.y+oy and
				other.x+other.hitbox.x < obj.x+obj.hitbox.x+obj.hitbox.w+ox and 
				other.y+other.hitbox.y < obj.y+obj.hitbox.y+obj.hitbox.h+oy then
				return other
			end
		end
		return nil
	end

	obj.check=function(type,ox,oy)
		return obj.collide(type,ox,oy) ~= nil
	end

	obj.move=function(ox,oy)
		local amount
		-- [x] get move amount
		obj.rem.x += ox
		amount = flr(obj.rem.x + 0.5)
		obj.rem.x -= amount
		obj.move_x(amount,0)

		-- [y] get move amount
		obj.rem.y += oy
		amount = flr(obj.rem.y + 0.5)
		obj.rem.y -= amount
		obj.move_y(amount)
	end

	obj.move_x=function(amount,start)
		if obj.solids then
			local step = sign(amount)
			for i=start,abs(amount) do
				if not obj.is_solid(step,0) then
					obj.x += step
				else
					obj.spd.x = 0
					obj.rem.x = 0
					break
				end
			end
		else
			obj.x += amount
		end
	end

	obj.move_y=function(amount)
		if obj.solids then
			local step = sign(amount)
			for i=0,abs(amount) do
			 if not obj.is_solid(0,step) then
					obj.y += step
				else
					obj.spd.y = 0
					obj.rem.y = 0
					break
				end
			end
		else
			obj.y += amount
		end
	end

	add(objects,obj)
	if obj.type.init~=nil then
		obj.type.init(obj)
	end
	return obj

end

function destroy_object(obj)
	if obj.pdspr ~= nil then
		obj.pdspr:remove()
	end
	del(objects,obj)
end

function kill_player(obj)
	sfx_timer=12
	sfx(0)
	deaths+=1
	shake=10
	destroy_object(obj)
	drawInLayer("hair", function(img)
		img:clear(playdate.graphics.kColorClear)
	end)
	layers["hair"]:markDirty()
	dead_particles={}
	for dir=0,7 do
		local angle=(dir/8)
		add(dead_particles,{
			x=obj.x+4,
			y=min(obj.y+4, 120),
			t=10,
			spd={
				x=sin(angle)*3,
				y=cos(angle)*3
			}
		})
		for i, item in ipairs(dead_particles) do
			local img <const> = playdate.graphics.image.new(item.t, item.t, playdate.graphics.kColorWhite)
			item.spr = playdate.graphics.sprite.new(img)
			item.spr:setZIndex(30)
			item.spr:add()
		end
	end
	if not room_just_changed then
		restart_room()
	end
end

-- room functions --
--------------------

function restart_room()
	will_restart=true
	delay_restart=15
end

function next_room()
	if room.x==2 and room.y==1 then
		music(30,500,7)
	elseif room.x==3 and room.y==1 then
		music(20,500,7)
	elseif room.x==4 and room.y==2 then
		music(30,500,7)
	elseif room.x==5 and room.y==3 then
		music(30,500,7)
	end

	if room.x==7 then
		load_room(0,room.y+1)
	else
		load_room(room.x+1,room.y)
	end
end

function load_room(x,y)

	has_dashed=false
	has_key=false
	room_just_changed = true

	--current room
	room.x = x
	room.y = y

	--remove existing objects
	foreach(objects,destroy_object)
	if #objects > 0 then
		objects = {}
	end

	--remove sprites
	playdate.graphics.sprite.removeAll()
	for _, layer in ipairs(layers) do
		layers[layer]:add()
	end

	-- entities
	for tx=0,15 do
		for ty=0,15 do
			local tile = mget(room.x*16+tx,room.y*16+ty);
			if tile==11 then
				init_object(platform,tx*8,ty*8).dir=-1
			elseif tile==12 then
				init_object(platform,tx*8,ty*8).dir=1
			else
				foreach(types,
				function(type)
					if type.tile == tile then
						init_object(type,tx*8,ty*8)
					end
				end)
			end
		end
	end

	if not is_title() then
		init_object(room_title,0,0)
	end
end

-- update function --
-----------------------

function _update()
	frames=((frames+1)%30)
	if frames==0 and level_index()<30 then
		seconds=((seconds+1)%60)
		if seconds==0 then
			minutes+=1
		end
	end

	if music_timer>0 then
		music_timer-=1
		if music_timer<=0 then
			music(10,0,7)
		end
	end

	if sfx_timer>0 then
		sfx_timer-=1
	end

	-- cancel if freeze
	if freeze>0 then freeze-=1 return end

	-- screenshake
	if shake>0 then
		shake-=1
		camera()
		if shake>0 then
			camera(-2+rnd(5),-2+rnd(5))
		end
	end

	-- restart (soon)
	if will_restart and delay_restart>0 then
		delay_restart-=1
		if delay_restart<=0 then
			will_restart=false
			load_room(room.x,room.y)
		end
	end

	-- update each object
	for _, obj in ipairs(objects) do
		if obj.spd.x ~= 0 or obj.spd.y ~= 0 then
			obj.move(obj.spd.x,obj.spd.y)
		end
		if obj.type.update~=nil then
			obj.type.update(obj)
		end
	end

	-- start game
	if is_title() then
		if not start_game and (btn(k_jump) or btn(k_dash)) then
			music(-1)
			start_game_flash=50
			start_game=true
			sfx(38)
		end
		if start_game then
			start_game_flash-=1
			if start_game_flash<=-30 then
				begin_game()
			end
		end
	end
end

-- drawing functions --
-----------------------
function _draw()
	if freeze>0 then return end

	-- start game flash
	-- if start_game then
	-- 	local c=10
	-- 	if start_game_flash>10 then
	-- 		if frames%10<5 then
	-- 			c=7
	-- 		end
	-- 	elseif start_game_flash>5 then
	-- 		c=2
	-- 	elseif start_game_flash>0 then
	-- 		c=1
	-- 	else
	-- 		c=0
	-- 	end
	-- 	if c<10 then
	-- 		pal(6,c)
	-- 		pal(12,c)
	-- 		pal(13,c)
	-- 		pal(5,c)
	-- 		pal(1,c)
	-- 		pal(7,c)
	-- 	end
	-- end

	-- clear screen
	-- rectfill(0,0,128,128,0)

	-- clouds
	drawInLayer("clouds", function(img)
		img:clear(playdate.graphics.kColorClear)
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		if not is_title() then
			foreach(clouds, function(c)
				c.x += c.spd
				rectfill(c.x,c.y,c.x+c.w,c.y+4+(1-c.w/64)*12,new_bg~=nil and 14 or 1)
				if c.x > 128 then
					c.x = -c.w
					c.y=rnd(128-8)
				end
			end)
		end
	end)

	-- draw bg terrain
	if room_just_changed then
		drawInLayer("bg_terrain", function(img)
			img:clear(playdate.graphics.kColorClear)
			map(room.x * 16,room.y * 16,0,0,16,16,2)
		end)
		if layers.bg_terrain ~= nil then
			local pdimg = layers.bg_terrain:getImage()
			local alpha = 0.3
			local ditherType = playdate.graphics.image.kDitherTypeDiagonalLine
			layers.bg_terrain:setImage(pdimg:fadedImage(alpha, ditherType))
		end
	end

	-- draw terrain
	if room_just_changed then
		drawInLayer("terrain", function(img)
			img:clear(playdate.graphics.kColorClear)
			local off=is_title() and -4 or 0
			map(room.x*16,room.y * 16,off,0,16,16,1)
		end)
		-- Create wall sprites
		if not is_title() then
			local roomIndex <const> = room.x + (room.y)*8 + 1
			local tilemap <const> = playdate.graphics.tilemap.new()
			tilemap:setImageTable(data.imagetables.tiles)
			tilemap:setTiles(data.rooms[roomIndex], 16)
			local iceWallSprites <const> = playdate.graphics.sprite.addWallSprites(tilemap, data.emptyIceIDs, kDrawOffsetX, kDrawOffsetY)
			for _, s in ipairs(iceWallSprites) do
				s.type = "ice"
				s.class = "solid"
				s:setGroups({6})
				s.collisionResponse=function(other)
					return playdate.graphics.sprite.kCollisionTypeOverlap
				end
			end
			local spikesWallSprites <const> = playdate.graphics.sprite.addWallSprites(tilemap, data.emptySpikesIDs, kDrawOffsetX, kDrawOffsetY)
			for _, s in ipairs(spikesWallSprites) do
				s.type = "spikes"
				s:setGroups({5})
				s.collisionResponse=function(other)
					return playdate.graphics.sprite.kCollisionTypeOverlap
				end
			end
			local solidWallSprites <const> = playdate.graphics.sprite.addWallSprites(tilemap, data.emptySolidIDs, kDrawOffsetX, kDrawOffsetY)
			for _, s in ipairs(solidWallSprites) do
				s.type = "solid"
				s.class = "solid"
				s:setGroups({2})
				s.collisionResponse=function(other)
					return playdate.graphics.sprite.kCollisionTypeOverlap
				end
			end
		end
	end

	-- draw objects
	foreach(objects, function(o)
		draw_object(o)
	end)

	-- draw fg terrain
	if room_just_changed then
		drawInLayer("fg_terrain", function(img)
			img:clear(playdate.graphics.kColorClear)
			map(room.x * 16,room.y * 16,0,0,16,16,3)
		end)
	end

	-- particles
	foreach(particles, function(p)
		if room_just_changed then
			p.spr:add()
		end
		p.x += p.spd
		p.y += sin(p.off)
		p.off+= min(0.05,p.spd/32)
		if is_title() then
			p.spr:moveTo(p.x,p.y)
		else
			p.spr:moveTo(p.x + kDrawOffsetX,p.y + kDrawOffsetY)
		end
		local w = 128
		if is_title() then w = 200 end
		if p.x>w+4 then
			p.x=-4
			p.y=rnd(w)
		end
	end)

	-- dead particles
	foreach(dead_particles, function(p)
		p.x += p.spd.x
		p.y += p.spd.y
		p.t -=1
		if p.t <= 0 then
			p.spr:remove()
			del(dead_particles,p)
		else
			local img <const> = playdate.graphics.image.new(flr(p.t/5) + 1, flr(p.t/5) + 1, playdate.graphics.kColorWhite)
			p.spr:setImage(img)
			p.spr:moveTo(p.x + kDrawOffsetX, p.y + kDrawOffsetY)
		end
	end)

	-- credits
	if room_just_changed then
		if is_title() then
			drawInLayer("credits", function(img)
				img:clear(playdate.graphics.kColorClear)
				_print("a+b",58,80,5)
				_print("maddy thorson",40,96,5)
				_print("noel berry",46,102,5)
			end)
		else
			drawInLayer("credits", function(img)
				img:clear(playdate.graphics.kColorClear)
			end)
		end
	end

	if level_index()==30 then
		drawInLayer("level30", function(img)
			img:clear(playdate.graphics.kColorClear)
			local p
			for i=1,#objects do
				if objects[i].type==player then
					p = objects[i]
					break
				end
			end
			if p~=nil then
				local diff=min(24,40-abs(p.x+4-64))
				rectfill(0,0,diff,128,0)
				rectfill(128-diff,0,128,128,0)
			end
		end)
	end

	room_just_changed = false

end

function draw_object(obj)

	if obj.type.draw ~=nil then
		obj.type.draw(obj)
	elseif obj.spr > 0 then
		spr(obj.spr,obj.x,obj.y,1,1,obj.flip.x,obj.flip.y)
	end

end

function draw_time(x,y)

	local pdimg <const> = playdate.graphics.image.new(33, 7)
	playdate.graphics.pushContext(pdimg)
		playdate.graphics.fillRect(0, 0, 33, 7)
		_print(get_time(),1,1,7)
	playdate.graphics.popContext()
	if not layers.time then
		layers.time = playdate.graphics.sprite.new(pdimg)
		layers.time:setCenter(0,0)
		layers.time:setZIndex(20)
	end
	layers.time:setImage(pdimg)
	layers.time:moveTo(kDrawOffsetX + x, kDrawOffsetY + y)
	layers.time:add()

end

function get_time()

	local s=seconds
	local m=minutes%60
	local h=flr(minutes/60)
	return (h<10 and "0"..h or h)..":"..(m<10 and "0"..m or m)..":"..(s<10 and "0"..s or s)

end

-- helper functions --
----------------------

function clamp(val,a,b)
	return max(a, min(b, val))
end

function appr(val,target,amount)
	return val > target 
		and max(val - amount, target) 
		or min(val + amount, target)
end

function sign(v)
	return v>0 and 1 or v<0 and -1 or 0
end

function maybe()
	return rnd(1)<0.5
end

function solid_at(x,y,w,h)
	return tile_flag_at(x,y,w,h,0)
end

function ice_at(x,y,w,h)
	return tile_flag_at(x,y,w,h,4)
end

function tile_flag_at(x,y,w,h,flag)
	for i=max(0,flr(x/8)),min(15,(x+w-1)/8) do
		for j=max(0,flr(y/8)),min(15,(y+h-1)/8) do
			if fget(tile_at(i,j),flag) then
				return true
			end
		end
	end
	return false
end

function tile_at(x,y)
	return mget(room.x * 16 + x, room.y * 16 + y)
end

function spikes_at(x,y,w,h,xspd,yspd)
	for i=max(0,flr(x/8)),min(15,(x+w-1)/8) do
		for j=max(0,flr(y/8)),min(15,(y+h-1)/8) do
			local tile=tile_at(i,j)
			if tile==17 and ((y+h-1)%8>=6 or y+h==j*8+8) and yspd>=0 then
				return true
			elseif tile==27 and y%8<=2 and yspd<=0 then
				return true
			elseif tile==43 and x%8<=2 and xspd<=0 then
				return true
			elseif tile==59 and ((x+w-1)%8>=6 or x+w==i*8+8) and xspd>=0 then
				return true
			end
		end
	end
	return false
end