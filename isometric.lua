IsometricGrid = Object:extend()

-- center x,y: location to place the center of the grid
-- enabled_tiles: a 2D table showing which tiles to enable
function IsometricGrid:new(tile_file, cells_w, cells_h, center_x, center_y)
    self.tile = love.graphics.newImage(tile_file, { dpiscale = 1 })
    self.tileWidth = self.tile:getWidth()
    self.tileHeight = self.tileWidth/2
    
    self.gridWidth = cells_w
    self.gridHeight = cells_h
    
    self.offset_x = center_x - self:toIsoX(self.gridWidth/2 + 1, self.gridHeight/2 + 1)
    self.offset_y = center_y - self:toIsoY(self.gridWidth/2 + 1, self.gridHeight/2 + 1)

    self.hoveredTile = { x = -1, y = -1 }
    
    self.mouseClick = false

    self.tiles = {}
    for i = 1, self.gridWidth do
        self.tiles[i] = {}
        for j = 1, self.gridHeight do
            self.tiles[i][j] = { enabled = true }
        end
    end

    -- some debugging stuff
    self.spritesOn = true
    self.gridOn = true
    self.centerDot = true
end

function IsometricGrid:keypressed(key, scancode, isrepeat)
    if key == "1" then
       self.spritesOn = not self.spritesOn
    end
    if key == "2" then
        self.gridOn = not self.gridOn
     end
     if key == "3" then
        self.centerDot = not self.centerDot
     end
 end

function IsometricGrid:mousepressed(x, y, button, istouch)
    self.mouseClick = true
end

function IsometricGrid:detectHover()
    local mx, my = love.mouse.getPosition()
    local gridX, gridY = self:toGrid(mx - self.offset_x, my - self.offset_y) -- Offset for centering the grid

    -- Check if the mouse is within bounds
    if gridX >= 1 and gridX <= self.gridWidth and gridY >= 1 and gridY <= self.gridHeight then
        if self.mouseClick then
            self.tiles[gridX][gridY].enabled = not self.tiles[gridX][gridY].enabled
            self.mouseClick = nil
        end
        self.hoveredTile.x, self.hoveredTile.y = gridX, gridY
    else
        self.hoveredTile.x, self.hoveredTile.y = -1, -1 -- No tile hovered
    end
end

function IsometricGrid:update(dt)
    self:detectHover()
end

function IsometricGrid:draw()
    if self.spritesOn then
        love.graphics.setColor({1,1,1})
        for i = 1, self.gridWidth do
            for j = 1, self.gridHeight do
                if self.tiles[i][j].enabled then
                    local isoX, isoY = self:toIso(i, j)
                    love.graphics.draw(self.tile, self.offset_x + isoX - self.tileWidth/2, self.offset_y + isoY - self.tileHeight/2)
                end
            end
        end
    end

    for i = 1, self.gridWidth do
        for j = 1, self.gridHeight do
            local isoX, isoY = self:toIso(i, j)
            -- highlight hovered tile
            if i == self.hoveredTile.x and j == self.hoveredTile.y then
                love.graphics.setColor({1,1,1,0.3})
                love.graphics.polygon('fill',
                    self.offset_x + isoX, self.offset_y + isoY, -- Offset to center the grid
                    self.offset_x + isoX + self.tileWidth / 2, self.offset_y + isoY + self.tileHeight / 2,
                    self.offset_x + isoX, self.offset_y + isoY + self.tileHeight,
                    self.offset_x + isoX - self.tileWidth / 2, self.offset_y + isoY + self.tileHeight / 2)
                love.graphics.setColor({1,1,1})
                love.graphics.print(tostring(i).." "..tostring(j), self.offset_x + isoX, self.offset_y + isoY + self.tileHeight/2)
            end

            -- draw grid with lines
            if self.gridOn then
                love.graphics.setColor({1,1,1})
                love.graphics.polygon('line',
                    self.offset_x + isoX, self.offset_y + isoY, -- Offset to center the grid
                    self.offset_x + isoX + self.tileWidth / 2, self.offset_y + isoY + self.tileHeight / 2,
                    self.offset_x + isoX, self.offset_y + isoY + self.tileHeight,
                    self.offset_x + isoX - self.tileWidth / 2, self.offset_y + isoY + self.tileHeight / 2)
            end
        end
    end

    if self.centerDot then
        love.graphics.circle('fill', love.graphics.getWidth()/2, love.graphics.getHeight()/2, 3)
    end
end


--- Coordinate Conversions

function IsometricGrid:toIso(x, y)
    return self:toIsoX(x, y), self:toIsoY(x, y)
end

function IsometricGrid:toIsoX(x, y)
    return (x - y) * (self.tileWidth / 2)
end

function IsometricGrid:toIsoY(x, y)
    return (x + y) * (self.tileHeight / 2) - self.tileHeight
end

-- Convert screen (isometric) coordinates back to grid coordinates
function IsometricGrid:toGrid(isoX, isoY)
    isoY = isoY+self.tileHeight
    local x = (isoY / (self.tileHeight / 2) + isoX / (self.tileWidth / 2)) / 2
    local y = (isoY / (self.tileHeight / 2) - isoX / (self.tileWidth / 2)) / 2
    return math.floor(x), math.floor(y)
end