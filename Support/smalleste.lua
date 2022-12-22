-- celeste classic
-- matt thorson + noel berry

-- "data structures"

function vector(x,y)
 return {x=x,y=y}
end

function rectangle(x,y,w,h)
 return {x=x,y=y,w=w,h=h}
end

-- [globals]

objects,got_fruit,
freeze,shake,delay_restart,sfx_timer,music_timer,
screenshake=
{},{},
0,0,0,0,0,
true

-- [entry point]

function _init()
 title_screen()
end

function title_screen()
 frames,start_game_flash=0,0
 music(40,0,7)
 load_room(7,3)
end

function begin_game()
 max_djump,deaths,frames,seconds,minutes,music_timer=1,0,0,0,0,0
 music(0,0,7)
 load_room(0,0)
end

function level_index()
 return room.y*8+room.x+1
end

function is_title()
 return level_index()==32
end

-- [effects]

clouds={}
for i=0,16 do
 add(clouds,{
  x=rnd"128",
  y=rnd"128",
  spd=1+rnd"4",
  w=32+rnd"32"
 })
end

particles={}
for i=0,24 do
 add(particles,{
  x=rnd"128",
  y=rnd"128",
  s=flr(rnd"1.25"),
  spd=0.25+rnd"5",
  off=rnd(),
  c=6+rnd"2",
 })
end

dead_particles={}

-- [player entity]

