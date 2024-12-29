function AbstractEnemy(x, y, hp, speed)

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
    end,
    MoveFunctions = {
        -- должны возвращать dx и dy
        AvoidCollisions = function (self)
            local dx, dy = 0, 0
            for i=1, #Enemies do
                if Enemies[i].x == self.x then goto continue end
                if Enemies[i].y == self.y then goto continue end
                local distanceToOthers = math.sqrt((Enemies[i].x - self.x)^2 + (Enemies[i].y - self.y)^2)
                if distanceToOthers > self.size*3 then goto continue end
                local newAngleToEnemy = math.asin(math.abs((Enemies[i].x - self.x)/distanceToOthers))
    
                local ddx = -math.sin(newAngleToEnemy)*self.speed* 7/(distanceToOthers - self.size*1.1)
                local ddy = -math.cos(newAngleToEnemy)*self.speed* 7/(distanceToOthers - self.size*1.1)
    
                if Enemies[i].x < self.x then
                    ddx = ddx * -1
                end
                if Enemies[i].y < self.y then
                    ddy = ddy * -1
                end
                
                dx = dx + ddx
                dy = dy + ddy
    
                ::continue::
            end
            local newAngle = math.asin(math.abs((Player.x - self.x)/self.distanceToPlayer))
    
            local newAngleToPlayer = lerp(self.angle, newAngle, 0.1)
            local ddx = - math.sin(newAngleToPlayer)*self.speed * 7/(self.distanceToPlayer - self.size*0.8)
            local ddy = - math.cos(newAngleToPlayer)*self.speed * 7/(self.distanceToPlayer - self.size*0.8)
    
            if Player.x < self.x then
                ddx = ddx * -1
            end
            if Player.y < self.y then
                ddy = ddy * -1
            end
            
            dx = dx + ddx
            dy = dy + ddy
            return dx, dy
        end,
        PushToFrame = function (self)
            if IsOnTheEdge(self.x, self.y, self.size) then
                if self.x - self.size/2 < Camera.x then
                    self.x = Camera.x + self.size/2
                elseif self.x + self.size/2 > Camera.x + love.graphics.getWidth() then
                    self.x = Camera.x + love.graphics.getWidth() - self.size/2
                end
                if self.y - self.size/2 < Camera.y then
                    self.y = Camera.y + self.size/2
                elseif self.y + self.size/2 > Camera.y + love.graphics.getHeight() then
                    self.y = Camera.y + love.graphics.getHeight() - self.size/2
                end
            end
            return 0, 0
        end,
    },
    Move = function (self)
        if self.timeFromDeath > 0 and self.timeFromDeath < 0.5 then return end
        self.distanceToPlayer = math.sqrt((Player.x - self.x)^2 + (Player.y - self.y)^2)
        local dx, dy = 0, 0
        for functionName, functionLogic in pairs(self.MoveFunctions) do
            local ddx, ddy = functionLogic(self)
            -- if functionName == "AvoidCollisions" and self.size == 60 then print(ddx, ddy) end
            dx = dx + ddx
            dy = dy + ddy
        end

        self.sx = self.sx * 0.5 + dx
        self.sy = self.sy * 0.5 + dy

        self.x = self.x + self.sx * DeltaTime * 60
        self.y = self.y + self.sy * DeltaTime * 60
    end
    }
end