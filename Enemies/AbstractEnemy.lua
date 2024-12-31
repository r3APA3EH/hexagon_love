function AbstractEnemy(x, y, hp, speed)
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
    color = {1, 1, 1},
    distanceToPlayer = 0,
    angle = 0,
    isColliding = false,
    collideCooldown = 0,
    saveTime = 0.1,
    deathEffect = NewDeathEffectParticleSystem(),
    GetHitbox = function (self)
        return self.x - self.size/2, self.y - self.size/2, self.size, self.size
    end,
    Draw = function (self)
        if self.timeFromDeath > 0 and self.timeFromDeath < 0.5 then return end

        local transform = love.math.newTransform(self.x, self.y, self.angle)

        love.graphics.setLineJoin("bevel")

        love.graphics.applyTransform(transform)
        love.graphics.setColor(self.color)
        love.graphics.setAlpha(0.5)
        love.graphics.draw(self.sprite, -self.sprite:getWidth()/2, -self.sprite:getHeight()/2)

        local maskHeight = self.size/2 - (self.size / self.maxHp * self.hp)
        if self.hp == self.maxHp then maskHeight = maskHeight - 8 end
        love.graphics.setScissor(0, -Camera.y + self.y + maskHeight, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(self.color)
        love.graphics.setAlpha(1)
        love.graphics.draw(self.sprite, -self.sprite:getWidth()/2, -self.sprite:getHeight()/2)
        
        if IndexOf(Enemies, self) <= Player.shotsNumber then
            love.graphics.setColor(0, 1, 0)
            love.graphics.setLineWidth(3)
            love.graphics.circle("line", 0, 0, self.size/1.7)
        end

        love.graphics.applyTransform(transform:inverse())
        love.graphics.setScissor()

        DrawSpeed(self.x, self.y, self.sx, self.sy)
        DrawHitbox({self:GetHitbox()})
    end,
    UpdateFunctions = {

    },
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
            if not Bullets[i].isShotByPlayer then goto continue end
            if 0 < self.collideCooldown and self.collideCooldown < self.saveTime then 
                self.isColliding = false 
                break
            end
            -- Просто передать 2 функции аргументами не получается. начинает жаловаться на то что w2 это nil
            local x1,y1,w1,h1 = self:GetHitbox()
            local x2,y2,w2,h2 = Bullets[i]:GetHitbox()
            self.isColliding = CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
            if self.isColliding then 
                self.hp = self.hp - Bullets[i].damage
                if self.hp < 0 then self.hp = 0 end
                if self.hp == 0 then
                    self.deathEffect:start()
                    self.deathEffect:emit(16)
                    self.timeFromDeath = DeltaTime
                    Powerups[#Powerups+1] = NewPowerup("random", self.x, self.y)
                end      
                self.collideCooldown = self.collideCooldown + DeltaTime
            end
            ::continue::
        end 
        for functionName, functionLogic in pairs(self.UpdateFunctions) do
            functionLogic(self)
        end
    end,
    MoveFunctions = {
        -- должны возвращать dx и dy
        AvoidCollisions = function (self)
            local dx, dy = 0, 0
            for i=0, #Enemies do
                local enemy
                if i == 0 then 
                    enemy = Player
                else
                    enemy = Enemies[i]
                end
                if enemy == self then goto continue end
                -- if enemy.x == self.x or enemy.y == self.y then print("same") end
                local distanceToOthers = math.sqrt((enemy.x - self.x)^2 + (enemy.y - self.y)^2)

                if i == 0 then 
                    distanceToOthers = distanceToOthers*2
                end
                if distanceToOthers > self.size*3 then goto continue end
                local newAngleToEnemy = math.atan2((enemy.y - self.y), (enemy.x - self.x))
    
                local ddx = -math.cos(newAngleToEnemy)*self.speed* 7/math.abs((distanceToOthers - self.size))*enemy.size/self.size
                local ddy = -math.sin(newAngleToEnemy)*self.speed* 7/math.abs((distanceToOthers - self.size))*enemy.size/self.size
                
                dx = dx + ddx
                dy = dy + ddy
    
                ::continue::
            end
            return dx, dy
        end,
        PushToFrame = function (self)
            local dx, dy = 0, 0
            if IsOnTheEdge(self.x, self.y, self.size) then
                if self.x - self.size/2 < Camera.x then
                    dx = Camera.x - (self.x - self.size/2)
                elseif self.x + self.size/2 > Camera.x + love.graphics.getWidth() then
                    dx = (Camera.x + love.graphics.getWidth()) - (self.x + self.size/2)
                end
                if self.y - self.size/2 < Camera.y then
                    dy = Camera.y - (self.y - self.size/2)
                elseif self.y + self.size/2 > Camera.y + love.graphics.getHeight() then
                    dy = (Camera.y + love.graphics.getHeight()) - (self.y + self.size/2)
                end
            end
            return dx, dy
        end,
    },
    Move = function (self)
        if self.timeFromDeath > 0 and self.timeFromDeath < 0.5 then return end
        self.distanceToPlayer = math.sqrt((Player.x - self.x)^2 + (Player.y - self.y)^2)
        local dx, dy = 0, 0
        for functionName, functionLogic in pairs(self.MoveFunctions) do
            local ddx, ddy = functionLogic(self)
            dx = dx + ddx
            dy = dy + ddy
        end

        self.sx = self.sx * 0.6 + dx
        self.sy = self.sy * 0.6 + dy

        self.x = self.x + self.sx * DeltaTime * 60
        self.y = self.y + self.sy * DeltaTime * 60
    end
    }
end