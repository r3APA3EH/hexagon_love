function AbstractEnemy(x, y, size, hp, speed)
    return
    {
    isAlive = true,
    timeFromDeath = 0,
    hp = hp,
    maxHp = hp,
    speed = speed,
    sx = 0,
    sy = 0,
    x = x,
    y = y,
    distanceToPlayer = 0,
    size = size,
    angle = 0,
    isColliding = false,
    collideCooldown = 0,
    saveTime = 0.1,
    GetHitbox = function (self)
        return self.x - self.size/2, self.y - self.size/2, self.size, self.size
    end,
    UpdateState = function (self)
        if self.timeFromDeath > 0 then
            self.timeFromDeath = self.timeFromDeath + DeltaTime
        end
        if self.timeFromDeath >= 0.5 then
            self.isAlive = false
        end
        if 0 < self.timeFromDeath and self.timeFromDeath < 0.5 then
            return
        end
        -- colliding
        if self.collideCooldown > 0 then
            self.collideCooldown = self.collideCooldown + DeltaTime
        end
        if self.collideCooldown >= self.saveTime then self.collideCooldown = 0 end
        for i=1, #Bullets do
            if 0 < self.collideCooldown and self.collideCooldown < self.saveTime then 
                self.isColliding = false 
                break
            end
            -- Просто передать 2 функции аргументами не получается. начинает жаловаться на то что w2 это nil
            local x1,y1,w1,h1 = self:GetHitbox()
            local x2,y2,w2,h2 = Bullets[i]:GetHitbox()
            self.isColliding = CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
            if self.isColliding then 
                -- Bullets[i].isAlive = false
                self.hp = self.hp - Bullets[i].damage
                if self.hp < 0 then self.hp = 0 end
                if self.hp == 0 then
                    ps:moveTo(self.x - Camera.x, self.y - Camera.y)
                    -- local t = {{unpack(self.color), 0}, self.color, 1, self.color, 0.5, self.color, 0}
                    -- ps:setColors({unpack(self.color), 0}, {unpack(self.color), 1}, {unpack(self.color), 0.5}, {unpack(self.color), 0})
                    ps:start()
                    ps:emit(16)
                    self.timeFromDeath = DeltaTime
                end      
                self.collideCooldown = self.collideCooldown + DeltaTime
                break
            end
        end   
    end
    }
end