player={
 init=function(this)
  this.grace,this.jbuffer=0,0
  this.djump=max_djump
  this.dash_time,this.dash_effect_time=0,0
  this.dash_target_x,this.dash_target_y=0,0
  this.dash_accel_x,this.dash_accel_y=0,0
  this.hitbox=rectangle(1,3,6,5)
  this.spr_off=0
  this.solids=true
  create_hair(this)
 end,
 update=function(this)
  if pause_player then
   return
  end

  -- horizontal input
  local h_input=btn(➡️) and 1 or btn(⬅️) and -1 or 0

  -- spike collision / bottom death
  if spikes_at(this.left(),this.top(),this.right(),this.bottom(),this.spd.x,this.spd.y) or
   this.y>128 then
   kill_player(this)
  end

  -- on ground checks
  local on_ground=this.is_solid(0,1)

  -- landing smoke
  if on_ground and not this.was_on_ground then
   this.init_smoke(0,4)
  end

  -- jump and dash input
  local jump,dash=btn(🅾️) and not this.p_jump,btn(❎) and not this.p_dash
  this.p_jump,this.p_dash=btn(🅾️),btn(❎)

  -- jump buffer
  if jump then
   this.jbuffer=4
  elseif this.jbuffer>0 then
   this.jbuffer-=1
  end

  -- grace frames and dash restoration
  if on_ground then
   this.grace=6
   if this.djump<max_djump then
    psfx"54"
    this.djump=max_djump
   end
  elseif this.grace>0 then
   this.grace-=1
  end

  -- dash effect timer (for dash-triggered events, e.g., berry blocks)
  this.dash_effect_time-=1

  -- dash startup period, accel toward dash target speed
  if this.dash_time>0 then
   this.init_smoke()
   this.dash_time-=1
   this.spd=vector(
    appr(this.spd.x,this.dash_target_x,this.dash_accel_x),
    appr(this.spd.y,this.dash_target_y,this.dash_accel_y)
   )
  else
   -- x movement
   local maxrun=1
   local accel=this.is_ice(0,1) and 0.05 or on_ground and 0.6 or 0.4
   local deccel=0.15

   -- set x speed
   this.spd.x=abs(this.spd.x)<=maxrun and
    appr(this.spd.x,h_input*maxrun,accel) or
    appr(this.spd.x,sign(this.spd.x)*maxrun,deccel)

   -- facing direction
   if this.spd.x~=0 then
    this.flip.x=this.spd.x<0
   end

   -- y movement
   local maxfall=2

   -- wall slide
   if h_input~=0 and this.is_solid(h_input,0) and not this.is_ice(h_input,0) then
    maxfall=0.4
    -- wall slide smoke
    if rnd()<0.2 then
     this.init_smoke(h_input*6)
    end
   end

   -- apply gravity
   if not on_ground then
    this.spd.y=appr(this.spd.y,maxfall,abs(this.spd.y)>0.15 and 0.21 or 0.105)
   end

   -- jump
   if this.jbuffer>0 then
    if this.grace>0 then
     -- normal jump
     psfx"1"
     this.jbuffer=0
     this.grace=0
     this.spd.y=-2
     this.init_smoke(0,4)
    else
     -- wall jump
     local wall_dir=(this.is_solid(-3,0) and -1 or this.is_solid(3,0) and 1 or 0)
     if wall_dir~=0 then
      psfx"2"
      this.jbuffer=0
      this.spd=vector(wall_dir*(-1-maxrun),-2)
      if not this.is_ice(wall_dir*3,0) then
       -- wall jump smoke
       this.init_smoke(wall_dir*6)
      end
     end
    end
   end

   -- dash
   local d_full=5
   local d_half=3.5355339059 -- 5 * sqrt(2)

   if this.djump>0 and dash then
    this.init_smoke()
    this.djump-=1
    this.dash_time=4
    has_dashed=true
    this.dash_effect_time=10
    -- vertical input
    local v_input=btn(⬆️) and -1 or btn(⬇️) and 1 or 0
    -- calculate dash speeds
    this.spd=vector(
     h_input~=0 and h_input*(v_input~=0 and d_half or d_full) or (v_input~=0 and 0 or this.flip.x and -1 or 1),
     v_input~=0 and v_input*(h_input~=0 and d_half or d_full) or 0
    )
    -- effects
    psfx"3"
    freeze=2
    shake=6
    -- dash target speeds and accels
    this.dash_target_x=2*sign(this.spd.x)
    this.dash_target_y=(this.spd.y>=0 and 2 or 1.5)*sign(this.spd.y)
    this.dash_accel_x=this.spd.y==0 and 1.5 or 1.06066017177 -- 1.5 * sqrt()
    this.dash_accel_y=this.spd.x==0 and 1.5 or 1.06066017177
   elseif this.djump<=0 and dash then
    -- failed dash smoke
    psfx"9"
    this.init_smoke()
   end
  end

  -- animation
  this.spr_off+=0.25
  this.spr = not on_ground and (this.is_solid(h_input,0) and 5 or 3) or  -- wall slide or mid air
   btn(⬇️) and 6 or -- crouch
   btn(⬆️) and 7 or -- look up
   this.spd.x~=0 and h_input~=0 and 1+this.spr_off%4 or 1 -- walk or stand

  -- exit level off the top (except summit)
  if this.y<-4 and level_index()<31 then
   next_room()
  end

  -- was on the ground
  this.was_on_ground=on_ground
 end,

 draw=function(this)
  -- clamp in screen
  local clamped=mid(this.x,-1,121)
  if this.x~=clamped then
   this.x=clamped
   this.spd.x=0
  end
  -- draw player hair and sprite
  set_hair_color(this.djump)
  draw_hair(this)
  draw_obj_sprite(this)
  unset_hair_color()
 end
}

function create_hair(obj)
 obj.hair={}
 for i=1,5 do
  add(obj.hair,vector(obj.x,obj.y))
 end
end

function set_hair_color(djump)
 pal(8,djump==1 and 8 or djump==0 and 12 or frames%6<3 and 7 or 11)
end

function draw_hair(obj)
 local last=vector(obj.x+(obj.flip.x and 6 or 2),obj.y+(btn(⬇️) and 4 or 3))
 for i,h in ipairs(obj.hair) do
  h.x+=(last.x-h.x)/1.5
  h.y+=(last.y+0.5-h.y)/1.5
  circfill(h.x,h.y,mid(4-i,1,2),8)
  last=h
 end
end

function unset_hair_color()
 pal() -- use pal(8,8) to preserve other palette swaps
end

-- [other entities]



