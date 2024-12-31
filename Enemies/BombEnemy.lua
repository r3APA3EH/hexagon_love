require("Enemies.AbstractEnemy")

function BombEnemy(x, y, hp, speed)
    local ParentObject = AbstractEnemy(x, y, hp, speed)

    local newMoveFunctions = {
        PushToFrame = function (self)
            return 0, 0
        end,
        MoveToBangSpot = function (self)
            local dx, dy = 0, 0

            self.angle = math.atan2((self.bangSpot.y - self.y), (self.bangSpot.x - self.x))

            local ddx = math.cos(self.angle)*self.speed
            local ddy = math.sin(self.angle)*self.speed
            
            dx = dx + ddx
            dy = dy + ddy

            return dx, dy
        end,
    }
    local newUpdateFunctions = {
        Bang = function (self)
            local distanceToBangSpot = math.sqrt((self.bangSpot.y - self.y)^2 + (self.bangSpot.x - self.x)^2)
            if distanceToBangSpot < self.size/2 then
                self.isAlive = false
                for i=1, 10 do
                    table.insert(Bullets, #Bullets + 1, NewBullet(false, self.x, self.y, 5, math.rad(36*i), (math.random()+0.5)*10, 1))
                end
            end
        end
    }
    MergeTables(ParentObject.MoveFunctions, newMoveFunctions)
    MergeTables(ParentObject.UpdateFunctions, newUpdateFunctions)


    local size = 75

    local color = {1, 0, 0.486}

    local shape = function (self)
        love.graphics.setLineWidth(5)
        love.graphics.setColor(color)
        local lineWidth = love.graphics.getLineWidth()
        love.graphics.circle("line", (size + lineWidth)/2, (size + lineWidth)/2, size/2, 6)
    end

    local sprite = DrawFunctionToImage(size, size, shape)

    local uniqueBehaviour =
    {
    size = size,
    sprite = sprite,
    bangSpot = {x = math.random(love.graphics.getWidth()) + Camera.x, y = math.random(love.graphics.getHeight()) + Camera.y}
    }
    return MergeTables(ParentObject, uniqueBehaviour)
end