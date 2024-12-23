function lerp(a,b,t) return a + (b-a) * t end

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end
function DrawHitbox(hitbox)
    if not ShowHitboxes then return end

    love.graphics.setColor(0, 1, 0)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", unpack(hitbox))
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

    for i=1, #BulletsToDelete do
        DestroyObjectByIndex(Bullets, IndexOf(Bullets, BulletsToDelete[i]))
    end

    for i=1, #EnemiesToDelete do
        DestroyObjectByIndex(Enemies, IndexOf(Enemies, EnemiesToDelete[i]))
    end
end