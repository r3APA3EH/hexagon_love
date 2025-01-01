function lerp(a,b,t) return a + (b-a) * t end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end

function IsHoveredByMouse(x1,y1,x2,y2)
    local mx, my = love.mouse.getPosition()
    return x1 <= mx and mx <= x2 and y1 <= my and my <= y2
end

function DrawHitbox(hitbox)
    if not ShowHitboxes then return end

    love.graphics.setColor(0, 1, 0)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", unpack(hitbox))
end

function DrawSpeed(x, y, sx, sy)
    if not ShowHitboxes then return end

    love.graphics.setColor(0, 1, 0)
    love.graphics.setLineWidth(2)
    love.graphics.line(x, y, (x + sx), (y + sy))
end

function IsOnTheEdge(x, y, size)
    local rightEdge = x + size/2 >= love.graphics.getWidth() + Camera.x
    local leftEdge = x - size/2 <= 0 + Camera.x
    local bottomEdge = y + size/2 >= love.graphics.getHeight() + Camera.y
    local topEdge = y - size/2 <= 0 + Camera.y

    return rightEdge or leftEdge or topEdge or bottomEdge
end

function DestroyObjectByIndex(space, pos)
    table.remove(space, pos)
end
function IndexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function DeleteRedundantObjects()
    local BulletsToDelete = {}
    local EnemiesToDelete = {}
    local PowerupsToDelete = {}

    for i=1, #Bullets do
        if not Bullets[i].isAlive then
            table.insert(BulletsToDelete, Bullets[i])
        end
    end

    for i=1, #Enemies do
        if not Enemies[i].isAlive then
            table.insert(EnemiesToDelete, Enemies[i])
        end
    end
    for i=1, #Powerups do
        if not Powerups[i].isAlive then
            table.insert(PowerupsToDelete, Powerups[i])
        end
    end

    for i=1, #BulletsToDelete do
        DestroyObjectByIndex(Bullets, IndexOf(Bullets, BulletsToDelete[i]))
    end

    for i=1, #EnemiesToDelete do
        DestroyObjectByIndex(Enemies, IndexOf(Enemies, EnemiesToDelete[i]))
    end
    for i=1, #PowerupsToDelete do
        DestroyObjectByIndex(Powerups, IndexOf(Powerups, PowerupsToDelete[i]))
    end
end
function MergeTables(first_table, second_table)
    for k,v in pairs(second_table) do first_table[k] = v end
    return first_table
end

function RandomChoice(table, c)
    -- print(Dump(table))
    -- print(Dump(c))
    if type(c) == "nil" then
        local n = math.random(#table)
        return table[n]
    end

    local chances = {}
    for key, value in ipairs(c) do
        chances[key] = value
    end

    


    local chancesSum = 0

    for key, value in ipairs(chances) do
        local chance = value
        chances[key] = chances[key] + chancesSum
        chancesSum = chancesSum + chance

    end

    local n = math.random(chancesSum)
    print(Dump(table))
    print(Dump(chances))
    print(n)
    for key, value in ipairs(chances) do
        if value >= n then
            return table[key]
        end
    end
    
end
function GetRandomSpotOnScreenPerimeter()
    local side = math.random(1,4)
    local x,y
    if side == 1 then
        x, y = 0, math.random(0, love.graphics.getHeight())
    elseif side == 2 then
        x, y = math.random(0, love.graphics.getWidth()), 0
    elseif side == 3 then
        x, y = love.graphics.getWidth(), math.random(0, love.graphics.getHeight())
    elseif side == 4 then
        x, y = math.random(0, love.graphics.getWidth()), love.graphics.getHeight()
    end
    x = x + Camera.x
    y = y + Camera.y
    return x, y
end

function Dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. Dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end
 

function love.graphics.setAlpha(alpha)
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(r, g, b, alpha)
end


function DrawFunctionToImage(width, height, drawFunction)
    local lineWidth = love.graphics.getLineWidth()
    local canvas = love.graphics.newCanvas(width + lineWidth, height + lineWidth)

    love.graphics.setCanvas(canvas)
    drawFunction()
    love.graphics.setCanvas()

    local image = love.graphics.newImage(canvas:newImageData())
    return image
    -- return canvas
end
function DrawFunctionToImageData(width, height, drawFunction)
    local lineWidth = love.graphics.getLineWidth()
    local canvas = love.graphics.newCanvas(width + lineWidth, height + lineWidth)

    love.graphics.setCanvas(canvas)
    drawFunction()
    love.graphics.setCanvas()

    local imageData = canvas:newImageData()
    return imageData
    -- return canvas
end