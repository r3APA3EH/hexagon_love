function NewEnemy(hp, speed, x, y)

    local size = 30

    return 
    {
    isAlive = true,
    hp = hp,
    maxHp = hp,
    speed = speed,
    x = x,
    y = y,
    size = size,
    angle = 0,
    isColliding = false,
    collideCooldown = 0,
    saveTime = 0.1,
    Draw = function (self)
        love.graphics.setLineWidth(5)

        local transform = love.math.newTransform(self.x, self.y, self.angle)
        -- love.graphics.applyTransform(transform)
        -- love.graphics.setColor(1, 0, 0)
        -- love.graphics.rectangle("line", -self.size/2, -self.size/2, self.size, self.size)
        -- love.graphics.applyTransform(transform:inverse())


        love.graphics.setLineWidth(5)
        love.graphics.applyTransform(transform)

        if self.speed >= 3 then
            love.graphics.setColor(1, 0.639, 0, 0.5)
            love.graphics.circle("line", 0, 0, self.size/1.5, 3)
        else
            love.graphics.setColor(1, 0, 0, 0.5)
            love.graphics.rectangle("line", -self.size/2, -self.size/2, self.size, self.size, 5, 5)
        end

        love.graphics.applyTransform(transform:inverse())


        local mask = function ()
            local maskHeight = self.size/2 - (self.size / self.maxHp * self.hp)
            if self.hp == self.maxHp then maskHeight = maskHeight - 8 end
            love.graphics.rectangle("fill", 0, self.y + maskHeight, love.graphics.getWidth(), love.graphics.getHeight())
        end

        love.graphics.stencil(mask, "replace", 1)
        love.graphics.setStencilTest("gequal", 1)
        love.graphics.applyTransform(transform)
        if self.speed >= 3 then
            love.graphics.setColor(1, 0.639, 0)
            love.graphics.circle("line", 0, 0, self.size/1.5, 3)
        else
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("line", -self.size/2, -self.size/2, self.size, self.size, 5, 5)
        end
        love.graphics.applyTransform(transform:inverse())
        love.graphics.setStencilTest()



        DrawHitbox({self:GetHitbox()})

        -- variable preview
        -- love.graphics.setColor(0, 1, 0)
        -- love.graphics.print(tostring(self.isColliding), self.x, self.y - 40)
        -- love.graphics.print(self.hp, self.x, self.y - 30)
        -- love.graphics.print(self.collideCooldown, self.x, self.y + 30)
        
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
        return self.x - self.size/2, self.y - self.size/2, self.size, self.size
    end,
    UpdateState = function (self)
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
                self.hp = self.hp - Bullets[i].damage
                if self.hp < 0 then self.hp = 0 end
                if self.hp == 0 then
                    self.isAlive = false
                end
                
                self.collideCooldown = self.collideCooldown + DeltaTime
                break
            end
        
        end

        
    end
    }
end