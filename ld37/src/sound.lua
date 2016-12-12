
SoundManager = class(function(sm)
  sm.music = {}
  sm.sounds = {}
  sm.cm = nil
  sm.m_vol = 1
  sm.s_vol = 1
  sm.stop = false
end)

function SoundManager:loadMusic(ref, src)
  local mus = love.audio.newSource(src)
  mus:setVolume(self.m_vol)
  self.music[ref] = mus
end

function SoundManager:loadSound(ref, src)
  local sound = love.audio.newSource(src)
  sound:setVolume(self.s_vol)
  self.sounds[ref] = sound
end

function SoundManager:setMusicVolume(vol)
  self.m_vol = vol
  for k, v in pairs(self.music) do
    v:setVolume(self.m_vol)
  end
end

function SoundManager:setSoundVolume(vol)
  self.s_vol = vol
  for k, v in pairs(self.sounds) do
    v:setVolume(self.s_vol)
  end
end

function SoundManager:playMusic(src)
  if self.cm then
    self.cm:stop()
  end
  src:rewind()
  src:play()
  self.cm = src
  self.stop = false
end

function SoundManager:stopMusic(src)
  if self.cm then
    self.cm:stop()
    self.stop = true
  end
end

function SoundManager:playSound(src)
  src:rewind()
  src:play()
end

function SoundManager:updateMusic()
  if self.cm then
    if not self.stop then
      if self.cm:isStopped() then
        self.cm:rewind()
        self.cm:play()
      end
    end
  end
end
