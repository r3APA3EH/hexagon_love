function Pickupable(x, y, PickupFunction, lifetime)
    
    return
    {
    x = x,
    y = y,
    lifetime = lifetime,
    timeLived = 0,
    size = 30,
    isAlive = true,
    PickupFunction = PickupFunction,
    GetHitbox = function (self)
        return self.x - self.size/2, self.y - self.size/2, self.size, self.size
    end,
    Draw = function (self)
        love.graphics.circle("fill", self.x, self.y, self.size/2)
    end,
    UpdateState = function (self)
        self.timeLived = self.timeLived + DeltaTime
        if self.lifetime ~= -1 and self.timeLived >= self.lifetime then
            self.isAlive = false
            return
        end

        local x1,y1,w1,h1 = self:GetHitbox()
        local x2,y2,w2,h2 = Player:GetHitbox()
        if CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2) then
            self.isAlive = false
            self.PickupFunction()
        end
    end
    }
end