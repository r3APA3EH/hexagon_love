require("Enemies.AbstractEnemy")

function DumbEnemy(x, y, hp, speed)
    local sizeType = RandomChoice({"small", "small", "small", "small", "big"})
    if sizeType == "big" then
        hp = hp *2
        speed = speed * 0.5
    end
    local ParentObject = AbstractEnemy(x, y, hp, speed)

    local newMoveFunctions = {
        MoveToPlayer = function (self)
            local dx, dy = 0, 0

            self.angle = math.atan2((Player.y - self.y), (Player.x - self.x))

            local ddx = math.cos(self.angle)*self.speed
            local ddy = math.sin(self.angle)*self.speed
            
            dx = dx + ddx
            dy = dy + ddy

            return dx, dy
        end,
    }
    MergeTables(ParentObject.MoveFunctions, newMoveFunctions)

    local segments = RandomChoice({3, 4})

    local color = RandomChoice({{1, 0.639, 0}, {1, 0, 0}})

    local size = 30
    if sizeType == "big" then size = 60 end

    local shape = function ()
        love.graphics.setLineWidth(5)
        love.graphics.setColor(color)
        local lineWidth = love.graphics.getLineWidth()
        love.graphics.circle("line", (size + lineWidth)/2, (size + lineWidth)/2, size/2, segments)
    end

    local sprite = DrawFunctionToImage(size, size, shape)


    local uniqueBehaviour =
    {
    sprite = sprite,
    size = size,
    segments = segments,
    color = color,
    
    }

    return MergeTables(ParentObject, uniqueBehaviour)
end