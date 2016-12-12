
Animation = class(function(a, loop)
  loop = true or loop
  a.quads = {}
  a.timers = {}
  a.idx = 1
  a.timer = 0
  a.looping = loop
  a.finished = false
end)

function Animation:add(x, y, w, h, sw, sh, t)
  local quad = love.graphics.newQuad(x, y, w, h, sw, sh)
  table.insert(self.quads, quad)
  table.insert(self.timers, t)
end

function Animation:update(dt)
  self.timer = self.timer + dt
  if self.timer > self.timers[self.idx] then
    self.timer = 0
    self.idx = self.idx + 1
    if self.idx > #self.quads then
      if not self.loop then
        self.finished = true
      end
      self.idx = 1
    end
  end
end

function Animation:getCurrent()
  return self.quads[self.idx]
end

function Animation:reset()
  self.idx = 1
  self.finished = false
end

Entity = class(function(e, lvl, id)
  e.x = 0
  e.y = 0
  e.level = lvl
  e.idx = id
end)

function Entity:load() end
function Entity:update(dt) end
function Entity:draw(x, y) end

Player = class(Entity, function(p, lvl)
  Entity.init(p, lvl)

  p.img = nil
  p.sprite = nil
  p.idle = nil
  p.id = 0
end)

function Player:load()
  self.y = 93
  self.x = 232
  self.invince = false
  self.itimer = 0
  self.hp = 5
  self.idx = "player"

  --self.img = love.graphics.newImage("media/images/player.png")
  self.sprite = love.graphics.newSpriteBatch(sprites)
  self.idle = Animation()
  self.idle:add(0, 0, 16, 16, 256, 256, 1)

  self.run = Animation()
  self.run:add(0, 16, 16, 16, 256, 256, 0.125)
  self.run:add(16, 16, 16, 16, 256, 256, 0.125)
  self.run:add(32, 16, 16, 16, 256, 256, 0.125)
  self.run:add(48, 16, 16, 16, 256, 256, 0.125)

  self.shoot = Animation(false)
  self.shoot:add(0, 32, 16, 16, 256, 256, 0.07)
  self.shoot:add(16, 32, 16, 16, 256, 256, 0.07)
  self.shoot:add(32, 32, 16, 16, 256, 256, 0.07)
  self.shoot:add(48, 32, 16, 16, 256, 256, 0.07)
  self.shoot:add(64, 32, 16, 16, 256, 256, 0.07)
  self.shoot:add(80, 32, 16, 16, 256, 256, 0.07)
  self.shoot:add(96, 32, 16, 16, 256, 256, 0.07)

  self.hurt = Animation(false)
  self.hurt:add(0, 48, 16, 16, 256, 256, 0.125)
  self.hurt:add(16, 48, 16, 16, 256, 256, 0.125)
  self.hurt:add(32, 48, 16, 16, 256, 256, 0.125)

  self.anim = self.idle
  self.id = self.sprite:add(self.anim:getCurrent(), 0, 0)

  self.facing = 'right'
end

function Player:reload()
  self.y = 93
  self.x = 232
  self.invince = false
  self.itimer = 0
  self.hp = 5
  self.idx = "player"
  self.anim = self.idle
  self.facing = 'right'
end

function Player:update(dt)
  if love.keyboard.isDown("lctrl")  then
    if self.anim ~= self.shoot and self.anim ~= self.hurt then
      self.anim = self.shoot

      local dx = 0
      local xstart = 0
      if self.facing == 'right' then
        dx = 1
        xstart = self.x + 14
      else
        dx = -1
        xstart = self.x + 2
      end
      local step = 8 / 5
      local dy = -4

      for i = 1, 5, 1 do
        local b = Bullet(self.level, "bullet")
        b:load(xstart, self.y + 8, dx, dy)
        self.level:spawn(b)

        dy = dy + step
      end
      snd:playSound(snd.sounds.shot)
    end
  end
  if self.anim ~= self.shoot and self.anim ~= self.hurt then
    if love.keyboard.isDown("left") then
      self.x = self.x - 100*dt
      self.facing = 'left'
      self.anim = self.run;
    elseif love.keyboard.isDown("right") then
      self.x = self.x + 100*dt
      self.facing = 'right'
      self.anim = self.run;
    else
      self.anim = self.idle;
    end
  end

  if self.invince then
    self.itimer = self.itimer + dt
    if self.itimer > 2 then
      self.itimer = 0
      self.invince = false
    end
  end

  if self.x < 11 then
    self.x = 11
  elseif self.x > 453 then
    self.x = 453
  end

  self.anim:update(dt)
  if self.anim.finished then
    self.anim:reset()
    self.anim = self.idle
  end
  self.sprite:set(self.id, self.anim:getCurrent(), 0, 0)
