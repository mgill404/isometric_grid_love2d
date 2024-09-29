Object = require "lib.classic.classic"
require "isometric"

-- Load the grid
function love.load()
    grid = IsometricGrid("blue_tile.png")
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

-- Draw the grid
function love.draw()
    grid:draw()
    
    love.graphics.print('mouse x: '..tostring(love.mouse.getX())..' y: '..tostring(love.mouse.getY()))
end