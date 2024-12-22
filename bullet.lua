function NewBullet(isShotByPlayer ,x, y, angle, xDirection, yDirection, speed, damage)
    local size = 4
    return {
        isShotByPlayer = isShotByPlayer,
        x = x,
        y = y,
        size = size,
        angle = angle,
        xDirection = xDirection,
        yDirection = yDirection,
        speed = speed,
        damage = damage,
        Draw = function (self)
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("fill", self.x, self.y, self.size)
            DrawHitbox({self:GetHitbox()})
        end,
        Move = function (self)

            local dx = math.sin(self.angle)*self.speed * self.xDirection
            local dy = math.cos(self.angle)*self.speed * self.yDirection

            self.x = self.x + dx * DeltaTime
            self.y = self.y + dy * DeltaTime
        end,
        UpdateState = function (self)
            if IsOnTheEdge(self.x, self.y, self.size) then
                table.insert(BulletsToDelete, self)
            end
        end,
        GetHitbox = function (self)
            return self.x - size/2, self.y - size/2, size, size
        end
    }
end