IsometricGrid = Object:extend()

-- options {
--      gridWidth:
--      gridHeight:
--      
-- 
-- }
-- center x,y: location to place the center of the grid
-- enabled_tiles: a 2D table showing which tiles to enable
function IsometricGrid:new(tile_file, options)
    options = options or {}

    self.tile = love.graphics.newImage(tile_file, { dpiscale = 1 })
    self.tileWidth = self.tile:getWidth()
    self.tileHeight = self.tileWidth/2
    
    self.gridWidth = options.gridWidth or 2
    self.gridHeight = options.gridHeight or 2

    self.centerX = options.centerX or love.graphics.getWidth()/2
    self.centerY = options.centerY or love.graphics.getHeight()/2
    self:center()
    
    self.offsetX = self.centerX - self:toIsoX(self.gridWidth/2 + 1, self.gridHeight/2 + 1)
    self.offsetY = self.centerY - self:toIsoY(self.gridWidth/2 + 1, self.gridHeight/2 + 1)

    self.hovered = { x = -1, y = -1 }
    
    self.mouseClick = false

    self.tiles = {}
    for i = 1, self.gridWidth do
        self.tiles[i] = {}
        for j = 1, self.gridHeight do
            self.tiles[i][j] = { enabled = true }
        end
    end

    -- some debugging options
    self.spritesOn = options.spritesOn or true
    self.gridOn = options.gridOn or false
    self.centerDot = options.centerDot or false
    self.gridIndexOn = options.gridIndexOn or false
end

function IsometricGrid:center()
    self.offsetX = self.centerX - self:toIsoX(self.gridWidth/2 + 1, self.gridHeight/2 + 1)
    self.offsetY = self.centerY - self:toIsoY(self.gridWidth/2 + 1, self.gridHeight/2 + 1)
end

function IsometricGrid:removeRow()
    if self.gridWidth == 1 then return end
    self.gridWidth = self.gridWidth - 1
    table.remove(self.tiles)
    self:center()
end

function IsometricGrid:removeColumn()
    if self.gridHeight == 1 then return end
    self.gridHeight = self.gridHeight - 1
    for i = 1, self.gridWidth do
        table.remove(self.tiles[i])
    end
    self:center()
end

function IsometricGrid:addRow()
    self.gridWidth = self.gridWidth + 1
    self.tiles[self.gridWidth] = {}
    for j = 1, self.gridHeight do
        self.tiles[self.gridWidth][j] = { enabled = true }
    end
    self:center()
end

function IsometricGrid:addColumn()
    self.gridHeight = self.gridHeight + 1
    for i = 1, self.gridWidth do
        self.tiles[i][self.gridHeight] = { enabled = true }
    end
    self:center()
end

function IsometricGrid:keypressed(key, scancode, isrepeat)
    if key == "1" then
        self.spritesOn = not self.spritesOn
    elseif key == "2" then
        self.gridOn = not self.gridOn
    elseif key == "3" then
        self.centerDot = not self.centerDot
    elseif key == "4" then
        self:addRow()
    elseif key == "5" then
        self:removeRow()
    elseif key == "6" then
        self:addColumn()
    elseif key == "7" then
        self:removeColumn()
    end
 end

function IsometricGrid:mousepressed(x, y, button, istouch)
    self.mouseClick = true
end

function IsometricGrid:detectHover()
    local mx, my = love.mouse.getPosition()
    local gridX, gridY = self:toGrid(mx - self.offsetX, my - self.offsetY) -- Offset for centering the grid

    -- Check if the mouse is within bounds
    if gridX >= 1 and gridX <= self.gridWidth and gridY >= 1 and gridY <= self.gridHeight then
        if self.mouseClick then
            self.tiles[gridX][gridY].enabled = not self.tiles[gridX][gridY].enabled
            self.mouseClick = nil
        end
        self.hovered.x, self.hovered.y = gridX, gridY
    else
        self.hovered.x, self.hovered.y = -1, -1 -- No tile hovered
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
                    love.graphics.draw(self.tile, self.offsetX + isoX - self.tileWidth/2, self.offsetY + isoY - self.tileHeight/2)
                end
            end
        end
    end

    for i = 1, self.gridWidth do
        for j = 1, self.gridHeight do
            local isoX, isoY = self:toIso(i, j)
            -- highlight hovered tile
            if i == self.hovered.x and j == self.hovered.y then
                love.graphics.setColor({1,1,1,0.3})
                love.graphics.polygon('fill',
                    self.offsetX + isoX, self.offsetY + isoY, -- Offset to center the grid
                    self.offsetX + isoX + self.tileWidth / 2, self.offsetY + isoY + self.tileHeight / 2,
                    self.offsetX + isoX, self.offsetY + isoY + self.tileHeight,
                    self.offsetX + isoX - self.tileWidth / 2, self.offsetY + isoY + self.tileHeight / 2)
                love.graphics.setColor({1,1,1})
                if self.gridIndexOn then
                    love.graphics.print(tostring(i).." "..tostring(j), self.offsetX + isoX, self.offsetY + isoY + self.tileHeight/2)
                end
            end

            -- draw grid with lines
            if self.gridOn then
                love.graphics.setColor({1,1,1})
                love.graphics.polygon('line',
                    self.offsetX + isoX, self.offsetY + isoY, -- Offset to center the grid
                    self.offsetX + isoX + self.tileWidth / 2, self.offsetY + isoY + self.tileHeight / 2,
                    self.offsetX + isoX, self.offsetY + isoY + self.tileHeight,
                    self.offsetX + isoX - self.tileWidth / 2, self.offsetY + isoY + self.tileHeight / 2)
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