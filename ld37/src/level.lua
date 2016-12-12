
Level = class(function(l)
  l.menus = {}
  l.despawner = {}
  l.menus.title = TitleMenu()
  l.menus.game_over = GameOver()
  l.menus.intruder = Intruder()

  l.menu = l.menus.title
  l.bkg = Background()
  l.entities = {}
  l.player = Player(l, "player")
  l.turrets = {}

  l.x = 0
  l.y = 0

  l.spawnTimer = 0
  l.measure = true

  l.wave = 0
  l.rng = love.math.newRandomGenerator(666)
end)

function Level:load()
  --load sound data
  snd:setMusicVolume(0.5)
  snd:loadMusic("music", "media/music/music.ogg")
  snd:setSoundVolume(0.75)
  snd:loadSound("explosion", "media/sounds/explosion.wav")
  snd:loadSound("shot", "media/sounds/shot.wav")
  snd:loadSound("phit", "media/sounds/playerhit.wav")
  snd:loadSound("ehit", "media/sounds/enemyhit.wav")
  snd:loadSound("turret", "media/sounds/turret.wav")

  self.bkg:load()
  for k,v in pairs(self.menus) do
    v:load()
  end

  self.player:load()
  table.insert(self.entities, self.player)
  --snd:playMusic(snd.music.music)
end

function Level:reload()
  self.spawnTimer = 0
  self.measure = true

  for k,v in pairs(self.menus) do
    v:load()
  end

  self.wave = 0
  self.entities = {}
  self.turrets = {}
  self.player:reload()
  table.insert(self.entities, self.player)

  self.menu = self.menus.title
  self.menu.shown = true

  self.rng:setSeed(666)
  snd:stopMusic(snd.music.music)
end

function Level:update(dt)
  self.despawner = {}
  if self.measure then
    if not self.menu.shown then
      self.spawnTimer = self.spawnTimer + dt

      if self.spawnTimer > 2 then
        self:createWave()
        self.measure = false
      end
    end
  end
  if self.menu.change then
    self.menu = self.menus[self.menu.next]
  end
  if self.menu.shown then
    self.menu:update(dt)
  else
    self.bkg:update(dt)
    local z_cnt = 0
    for i,v in pairs(self.entities) do
      if v.idx == "bullet" then
        for i2,v2 in pairs(self.entities) do
          if v2.idx == "zombie" then
            -- check if hit
            local bx = v.x
            local by = v.y
            if bx > v2.x and bx < v2.x+16 and by > v2.y and by < v2.y+16 then
              v2:hurt()
              self:despawn(v)
            end
          end
        end
      end

      if v.idx == "tbullet" then
        for i2,v2 in pairs(self.entities) do
          if v2.idx == "zombie" or v2.idx == "player" then
            -- check if hit
            local bx = v.x
            local by = v.y
            if bx > v2.x and bx < v2.x+16 and by > v2.y and by < v2.y+16 then
              if v2.idx == "zombie" then
                v2:hurt()
                --self:despawn(v)
              else
                v2:hit()
              end
            end
          end
        end
      end

      zombiecnt = z_cnt
      if v.idx == "zombie" then
        z_cnt = z_cnt + 1

        local xc = 0
        if v.facing == 'right' then
          xc = v.x + 9
        else
          xc = v.x + 7
        end
        if xc > self.player.x and xc < self.player.x + 16 then
          self.player:hit()
        end
      end
      v:update(dt)
    end

    if z_cnt == 0 and not self.measure then
      self.spawnTimer = 0
      self.measure = true
    end

    for i, v in pairs(self.despawner) do
      for i2,v2 in pairs(self.entities) do
        if v == v2 then
          self.entities[i2] = nil
        end
      end
    end

    if self.player.hp <= 0 then
      self.menu = self.menus.game_over
      self.menu.shown = true
      snd:stopMusic(snd.music.music)
    end
  end

  self.x = self.player.x - 80
  if self.x < 0 then
    self.x = 0
  elseif self.x > 320 then
    self.x = 320
  end

  snd:updateMusic()
end

function Level:draw()
  love.graphics.clear(20, 12, 28)
  love.graphics.setFont(FONTS.mari)

  love.graphics.setColor(255, 255, 255)
  self.bkg:draw(self.x, 0)
  for i,v in pairs(self.entities) do
    v:draw(self.x, 0)
  end
  self.bkg:drawOverlay(self.x, 0)

  -- GUI
  love.graphics.setColor(208, 70, 72)
  love.graphics.print("W a v e : " .. self.wave, 100, 2)

  local xs = 5
  for i = 1, self.player.hp, 1 do
    love.graphics.rectangle("fill", xs, 5, 5, 5)
    xs = xs + 6
  end
  if self.menu.shown then
    self.menu:draw()
  end
end

function Level:createWave()
  local cw = self.wave + 1

  if cw == 3 then
    self.menu = self.menus.intruder
    self.menu.shown = true
    snd:playMusic(snd.music.music)

    local t = Turret(self, "turret")
    t:load(240, self.player)
    self:spawn(t)
    self.turrets[1] = t
  end

  if cw == 4 then
    local t = Turret(self, "turret")
    t:load(80, self.player)
    self:spawn(t)
    self.turrets[2] = t
  end

  if cw == 5 then
    local t = Turret(self, "turret")
    t:load(400, self.player)
    self:spawn(t)
    self.turrets[3] = t
  end

  if cw > 5 then
    self.turrets[self.rng:random(1,3)]:harder(self.rng)
  end

  local nr = 4 + cw
  for i = 1, nr, 1 do
    local facing = 'right'
    local dir = self.rng:random(1,2)
    if dir == 1 then
      facing = 'left'
    else
      facing = 'right'
    end

    local start_x = self.rng:random(1, 25 + cw*5)

    local z = Zombie(self, "zombie")
    z:load(facing, 1, self.rng:random(10, math.min(50, math.max(10, cw*10 / 2))))
    if facing == 'right' then
      z.x = -start_x
    else
      z.x = start_x + 480
    end
    self:spawn(z)
  end

  self.wave = cw
end

function Level:spawn(e)
  table.insert(self.entities, e)
end

function Level:despawn(e)
  table.insert(self.despawner, e)
end
