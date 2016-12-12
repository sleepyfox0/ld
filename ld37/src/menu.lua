
Menu = class(function(m)
  m.shown = false
  m.change = false
  m.next = "menu"
end)

function Menu:load()end
function Menu:update(dt)end
function Menu:draw()end

--[[
Title Menu
]]
TitleMenu = class(Menu)

function TitleMenu:load()
  self.shown = true
  self.next = "title"
  self.change = false
end

function TitleMenu:update(dt)
  if love.keyboard.isDown("return") then
    --self.change = true
    self.shown = false
  end

  if love.keyboard.isDown("space") then
    snd:playSound(snd.sounds.explosion)
  end
end

function TitleMenu:draw()
  love.graphics.setColor(20, 12, 28)
  love.graphics.rectangle("fill", 0, 0, CWIDTH, CHEIGHT)
  love.graphics.setColor(222, 238, 214)
  love.graphics.print("A L O N E  W I T H  Z O M B I E S", 23, 30)
  love.graphics.print("A  s i l l y  \" g a m e \"  b y  s l e e p y f o x", 10, 50)
  love.graphics.print("P r e s s  r e t u r n ,  p l e a s e", 25, 100)
end

GameOver = class(Menu)

function GameOver:load()
  self.shown = false
  self.next = "title"
  self.change = false
end

function GameOver:update(dt)
  if love.keyboard.isDown("lctrl") then
    lvl.menus.title.shown = true
    self.change = true
    lvl:reload()
    print("reloading")
  end
end

function GameOver:draw()
  love.graphics.setColor(20, 12, 28, 128)
  love.graphics.rectangle("fill", 0, 0, CWIDTH, CHEIGHT)
  love.graphics.setColor(222, 238, 214)
  love.graphics.print("G A M E  O V E R", 10, 50)
  love.graphics.print("Y o u r  l i f e  e n d e d  t r a g i c a l l y .", 5, 60)
  love.graphics.print("S a d ,  b u t  t r u e .", 5, 70)
end

Intruder = class(Menu)

function Intruder:load()
  self.itimer = 0
  self.what = 'intruder'
  self.shown = false
  self.change = false
end

function Intruder:update(dt)
  self.itimer = self.itimer + dt
  if self.what == 'empty' then
    if self.itimer > 1 then
      self.itimer = 0
      self.what = 'intruder'
    end
  end

  if self.what == 'intruder' then
    if self.itimer > 5 then
      self.shown = false
    end
  end
end

function Intruder:draw()
  love.graphics.setColor(20, 12, 28, 128)
  love.graphics.rectangle("fill", 0, 0, CWIDTH, CHEIGHT)
  if self.what == 'intruder' then
    love.graphics.setColor(222, 238, 214)
    love.graphics.print("I N T R U D E R  D E T E C T E D !", 5, 20)
    love.graphics.print("I n i t i a t i n g  c o u n t e r m e a s u r e s", 5, 30)
  end
end
