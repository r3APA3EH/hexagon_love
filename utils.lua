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
    local rightEdge = x + size/2 >= love.graphics.getWidth()
    local leftEdge = x - size/2 <= 0
    local bottomEdge = y + size/2 >= love.graphics.getHeight()
    local topEdge = y - size/2 <= 0
    if rightEdge or leftEdge or topEdge or bottomEdge then return true end
    return false
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
    for i=1, #BulletsToDelete do
        DestroyObjectByIndex(Bullets, IndexOf(Bullets, BulletsToDelete[i]))
    end
    BulletsToDelete = {}
end