player_spawn={
 init=function(this)
  sfx"4"
  this.spr=3
  this.target=this.y
  this.y=128
  this.spd.y=-4
  this.state=0
  this.delay=0
  this.djump=max_djump
  create_hair(this)
 end,
 update=function(this)
  -- jumping up
  if this.state==0 and this.y<this.target+16 then
   this.state=1
   this.delay=3
  -- falling
  elseif this.state==1 then
   this.spd.y+=0.5
   if this.spd.y>0 then
    if this.delay>0 then
     -- stall at peak
     this.spd.y=0
     this.delay-=1
    elseif this.y>this.target then
     -- clamp at target y
     this.y=this.target
     this.spd=vector(0,0)
     this.state=2
     this.delay=5
     shake=5
     this.init_smoke(0,4)
     sfx"5"
    end
   end
  -- landing and spawning player object
  elseif this.state==2 then
   this.delay-=1
   this.spr=6
   if this.delay<0 then
    destroy_object(this)
    init_object(player,this.x,this.y)
   end
  end
 end,
 draw=player.draw
}

spring={
 init=function(this)
  this.hide_in=0
  this.hide_for=0
 end,
 update=function(this)
  if this.hide_for>0 then
   this.hide_for-=1
   if this.hide_for<=0 then
    this.spr=18
    this.delay=0
   end
  elseif this.spr==18 then
   local hit=this.player_here()
   if hit and hit.spd.y>=0 then
    this.spr=19
    hit.y=this.y-4
    hit.spd.x*=0.2
    hit.spd.y=-3
    hit.djump=max_djump
    this.delay=10
    this.init_smoke()
    -- crumble below spring
    break_fall_floor(this.check(fall_floor,0,1) or {})
    psfx"8"
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
 end
}

balloon={
 init=function(this)
  this.offset=rnd()
  this.start=this.y
  this.timer=0
  this.hitbox=rectangle(-1,-1,10,10)
 end,
 update=function(this)
  if this.spr==22 then
   this.offset+=0.01
   this.y=this.start+sin(this.offset)*2
   local hit=this.player_here()
   if hit and hit.djump<max_djump then
    psfx"6"
    this.init_smoke()
    hit.djump=max_djump
    this.spr=0
    this.timer=60
   end
  elseif this.timer>0 then
   this.timer-=1
  else
   psfx"7"
   this.init_smoke()
   this.spr=22
  end
 end,
 draw=function(this)
  if this.spr==22 then
   spr(13+(this.offset*8)%3,this.x,this.y+6)
   draw_obj_sprite(this)
   --spr(this.spr,this.x,this.y)
  end
 end
}

fall_floor={
 init=function(this)
  this.state=0
  --this.delay=0
 end,
 update=function(this)
  -- idling
  if this.state==0 then
   for i=0,2 do
    if this.check(player,i-1,-(i%2)) then
     break_fall_floor(this)
    end
   end
  -- shaking
  elseif this.state==1 then
   this.delay-=1
   if this.delay<=0 then
    this.state=2
    this.delay=60--how long it hides for
    this.collideable=false
   end
  -- invisible, waiting to reset
  elseif this.state==2 then
   this.delay-=1
   if this.delay<=0 and not this.player_here() then
    psfx"7"
    this.state=0
    this.collideable=true
    this.init_smoke()
   end
  end
 end,
 draw=function(this)
  spr(this.state==1 and 26-this.delay/5 or this.state==0 and 23,this.x,this.y)
 end
}

function break_fall_floor(obj)
 if obj.state==0 then
  psfx"15"
  obj.state=1
  obj.delay=15--how long until it falls
  obj.init_smoke();
  (obj.check(spring,0,-1) or {}).hide_in=15
 end
end

smoke={
 init=function(this)
  this.spd=vector(0.3+rnd"0.2",-0.1)
  this.x+=-1+rnd"2"
  this.y+=-1+rnd"2"
  this.flip=vector(rnd()<0.5,rnd()<0.5)
 end,
 update=function(this)
  this.spr+=0.2
  if this.spr>=32 then
   destroy_object(this)
  end
 end
}

fruit={
 if_not_fruit=true,
 init=function(this)
  this.start=this.y
  this.off=0
 end,
 update=function(this)
  check_fruit(this)
  this.off+=0.025
  this.y=this.start+sin(this.off)*2.5
 end
}

