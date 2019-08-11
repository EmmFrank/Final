fireballGo = Class{__includes = BaseState}

function fireballGo:init(tilemap, player, fireball)
    self.tilemap = tilemap
    self.player = player
    self.fireball = fireball
    self.animation = Animation {
        frames = {1, 2},
        interval = 0.5
    }
    self.fireball.currentAnimation = self.animation
  end


  function fireballGo:update(dt)

    exists = true

    if self.fireball.x < VIRTUAL_WIDTH/2 then
      exists = false
    end

        if self.player.x < self.fireball.x then

            self.fireball.x = self.fireball.x - SNAIL_MOVE_SPEED/10
            self.fireball.y = self.fireball.y - SNAIL_MOVE_SPEED/10

        else

            self.fireball.x = self.fireball.x + SNAIL_MOVE_SPEED/10
            self.fireball.y = self.fireball.y - SNAIL_MOVE_SPEED/10

      end
  end
