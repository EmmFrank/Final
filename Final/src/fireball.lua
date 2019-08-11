--[[
    GD50
    Super Mario Bros. Remake

Author: Michael Frank
]]

fireball = Class{__includes = Entity}

function fireball:init(def)
    Entity.init(self, def)
end

function fireball:render()
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][1],
        math.floor(self.x) + 8, math.floor(self.y) + 8, 0, self.direction == 'left' and 1 or -1, 1, 8, 10)
end