end

function Player:draw(x, y)
  --love.graphics.setColor(255, 0, 0)
  --love.graphics.rectangle("fill", self.x - x, self.y, 16, 24)
  if self.facing == 'right' then
    love.graphics.draw(self.sprite, self.x - x, self.y)
  else
    love.graphics.draw(self.sprite, self.x - x + 16, self.y, 0, -1, 1)
  end
end

function Player:hit()
  if not self.invince then
    self.anim = self.hurt
    self.invince = true
    self.hp = self.hp - 1
    snd:playSound(snd.sounds.phit)
  end
end

Bullet = class(Entity)

function Bullet:load(x, y, dx, dy)
  self.x = x
  self.y = y
  self.dx = dx
  self.dy = dy
end

function Bullet:update(dt)
  self.x = self.x + 100*dt*self.dx
  self.y = self.y + 10*dt*self.dy

  if self.x < 0 or self.x > 480 then
    self.level:despawn(self)
  end

  if self.y < 0 or self.y > 160 then
    self.level:despawn(self)
  end
end

function Bullet:draw(x, y)
  love.graphics.draw(particle, self.x - x, self.y)
end

TurretBullet = class(Entity)

function TurretBullet:load(x, y, dx, dy)
  self.x = x
  self.y = y
  self.dx = dx
  self.dy = dy
end

function TurretBullet:update(dt)
  self.x = self.x + dt*self.dx
  self.y = self.y + dt*self.dy

  if self.x < 0 or self.x > 480 then
    self.level:despawn(self)
  end

  if self.y < 0 or self.y > 160 then
    self.level:despawn(self)
  end
end

function TurretBullet:draw(x, y)
  love.graphics.setColor(210, 125, 44)
  love.graphics.draw(particle, self.x - x - 1, self.y, 0, 3)
  love.graphics.setColor(255, 255, 255)
end

Turret = class(Entity)

function Turret:load(x, target)
  self.x = x
  self.target = target
  self.speed = 1
  self.bulletsFired = 0
  self.btimer = 0
  self.next = 0
  self.canfire = true
  self.interval = 5
end

function Turret:update(dt)
  local dirX = (self.target.x+8) - self.x
  local dirY = 160 / 5
  if math.abs(dirX) > 80 then
    self.canfire = false
  end
  dirX = dirX / 3

  self.btimer = self.btimer + dt
  if self.btimer > self.next then
    if true then
      local b = TurretBullet(self.level, "tbullet")
      b:load(self.x, 0, dirX, dirY)
      self.level:spawn(b)

      self.btimer = 0
      self.bulletsFired = self.bulletsFired + 1
      self.next = 0.5
      snd:playSound(snd.sounds.turret)

      if self.bulletsFired == self.speed then
        self.next = self.interval
        self.bulletsFired = 0
      end
    end
  end
end

function Turret:harder(rng)
  if rng:random(1, 2) == 1 then
    self.speed = self.speed + 1
    if self.speed > 6 then
      self.speed = 6
    end
  else
    self.interval = self.interval - 1
    if self.interval < 1 then
      self.interval = 1
    end
  end
end

Zombie = class(Entity)

function Zombie:load(facing, hp, velocity)
  self.facing = facing
  self.x = 0
  self.y = 93
  self.sprite = love.graphics.newSpriteBatch(sprites)
  self.walk = Animation()
  if self.facing == 'right' then
    self.walk:add(0, 64, 16, 16, 256, 256, 0.25)
    self.walk:add(16, 64, 16, 16, 256, 256, 0.25)
  else
    self.walk:add(32, 64, 16, 16, 256, 256, 0.25)
    self.walk:add(48, 64, 16, 16, 256, 256, 0.25)
  end

  self.anim = self.walk

  self.id = self.sprite:add(self.anim:getCurrent(), 0, 0)
  self.vel = velocity

  self.hp = hp
  self.lastHP = self.hp
end

function Zombie:update(dt)
  if self.hp <= 0 then
    --dead
    self.level:despawn(self)
  end
  if self.facing == 'right' then
    self.x = self.x + self.vel*dt
  else
    self.x = self.x - self.vel*dt
  end
  self.anim:update(dt)
  self.sprite:set(self.id, self.anim:getCurrent(), 0, 0)

  if self.x > 480 and self.facing == 'right' then
    self.level:despawn(self)
  elseif self.x < 0 and self.facing == 'left' then
    self.level:despawn(self)
  end

  if self.lastHP ~= self.hp then
    snd:playSound(snd.sounds.ehit)
  end

  self.lastHP = self.hp
end

function Zombie:draw(x, y)
  love.graphics.draw(self.sprite, self.x - x, self.y)
end

function Zombie:hurt()
  self.hp = self.hp - 1
end
