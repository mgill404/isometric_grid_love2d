local tile = love.graphics.newImage("blue_tile.png", { dpiscale = 1 })


-- Grid and tile settings
local tileWidth = tile:getWidth()
local tileHeight = tileWidth/2
local gridWidth = 5
local gridHeight = 5
local tiles = {}
local hoveredTile = { x = -1, y = -1 } -- Variable to store hovered tile coordinates
local mouseEvent = nil

local spritesOn = false
local gridOn = true
local centerDot = true

function love.keypressed(key, scancode, isrepeat)
    if key == "1" then
       spritesOn = not spritesOn
    end
    if key == "2" then
        gridOn = not gridOn
     end
     if key == "3" then
        centerDot = not centerDot
     end
 end

-- Convert Cartesian grid to isometric coordinates
function toIso(x, y)
    return toIsoX(x, y), toIsoY(x, y)
end

function toIsoX(x, y)
    return (x - y) * (tileWidth / 2)
end

function toIsoY(x, y)
    return (x + y) * (tileHeight / 2) - tileHeight
end

-- Convert screen (isometric) coordinates back to grid coordinates
function toGrid(isoX, isoY)
    isoY = isoY+tileHeight
    local x = (isoY / (tileHeight / 2) + isoX / (tileWidth / 2)) / 2
    local y = (isoY / (tileHeight / 2) - isoX / (tileWidth / 2)) / 2
    return math.floor(x), math.floor(y)
end

function centerX()

end

-- Load the grid
function love.load()
    local centerX = gridWidth/2 + 1
    local centerY = gridHeight/2 + 1
    x_offset = game_w/2 - toIsoX(centerX, centerY)
    y_offset = game_h/2 - toIsoY(centerX, centerY)

    for i = 1, gridWidth do
        tiles[i] = {}
        for j = 1, gridHeight do
            tiles[i][j] = { x = i, y = j, color = { 1, 1, 1 }, enabled = false } -- white by default
        end
    end
end

function love.mousepressed(x, y, button, istouch)
    mouseEvent = {x = x, y = y, button = button}
end

-- Update function to detect hover
function love.update(dt)
    local mouseX, mouseY = love.mouse.getPosition()
    local gridX, gridY = toGrid(mouseX - x_offset, mouseY - y_offset) -- Offset for centering the grid

    -- Check if the mouse is within bounds
    if gridX >= 1 and gridX <= gridWidth and gridY >= 1 and gridY <= gridHeight then
        if mouseEvent then
            tiles[gridX][gridY].enabled = not tiles[gridX][gridY].enabled
            mouseEvent = nil
        end
        hoveredTile.x, hoveredTile.y = gridX, gridY
    else
        hoveredTile.x, hoveredTile.y = -1, -1 -- No tile hovered
    end
end

-- Draw the grid
function love.draw()
    if spritesOn then
        love.graphics.setColor({1,1,1})
        for i = 1, gridWidth do
            for j = 1, gridHeight do
                if tiles[i][j].enabled then
                    local isoX, isoY = toIso(i, j)
                    love.graphics.draw(tile, x_offset + isoX - tileWidth/2, y_offset + isoY - tileHeight/2)
                end
            end
        end
    end

    for i = 1, gridWidth do
        for j = 1, gridHeight do
            local isoX, isoY = toIso(i, j)
            if i == hoveredTile.x and j == hoveredTile.y then
                love.graphics.setColor({1,1,1,0.3})
                love.graphics.polygon('fill',
                    x_offset + isoX, y_offset + isoY, -- Offset to center the grid
                    x_offset + isoX + tileWidth / 2, y_offset + isoY + tileHeight / 2,
                    x_offset + isoX, y_offset + isoY + tileHeight,
                    x_offset + isoX - tileWidth / 2, y_offset + isoY + tileHeight / 2)
                love.graphics.setColor({1,1,1})
                love.graphics.print(tostring(i).." "..tostring(j), x_offset + isoX, y_offset + isoY + tileHeight/2)
            end
            if gridOn then
                love.graphics.setColor({1,1,1})
                love.graphics.polygon('line',
                    x_offset + isoX, y_offset + isoY, -- Offset to center the grid
                    x_offset + isoX + tileWidth / 2, y_offset + isoY + tileHeight / 2,
                    x_offset + isoX, y_offset + isoY + tileHeight,
                    x_offset + isoX - tileWidth / 2, y_offset + isoY + tileHeight / 2)
            end
        end
    end

    if centerDot then
        love.graphics.circle('fill', game_w/2, game_h/2, 3)
    end
    
    love.graphics.print('mouse x: '..tostring(love.mouse.getX())..' y: '..tostring(love.mouse.getY()))
end