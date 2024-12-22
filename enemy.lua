function NewEnemy(hp, speed, x, y)

    local size = 30

    return {
        hp = hp,
        speed = speed,
        x = x,
        y = y,
        angle = 0,
        Draw = function (self)
            love.graphics.setLineWidth(5)
            local transform = love.math.newTransform(self.x, self.y, self.angle)

            love.graphics.applyTransform(transform)
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("line", -size/2, -size/2, size, size)
            love.graphics.applyTransform(transform:inverse())
            DrawHitbox({self:GetHitbox()})
            
        end,
        Move = function (self)
            local newAngle = math.asin(math.abs((Player.x - self.x)/math.sqrt((Player.x - self.x)^2 + (Player.y - self.y)^2)))

            self.angle = lerp(self.angle, newAngle, 0.1)

            local dx = math.sin(self.angle)*self.speed
            local dy = math.cos(self.angle)*self.speed

            if Player.x < self.x then
                dx = dx * -1
            end
            if Player.y < self.y then
                dy = dy * -1
            end

            self.x = self.x + dx * DeltaTime * 60
            self.y = self.y + dy * DeltaTime * 60
        end,
        GetHitbox = function (self)
            return self.x - size/2, self.y - size/2, size, size
        end
    }
end