fly_fruit={
 if_not_fruit=true,
 init=function(this)
  this.start=this.y
  this.off=0.5
  this.sfx_delay=8
 end,
 update=function(this)
  --fly away
  if has_dashed then
   if this.sfx_delay>0 then
   this.sfx_delay-=1
   if this.sfx_delay<=0 then
    sfx_timer=20
    sfx"14"
   end
   end
   this.spd.y=appr(this.spd.y,-3.5,0.25)
   if this.y<-16 then
    destroy_object(this)
   end
  -- wait
  else
   this.off+=0.05
   this.spd.y=sin(this.off)*0.5
  end
  -- collect
  check_fruit(this)
 end,
 draw=function(this)
  draw_obj_sprite(this)
  --spr(this.spr,this.x,this.y)
  for ox=-6,6,12 do
   spr((has_dashed or sin(this.off)>=0) and 45 or this.y>this.start and 47 or 46,this.x+ox,this.y-2,1,1,ox==-6)
  end
 end
}

function check_fruit(this)
 local hit=this.player_here()
 if hit then
  hit.djump=max_djump
  sfx_timer=20
  sfx"13"
  got_fruit[level_index()]=true
  init_object(lifeup,this.x,this.y)
  destroy_object(this)
 end
end

lifeup={
 init=function(this)
  this.spd.y=-0.25
  this.duration=30
  this.flash=0
 end,
 update=function(this)
  this.duration-=1
  if this.duration<=0 then
   destroy_object(this)
  end
 end,
 draw=function(this)
  this.flash+=0.5
  ?"1000",this.x-4,this.y-4,7+this.flash%2
 end
}

fake_wall={
 if_not_fruit=true,
 update=function(this)
  this.hitbox=rectangle(-1,-1,18,18)
  local hit=this.player_here()
  if hit and hit.dash_effect_time>0 then
   hit.spd=vector(sign(hit.spd.x)*-1.5,-1.5)
   hit.dash_time=-1
   for ox=0,8,8 do
    for oy=0,8,8 do
     this.init_smoke(ox,oy)
    end
   end
   init_fruit(this,4,4)
  end
  this.hitbox=rectangle(0,0,16,16)
 end,
 draw=function(this)
  spr(64,this.x,this.y,2,2)
 end
}

function init_fruit(this,ox,oy)
 sfx_timer=20
 sfx"16"
 init_object(fruit,this.x+ox,this.y+oy,26)
 destroy_object(this)
end

key={
 if_not_fruit=true,
 update=function(this)
  this.spr=9.5+sin(frames/30)
  if frames==18 then
   this.flip.x=not this.flip.x
  end
  if this.player_here() then
   sfx"23"
   sfx_timer=10
   destroy_object(this)
   has_key=true
  end
 end
}

chest={
 if_not_fruit=true,
 init=function(this)
  this.x-=4
  this.start=this.x
  this.timer=20
 end,
 update=function(this)
  if has_key then
   this.timer-=1
   this.x=this.start-1+rnd"3"
   if this.timer<=0 then
    init_fruit(this,0,-4)
   end
  end
 end
}

platform={
 init=function(this)
  this.x-=4
  this.hitbox.w=16
  this.last=this.x
  this.dir=this.spr==11 and -1 or 1
 end,
 update=function(this)
  this.spd.x=this.dir*0.65
  if this.x<-16 then this.x=128
  elseif this.x>128 then this.x=-16 end
  if not this.player_here() then
   local hit=this.check(player,0,-1)
   if hit then
    --hit.move_x(this.x-this.last,1)
    --hit.move_loop(this.x-this.last,1,"x")
    hit.move(this.x-this.last,0,1)
   end
  end
  this.last=this.x
 end,
 draw=function(this)
   spr(11,this.x,this.y-1,2,1)
 end
}

message={
 draw=function(this)
  this.text="-- celeste mountain --#this memorial to those# perished on the climb"
  if this.check(player,4,0) then
   if this.index<#this.text then
    this.index+=0.5
    if this.index>=this.last+1 then
     this.last+=1
     sfx"35"
    end
   end
   local _x,_y=8,96
   for i=1,this.index do
    if sub(this.text,i,i)~="#" then
     rectfill(_x-2,_y-2,_x+7,_y+6 ,7)
     ?sub(this.text,i,i),_x,_y,0
     _x+=5
    else
     _x=8
     _y+=7
    end
   end
  else
   this.index=0
   this.last=0
  end
 end
}

