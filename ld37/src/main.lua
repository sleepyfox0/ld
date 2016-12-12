require "class"

require "sound"

require "menu"
require "background"
require "entity"
require "level"

DEBUG = false

CWIDTH = 160
CHEIGHT = 120
SCALE = 3

FONTS = {}

function love.load(arg)
  FONTS.default = love.graphics.newFont()
  FONTS.mari = love.graphics.newImageFont("media/fonts/MariBonbonFont.png"
              , " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.,!?-+/\\()[]{}:;%&'\"*#=")
  snd = SoundManager()

  love.graphics.setDefaultFilter("nearest", "nearest")
  love.window.setMode(CWIDTH*SCALE, CHEIGHT*SCALE) --take out when res is set
  canvas = love.graphics.newCanvas(CWIDTH, CHEIGHT)

  particle = love.graphics.newImage("media/images/dot.png")
  sprites = love.graphics.newImage("media/images/player.png")

  zombiecnt = 0

  lvl = Level()
  lvl:load()
end

function love.update(dt)
  lvl:update(dt)
end

function love.draw()
  love.graphics.setCanvas(canvas)
  lvl:draw()
  love.graphics.setCanvas()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(canvas, 0, 0, 0, SCALE, SCALE)
  if DEBUG then
    love.graphics.setFont(FONTS.default)
    love.graphics.setColor(255, 0, 0)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
    love.graphics.print("Zombies: " .. zombiecnt, 10, 25)
  end
end
