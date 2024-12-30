function NewBullet(isShotByPlayer, x, y, angle, speed, damage)
    local size = 5
    return {
        isAlive = true,
        isShotByPlayer = isShotByPlayer,
        x = x,
        y = y,
        size = size,
        angle = angle,
        speed = speed,
        damage = damage,
        Draw = function (self)
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("fill", self.x, self.y, self.size)
            DrawHitbox({self:GetHitbox()})
        end,
        Move = function (self)

            local dx = math.cos(self.angle)*self.speed
            local dy = math.sin(self.angle)*self.speed

            self.x = self.x + dx * DeltaTime * 60
            self.y = self.y + dy * DeltaTime * 60
        end,
        UpdateState = function (self)
            if IsOnTheEdge(self.x, self.y, self.size) then
                self.isAlive = false
            end
        end,
        GetHitbox = function (self)
            return self.x - size/2, self.y - size/2, size, size
        end
    }
end