--[[
    GD50
    Super Mario Bros. Remake

    -- LevelMaker Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

LevelMaker = Class{}

function LevelMaker.generate(width, height, score)
    local tiles = {}
    local entities = {}
    local objects = {}


    local tileID = TILE_ID_GROUND

    -- whether we should draw our tiles with toppers
    local topper = true
    local tileset = math.random(20)
    local topperset = math.random(20)


    local keyGet = false
    local isLock = false
    local flagColor = math.random(4)
    local keyColor = math.random(4)

    -- insert blank tables into tiles for later access
    for x = 1, height do
        table.insert(tiles, {})
    end



    -- column by column generation instead of row; sometimes better for platformers
    for x = 1, width do
        local tileID = TILE_ID_EMPTY


        -- lay out the empty space
        for y = 1, 6 do
            table.insert(tiles[y],
                Tile(x, y, tileID, nil, tileset, topperset))
        end

        if x == 1 then
          for y = 7, height do
            table.insert(tiles[y],
            Tile(x, y, TILE_ID_GROUND, nil, tileset, topperset))

          end

        end


        -- chance to just be emptiness
          if math.random(7) == 1 then
            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, nil, tileset, topperset))
          end
        else
            tileID = TILE_ID_GROUND

            -- height at which we would spawn a potential jump block
            local blockHeight = 4

            for y = 7, height do
                table.insert(tiles[y],
                    Tile(x, y, tileID, y == 7 and topper or nil, tileset, topperset))
            end

            -- chance to generate a pillar
            if math.random(8) == 1 then
                blockHeight = 2

                -- chance to generate bush on pillar
                if math.random(8) == 1 then
                    table.insert(objects,
                        GameObject {
                            texture = 'bushes',
                            x = (x - 1) * TILE_SIZE,
                            y = (4 - 1) * TILE_SIZE,
                            width = 16,
                            height = 16,

                            -- select random frame from bush_ids whitelist, then random row for variance
                            frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                            collidable = false
                        }
                    )
                end

                -- pillar tiles
                tiles[5][x] = Tile(x, 5, tileID, topper, tileset, topperset)
                tiles[6][x] = Tile(x, 6, tileID, nil, tileset, topperset)
                tiles[7][x].topper = nil

            -- chance to generate bushes
            elseif math.random(8) == 1 then
                table.insert(objects,
                    GameObject {
                        texture = 'bushes',
                        x = (x - 1) * TILE_SIZE,
                        y = (6 - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,
                        frame = BUSH_IDS[math.random(#BUSH_IDS)] + (math.random(4) - 1) * 7,
                        collidable = false
                    }
                )
            end

            --spawn lock OF THE SAME COLOR
            if math.random(10) == 1 and not isLock then

              consumable = false
              isLock = true

              if keyGet then
                consumable = true
              end

                table.insert(objects,

                GameObject {
                  texture = 'keys_and_locks',
                  x = (x - 1) * TILE_SIZE,
                  y = (blockHeight - 1) * TILE_SIZE,
                  width = 16,
                  height = 16,
                  -- make it the same color as key
                  frame = keyColor + 4,
                  collidable = true,
                  consumable = true,
                  solid = false,

                  -- collision function spawns flag

                  onConsume = function(player, object)

                    if keyGet then

                      gSounds['pickup']:play()
                      player.score = player.score + 1000

                      --make flag ONLY IF KEY IS COLLECTED

                      table.insert(objects,

                      GameObject {
                        texture = 'poles',
                        x = (levelSize - 2) * TILE_SIZE,
                        y = (3) * TILE_SIZE,
                        width = 16,
                        height = 128,
                        -- make it the same color as flag
                        frame = flagColor,
                        collidable = true,
                        consumable = true,
                        solid = false,

                        onConsume = function(player, object)
                            gSounds['pickup']:play()
                            player.score = player.score + 1000
                            levelSize = levelSize + 10
                            score = player.score
                                gStateMachine:change('play')

                          end

                      }
                    )
                  end
                    table.insert(objects,

                    GameObject {
                      texture = 'flags',
                      x = (levelSize - 1.5) * TILE_SIZE,
                      y = (3) * TILE_SIZE,
                      width = 16,
                      height = 128,
                      -- make it the same color as pole
                      frame = flagColor + 4,
                      collidable = false,
                      consumable = false,
                      solid = false
                    }
                    )



                  end

                }
              )

              end

            -- chance to spawn a block
            if math.random(10) == 1 then
                table.insert(objects,

                    -- jump block
                    GameObject {
                        texture = 'jump-blocks',
                        x = (x - 1) * TILE_SIZE,
                        y = (blockHeight - 1) * TILE_SIZE,
                        width = 16,
                        height = 16,

                        -- make it a random variant
                        frame = math.random(#JUMP_BLOCKS),
                        collidable = true,
                        hit = false,
                        solid = true,

                        -- collision function takes itself
                        onCollide = function(obj)

                            -- spawn a gem if we haven't already hit the block
                            if not obj.hit then

                                -- chance to spawn gem, not guaranteed
                                if math.random(5) == 1 then

                                    -- maintain reference so we can set it to nil
                                    local gem = GameObject {
                                        texture = 'gems',
                                        x = (x - 1) * TILE_SIZE,
                                        y = (blockHeight - 1) * TILE_SIZE - 4,
                                        width = 16,
                                        height = 16,
                                        frame = math.random(#GEMS),
                                        collidable = true,
                                        consumable = true,
                                        solid = false,

                                        -- gem has its own function to add to the player's score
                                        onConsume = function(player, object)
                                            gSounds['pickup']:play()
                                            player.score = player.score + 100
                                          end
                                    }

                                    -- make the gem move up from the block and play a sound
                                    Timer.tween(0.1, {
                                        [gem] = {y = (blockHeight - 2) * TILE_SIZE}
                                    })
                                    gSounds['powerup-reveal']:play()

                                    table.insert(objects, gem)



                                  else
                                    -- chance to spawn key, IF gem not spawned
                                    if math.random(7) == 1 and not keyGet then

                                      local key = GameObject {
                                          texture = 'keys_and_locks',
                                          x = (x - 1) * TILE_SIZE,
                                          y = (blockHeight - 1) * TILE_SIZE - 4,
                                          width = 16,
                                          height = 16,
                                          frame = keyColor,
                                          collidable = true,
                                          consumable = true,
                                          solid = false,

                                          onConsume = function(object)
                                              gSounds['pickup']:play()
                                              keyGet = true
                                          end
                                      }

                                      -- make the key move up from the block and play a sound
                                      Timer.tween(0.1, {
                                          [key] = {y = (blockHeight - 2) * TILE_SIZE}
                                      })
                                      gSounds['powerup-reveal']:play()

                                      table.insert(objects, key)

                                    end
                                end

                                obj.hit = true
                            end

                            gSounds['empty-block']:play()
                        end
                    }
                )
            end
        end
    end

    local map = TileMap(width, height)
    map.tiles = tiles

    return GameLevel(entities, objects, map)
end
