function AbstractEnemy(x, y, size, hp, speed)

    local deathEffect = NewDeathEffectParticleSystem()
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
    deathEffect = deathEffect,
    GetHitbox = function (self)
        return self.x - self.size/2, self.y - self.size/2, self.size, self.size
    end,
    UpdateState = function (self)
        self.deathEffect:moveTo(self.x, self.y)
        self.deathEffect:update(DeltaTime)
        if self.timeFromDeath > 0 then
            self.timeFromDeath = self.timeFromDeath + DeltaTime
        end
        if self.timeFromDeath >= 0.5 then
            self.isAlive = false
            return
        end
        if 0 < self.timeFromDeath and self.timeFromDeath <= 0.5 then
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
                    self.deathEffect:start()
                    self.deathEffect:emit(16)
                    self.timeFromDeath = DeltaTime
                end      
                self.collideCooldown = self.collideCooldown + DeltaTime
                break
            end
        end   
    end
    }
end