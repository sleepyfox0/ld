
Background = class(function(b)
  b.img = nil
  b.mid = nil
  b.mid2 = nil
  b.bkg = nil
  b.over = nil
end)

function Background:load()
  self.img = love.graphics.newImage("media/images/room.png")
  self.bkg = love.graphics.newImage("media/images/bkg.png")
  self.mid = love.graphics.newImage("media/images/middle.png")
  self.mid2 = love.graphics.newImage("media/images/mid2.png")
  self.over = love.graphics.newImage("media/images/overlay.png")
end

function Background:update(dt) end

function Background:draw(x, y)
  love.graphics.draw(self.bkg, 0, 0)
  love.graphics.draw(self.mid2, -x/4, 0)
  love.graphics.draw(self.mid, -x/2, 0)
  love.graphics.draw(self.img, -x, 0)
end

function Background:drawOverlay(x, y)
  love.graphics.draw(self.over, -x, 0)
end
