--[[
    GD50
    Super Mario Bros. Remake

]]

BztIdleState = Class{__includes = BaseState}

function BztIdleState:init(tilemap, player, bzt)
    self.tilemap = tilemap
    self.player = player
    self.Bzt = bzt
    self.waitTimer = 0
    self.animation = Animation {
        frames = {33, 34},
        interval = 0.5
    }
    self.Bzt.currentAnimation = self.animation
end

function BztIdleState:enter(params)
    self.waitPeriod = params.wait
end

function BztIdleState:update(dt)
    if self.waitTimer < self.waitPeriod then
        self.waitTimer = self.waitTimer + dt
    else
        self.Bzt:changeState('moving')
    end

    -- calculate difference between Bzt and player on X axis
    -- and only chase if <= 5 tiles
    local diffX = math.abs(self.player.x - self.Bzt.x)

    if diffX < 5 * TILE_SIZE then
        self.Bzt:changeState('chasing')
    end
end