big_chest={
 init=function(this)
  this.state=0
  this.hitbox.w=16
 end,
 draw=function(this)
  if this.state==0 then
   local hit=this.check(player,0,8)
   if hit and hit.is_solid(0,1) then
    music(-1,500,7)
    sfx"37"
    pause_player=true
    hit.spd=vector(0,0)
    this.state=1
    this.init_smoke()
    this.init_smoke(8)
    this.timer=60
    this.particles={}
   end
   sspr(0,48,16,8,this.x,this.y)
  elseif this.state==1 then
   this.timer-=1
   shake=5
   flash_bg=true
   if this.timer<=45 and #this.particles<50 then
    add(this.particles,{
     x=1+rnd"14",
     y=0,
     h=32+rnd"32",
     spd=8+rnd"8"
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
  sspr(0,56,16,8,this.x,this.y+8)
 end
}

orb={
 init=function(this)
  this.spd.y=-4
 end,
 draw=function(this)
  this.spd.y=appr(this.spd.y,0,0.5)
  local hit=this.player_here()
  if this.spd.y==0 and hit then
   music_timer=45
   sfx"51"
   freeze=10
   shake=10
   destroy_object(this)
   max_djump=2
   hit.djump=2
  end
  spr(102,this.x,this.y)
  for i=0,0.875,0.125 do
   circfill(this.x+4+cos(frames/30+i)*8,this.y+4+sin(frames/30+i)*8,1,7)
  end
 end
}

flag={
 init=function(this)
  --this.show=false
  this.x+=5
  this.score=0
  for _ in pairs(got_fruit) do
   this.score+=1
  end
 end,
 draw=function(this)
  this.spr=118+frames/5%3
  draw_obj_sprite(this)
  --spr(this.spr,this.x,this.y)
  if this.show then
   rectfill(32,2,96,31,0)
   spr(26,55,6)
   ?"x"..this.score,64,9,7
   draw_time(49,16)
   ?"deaths:"..deaths,48,24,7
  elseif this.player_here() then
   sfx"55"
   sfx_timer=30
   this.show=true
  end
 end
}

room_title={
 init=function(this)
  this.delay=5
 end,
 draw=function(this)
  this.delay-=1
  if this.delay<-30 then
   destroy_object(this)
  elseif this.delay<0 then
   rectfill(24,58,104,70,0)
   local level=level_index()
   if level==12 then
    ?"old site",48,62,7
   elseif level==31 then
    ?"summit",52,62,7
   else
    ?level.."00 m",level<10 and 54 or 52,62,7
   end
   draw_time(4,4)
  end
 end
}

function psfx(num)
 if sfx_timer<=0 then
  sfx(num)
 end
end

-- [tile dict]
tiles={}
foreach(split([[
1,player_spawn
8,key
11,platform
12,platform
18,spring
20,chest
22,balloon
23,fall_floor
26,fruit
28,fly_fruit
64,fake_wall
86,message
96,big_chest
118,flag
]],"\n"),function(t)
 local tile,obj=unpack(split(t))
 tiles[tile]=_ENV[obj]
end)

-- [object functions]

function init_object(type,x,y,tile)
 if type.if_not_fruit and got_fruit[level_index()] then
  return
 end

 local obj={
  type=type,
  collideable=true,
  --solids=false,
  spr=tile,
  flip=vector(),
  x=x,
  y=y,
  hitbox=rectangle(0,0,8,8),
  spd=vector(0,0),
  rem=vector(0,0),
 }

 function obj.left() return obj.x+obj.hitbox.x end
 function obj.right() return obj.left()+obj.hitbox.w-1 end
 function obj.top() return obj.y+obj.hitbox.y end
 function obj.bottom() return obj.top()+obj.hitbox.h-1 end

 function obj.init_smoke(ox,oy)
  init_object(smoke,obj.x+(ox or 0),obj.y+(oy or 0),29)
 end

 function obj.is_solid(ox,oy)
  return (oy>0 and not obj.check(platform,ox,0) and obj.check(platform,ox,oy)) or
      obj.is_flag(ox,oy,0) or
      obj.check(fall_floor,ox,oy) or
      obj.check(fake_wall,ox,oy)
 end

 function obj.is_ice(ox,oy)
  return obj.is_flag(ox,oy,4)
 end

 function obj.is_flag(ox,oy,flag)
  for i=max(0,(obj.left()+ox)\8),min(15,(obj.right()+ox)/8) do
   for j=max(0,(obj.top()+oy)\8),min(15,(obj.bottom()+oy)/8) do
    if fget(tile_at(i,j),flag) then
     return true
    end
   end
  end
  --return tile_flag_at(obj.left()+ox,obj.top()+oy,obj.right()+ox,obj.bottom()+oy,flag)
 end

 function obj.check(type,ox,oy)
  for other in all(objects) do
   if other and other.type==type and other~=obj and other.collideable and
    other.right()>=obj.left()+ox and
    other.bottom()>=obj.top()+oy and
    other.left()<=obj.right()+ox and
    other.top()<=obj.bottom()+oy then
    return other
   end
  end
 end

 function obj.player_here()
  return obj.check(player,0,0)
 end

 function obj.move(ox,oy,start)
  for axis in all{"x","y"} do
   obj.rem[axis]+=vector(ox,oy)[axis]
   local amt=flr(obj.rem[axis]+0.5)
   obj.rem[axis]-=amt
   if obj.solids then
    local step=sign(amt)
    local d=axis=="x" and step or 0
    for i=start,abs(amt) do
     if not obj.is_solid(d,step-d) then
      obj[axis]+=step
     else
      obj.spd[axis],obj.rem[axis]=0,0
      break
     end
    end
   else
    obj[axis]+=amt
   end
  end
 end

 add(objects,obj);
 (obj.type.init or max)(obj)

 return obj
end

function destroy_object(obj)
 del(objects,obj)
end

function kill_player(obj)
 sfx_timer=12
 sfx"0"
 deaths+=1
 shake=10
 destroy_object(obj)
 dead_particles={}
 for dir=0,0.875,0.125 do
  add(dead_particles,{
   x=obj.x+4,
   y=obj.y+4,
   t=2,--10,
   dx=sin(dir)*3,
   dy=cos(dir)*3
  })
 end
 --restart_room()
 delay_restart=15
end

-- [room functions]

--function restart_room()
--  delay_restart=15
--end

function next_room()
 local level=level_index()
 if level==11 or level==21 or level==30 then -- quiet for old site, 2200m, summit
  music(30,500,7)
 elseif level==12 then -- 1300m
  music(20,500,7)
 end
 load_room(level%8,level\8)
end

function load_room(x,y)
 has_dashed,has_key=false,--false
 --remove existing objects
 foreach(objects,destroy_object)
 --current room
 room=vector(x,y)
 -- entities
 for tx=0,15 do
  for ty=0,15 do
   local tile=tile_at(tx,ty)
   if tiles[tile] then
    init_object(tiles[tile],tx*8,ty*8,tile)
   end
  end
 end
 -- room title
 if not is_title() then
  init_object(room_title,0,0)
 end
end

-- [main update loop]

function _update()
 frames+=1
 if level_index()<31 then
  seconds+=frames\30
  minutes+=seconds\60
  seconds%=60
 end
 frames%=30

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
 if freeze>0 then
  freeze-=1
  return
 end

 -- screenshake
 if btnp(⬆️,1) then
  screenshake=not screenshake
 end
 if shake>0 then
  shake-=1
  camera()
  if screenshake and shake~=0 then
   camera(-2+rnd"5",-2+rnd"5")
  end
 end

 -- restart (soon)
 if delay_restart>0 then
  delay_restart-=1
  if delay_restart==0 then
   load_room(room.x,room.y)
  end
 end

 -- update each object
 foreach(objects,function(obj)
  obj.move(obj.spd.x,obj.spd.y,0);
  (obj.type.update or max)(obj)
 end)

 -- start game
 if is_title() then
  if start_game then
   start_game_flash-=1
   if start_game_flash<=-30 then
    begin_game()
   end
  elseif btn(🅾️) or btn(❎) then
   music"-1"
   start_game_flash,start_game=50,true
   sfx"38"
  end
 end
end

-- [drawing functions]

function _draw()
 if freeze>0 then
  return
 end

 -- reset all palette values
 pal()

 -- start game flash
 if is_title() and start_game then
  for i=1,15 do
   pal(i, start_game_flash<=10 and ceil(max(start_game_flash)/5) or frames%10<5 and 7 or i)
  end
 end

 -- draw bg color (pad for screenshake)
 cls()
 rectfill(0,0,127,127,flash_bg and frames/5 or new_bg and 2 or 0)

 -- bg clouds effect
 if not is_title() then
  foreach(clouds,function(c)
   c.x+=c.spd
   crectfill(c.x,c.y,c.x+c.w,c.y+16-c.w*0.1875,new_bg and 14 or 1)
   if c.x>128 then
    c.x=-c.w
    c.y=rnd"120"
   end
  end)
 end

 local rx,ry=room.x*16,room.y*16

 -- draw bg terrain
 map(rx,ry,0,0,16,16,4)

 -- draw clouds + orb chest
 foreach(objects,function(o)
  if o.type==platform then
   draw_object(o)
  end
 end)

 -- draw terrain (offset if title screen)
 map(rx,ry,is_title() and -4 or 0,0,16,16,2)

 -- draw objects
 foreach(objects,function(o)
  if o.type~=platform then
   draw_object(o)
  end
 end)

 -- draw fg terrain (not a thing)
 --map(room.x*16,room.y*16,0,0,16,16,8)

 -- particles
 foreach(particles,function(p)
  p.x+=p.spd
  p.y+=sin(p.off)
  p.off+=min(0.05,p.spd/32)
  crectfill(p.x,p.y,p.x+p.s,p.y+p.s,p.c)
  if p.x>132 then
   p.x=-4
   p.y=rnd"128"
  end
 end)

 -- dead particles
 foreach(dead_particles,function(p)
  p.x+=p.dx
  p.y+=p.dy
  p.t-=0.2--1
  if p.t<=0 then
   del(dead_particles,p)
  end
  crectfill(p.x-p.t,p.y-p.t,p.x+p.t,p.y+p.t,14+p.t*5%2)
 end)

 -- credits
 if is_title() then
  ?"z+x",58,80,5
  ?"matt thorson",42,96,5
  ?"noel berry",46,102,5
 end

 -- summit blinds effect
 if level_index()==31 and objects[2].type==player then
  local diff=min(24,40-abs(objects[2].x-60))
  rectfill(0,0,diff,127,0)
  rectfill(127-diff,0,127,127,0)
 end
end

function draw_object(obj)
 (obj.type.draw or draw_obj_sprite)(obj)
end

function draw_obj_sprite(obj)
 spr(obj.spr,obj.x,obj.y,1,1,obj.flip.x,obj.flip.y)
end

function draw_time(x,y)
 rectfill(x,y,x+32,y+6,0)
 ?two_digit_str(minutes\60)..":"..two_digit_str(minutes%60)..":"..two_digit_str(seconds),x+1,y+1,7
end

function two_digit_str(x)
 return x<10 and "0"..x or x
end

function crectfill(x1,y1,x2,y2,c)
 if x1<128 and x2>0 and y1<128 and y2>0 then
  rectfill(max(0,x1),max(0,y1),min(127,x2),min(127,y2),c)
 end
end

-- [helper functions]

function appr(val,target,amount)
 return val>target and max(val-amount,target) or min(val+amount,target)
end

function sign(v)
 return v~=0 and sgn(v) or 0
end

function tile_at(x,y)
 return mget(room.x*16+x,room.y*16+y)
end

function spikes_at(x1,y1,x2,y2,xspd,yspd)
 for i=max(0,x1\8),min(15,x2/8) do
  for j=max(0,y1\8),min(15,y2/8) do
   if ({[17]=yspd>=0 and y2%8>=6,
    [27]=yspd<=0 and y1%8<=2,
    [43]=xspd<=0 and x1%8<=2,
    [59]=xspd>=0 and x2%8>=6})[tile_at(i,j)] then
    return true
   end
  end
 end
end