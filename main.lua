local dirt = love.graphics.newImage("dirt.png", { dpiscale = 0.5 })


-- Grid and tile settings
local tileWidth = dirt:getWidth()
local tileHeight = tileWidth/2
local gridWidth = 5
local gridHeight = 5
local tiles = {}
local hoveredTile = { x = -1, y = -1 } -- Variable to store hovered tile coordinates

-- Convert Cartesian grid to isometric coordinates
function toIso(x, y)
    local isoX = (x - y) * (tileWidth / 2)
    return isoX, toIsoY(x, y)
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

-- Load the grid
function love.load()
    x_offset = game_w/2
    -- only works for squares
    local centerX = gridWidth/2 + 1
    local centerY = gridHeight/2 + 1
    y_offset = game_h/2 - toIsoY(centerX, centerY)

    for i = 1, gridWidth do
        tiles[i] = {}
        for j = 1, gridHeight do
            tiles[i][j] = { x = i, y = j, color = { 1, 1, 1 } } -- white by default
        end
    end
end

-- Update function to detect hover
function love.update(dt)
    local mouseX, mouseY = love.mouse.getPosition()
    local gridX, gridY = toGrid(mouseX - x_offset, mouseY - y_offset) -- Offset for centering the grid

    -- Check if the mouse is within bounds
    if gridX >= 1 and gridX <= gridWidth and gridY >= 1 and gridY <= gridHeight then
        hoveredTile.x, hoveredTile.y = gridX, gridY
    else
        hoveredTile.x, hoveredTile.y = -1, -1 -- No tile hovered
    end
end

-- Draw the grid
function love.draw()
    for i = 1, gridWidth do
        for j = 1, gridHeight do
            local isoX, isoY = toIso(i, j)
            love.graphics.draw(dirt, x_offset + isoX - tileWidth/2, y_offset + isoY - tileHeight/2)
        end
    end

    for i = 1, gridWidth do
        for j = 1, gridHeight do
            local isoX, isoY = toIso(i, j)
            local tileColor = tiles[i][j].color
            love.graphics.setColor(tileColor)

            local mode = 'line'
            if i == hoveredTile.x and j == hoveredTile.y then
                mode = "fill"
            end
            
            -- Fill the hovered tile
            love.graphics.polygon(mode,
                x_offset + isoX, y_offset + isoY, -- Offset to center the grid
                x_offset + isoX + tileWidth / 2, y_offset + isoY + tileHeight / 2,
                x_offset + isoX, y_offset + isoY + tileHeight,
                x_offset + isoX - tileWidth / 2, y_offset + isoY + tileHeight / 2)
        end
    end

    love.graphics.circle('fill', game_w/2, game_h/2, 3)
    love.graphics.print('mouse x: '..tostring(love.mouse.getX())..' y: '..tostring(love.mouse.getY()))
end