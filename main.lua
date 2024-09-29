Object = require "lib.classic.classic"
json = require "lib.dkjson.dkjson"
require "isometric"

-- Load the grid
function love.load()
    grid = IsometricGrid("blue_tile.png", {
        gridFile = "grid.json"
    })
end

function love.keypressed(key, scancode, isrepeat)
    grid:keypressed(key, scancode, isrepeat)
end

function love.mousepressed(x, y, button, istouch)
    grid:mousepressed(x, y, button, istouch)
end

-- Update function to detect hover
function love.update(dt)
    grid:update(dt)
end

function love.draw()
    grid:draw()
end