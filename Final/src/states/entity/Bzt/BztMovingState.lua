--[[
    GD50
    Super Mario Bros. Remake

]]

BztMovingState = Class{__includes = BaseState}

function BztMovingState:init(tilemap, player, bzt)
    self.tilemap = tilemap
    self.player = player
    self.Bzt = bzt
    self.animation = Animation {
        frames = {33, 34},
        interval = 0.5
    }
    self.Bzt.currentAnimation = self.animation

    self.movingDirection = math.random(2) == 1 and 'left' or 'right'
    self.Bzt.direction = self.movingDirection
    self.movingDuration = math.random(5)
    self.movingTimer = 0
end

function BztMovingState:update(dt)
    self.movingTimer = self.movingTimer + dt
    self.Bzt.currentAnimation:update(dt)

    -- reset movement direction and timer if timer is above duration
    if self.movingTimer > self.movingDuration then

        -- chance to go into idle state randomly
        if math.random(4) == 1 then
            self.Bzt:changeState('idle', {

                -- random amount of time for Bzt to be idle
                wait = math.random(5)
            })
        else
            self.movingDirection = math.random(2) == 1 and 'left' or 'right'
            self.Bzt.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    elseif self.Bzt.direction == 'left' then
        self.Bzt.x = self.Bzt.x - BZT_MOVE_SPEED * dt

        -- stop the Bzt if there's a missing tile on the floor to the left or a solid tile directly left
        local tileLeft = self.tilemap:pointToTile(self.Bzt.x, self.Bzt.y)
        local tileBottomLeft = self.tilemap:pointToTile(self.Bzt.x, self.Bzt.y + self.Bzt.height)

        if (tileLeft and tileBottomLeft) and (tileLeft:collidable() or not tileBottomLeft:collidable()) then
            self.Bzt.x = self.Bzt.x + BZT_MOVE_SPEED * dt

            -- reset direction if we hit a wall
            self.movingDirection = 'right'
            self.Bzt.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    else
        self.Bzt.direction = 'right'
        self.Bzt.x = self.Bzt.x + BZT_MOVE_SPEED * dt

        -- stop the Bzt if there's a missing tile on the floor to the right or a solid tile directly right
        local tileRight = self.tilemap:pointToTile(self.Bzt.x + self.Bzt.width, self.Bzt.y)
        local tileBottomRight = self.tilemap:pointToTile(self.Bzt.x + self.Bzt.width, self.Bzt.y + self.Bzt.height)

        if (tileRight and tileBottomRight) and (tileRight:collidable() or not tileBottomRight:collidable()) then
            self.Bzt.x = self.Bzt.x - BZT_MOVE_SPEED * dt

            -- reset direction if we hit a wall
            self.movingDirection = 'left'
            self.Bzt.direction = self.movingDirection
            self.movingDuration = math.random(5)
            self.movingTimer = 0
        end
    end

    -- calculate difference between Bzt and player on X axis
    -- and only chase if <= 5 tiles
    local diffX = math.abs(self.player.x - self.Bzt.x)

    if diffX < 5 * TILE_SIZE then
        self.Bzt:changeState('chasing')
    end
end
