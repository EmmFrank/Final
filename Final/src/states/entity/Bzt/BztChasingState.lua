--[[
    GD50
    Super Mario Bros. Remake
]]

BztChasingState = Class{__includes = BaseState}

function BztChasingState:init(tilemap, player, bzt)
    self.tilemap = tilemap
    self.player = player
    self.Bzt = bzt
    self.animation = Animation {
        frames = {33, 34},
        interval = 0.5
    }
    self.Bzt.currentAnimation = self.animation
end

function BztChasingState:update(dt)
    self.Bzt.currentAnimation:update(dt)

    -- calculate difference between Bzt and player on X axis
    -- and only chase if <= 5 tiles
    local diffX = math.abs(self.player.x - self.Bzt.x)

    if diffX > 5 * TILE_SIZE then
        self.Bzt:changeState('moving')
    elseif self.player.x < self.Bzt.x then
        self.Bzt.direction = 'left'
        self.Bzt.x = self.Bzt.x - BZT_MOVE_SPEED * dt

        -- stop the Bzt if there's a missing tile on the floor to the left or a solid tile directly left
        local tileLeft = self.tilemap:pointToTile(self.Bzt.x, self.Bzt.y)
        local tileBottomLeft = self.tilemap:pointToTile(self.Bzt.x, self.Bzt.y + self.Bzt.height)

        if (tileLeft and tileBottomLeft) and (tileLeft:collidable() or not tileBottomLeft:collidable()) then
            self.Bzt.x = self.Bzt.x + BZT_MOVE_SPEED * dt
        end
    else
        self.Bzt.direction = 'right'
        self.Bzt.x = self.Bzt.x + BZT_MOVE_SPEED * dt

        -- stop the Bzt if there's a missing tile on the floor to the right or a solid tile directly right
        local tileRight = self.tilemap:pointToTile(self.Bzt.x + self.Bzt.width, self.Bzt.y)
        local tileBottomRight = self.tilemap:pointToTile(self.Bzt.x + self.Bzt.width, self.Bzt.y + self.Bzt.height)

        if (tileRight and tileBottomRight) and (tileRight:collidable() or not tileBottomRight:collidable()) then
            self.Bzt.x = self.Bzt.x - BZT_MOVE_SPEED * dt
        end
    end
end
