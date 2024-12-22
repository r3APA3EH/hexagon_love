function NewPlayer()

    local size = 30

    return 
    {
    size = size,
    x = love.graphics.getWidth()/2,
    y = love.graphics.getHeight()/2,
    isColliding = false,
    collideCooldown = 0,
    maxHp = 10,
    hp = 10,
    speed = 5,
    canFire = true,
    canFireTimer = 0,
    fireCooldown = 0,
    GetHitbox = function (self)
        return self.x - size/2, self.y - size/2, size, size
    end,
    Draw = function (self)
        love.graphics.setLineWidth(5)
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.circle("line", self.x, self.y, self.size/2)
        local mask = function ()
            local maskHeight = self.size/2 - (self.size / self.maxHp * self.hp)
            if self.hp == self.maxHp then maskHeight = maskHeight - 5 end
            love.graphics.rectangle("fill", 0, self.y + maskHeight, love.graphics.getWidth(), love.graphics.getHeight())
        end
        love.graphics.stencil(mask, "replace", 1)
        love.graphics.setStencilTest("gequal", 1)
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("line", self.x, self.y, self.size/2)
        love.graphics.setStencilTest()

        -- variable preview
        love.graphics.setColor(0, 1, 0)
        -- love.graphics.print(tostring(self.isColliding), self.x, self.y - 30)
        love.graphics.print(self.hp, self.x, self.y - 30)

        DrawHitbox({self:GetHitbox()})
    end,
    Move = function (self)

        if love.keyboard.isDown('lshift') then self.speed = 10 else self.speed = 5 end

        local dx = 0
        local dy = 0

        if love.keyboard.isDown('s') then
            dy = dy + self.speed * DeltaTime * 60
        end
        if love.keyboard.isDown('w') then
            dy = dy - self.speed * DeltaTime * 60
        end
        if love.keyboard.isDown('d') then
            dx = dx + self.speed * DeltaTime * 60
        end
        if love.keyboard.isDown('a') then
            dx = dx - self.speed * DeltaTime * 60
        end

        if not IsOnTheEdge(self.x + dx, self.y, self.size) then self.x = self.x + dx end
        if not IsOnTheEdge(self.x, self.y + dy, self.size) then self.y = self.y + dy end
    end,
    UpdateState = function (self)
        -- firing
        self.fireCooldown = self.fireCooldown + DeltaTime
        if self.fireCooldown >= 0.5 then
            self.fireCooldown = 0
            self.canFire = true
        end

        -- colliding
        if self.collideCooldown > 0 then
            self.collideCooldown = self.collideCooldown + DeltaTime
        end
        if self.collideCooldown >= 1 then self.collideCooldown = 0 end
        for i=1, #Enemies do
            if 0 < self.collideCooldown and self.collideCooldown < 1 then 
                self.isColliding = false 
                break
            end
            -- Просто передать 2 функции аргументами не получается. начинает жаловаться на то что w2 это nil
            local x1,y1,w1,h1 = self:GetHitbox()
            local x2,y2,w2,h2 = Enemies[i]:GetHitbox()
            self.isColliding = CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
            if self.isColliding then 
                self.collideCooldown = self.collideCooldown + DeltaTime
                break
            end
        
        end

        if self.isColliding then
            self.hp = self.hp - 1
        end

        if self.hp < 0 then self.hp = 0 end


        Player.canFireTimer = Player.canFireTimer + DeltaTime
        if Player.canFireTimer > 0.01 then
            Player.canFireTimer = 0
            Player.canFire = true
        end

    end,
    Fire = function (self)
        if not self.canFire then return end
        local mx, my = love.mouse.getPosition()

        local angle = math.asin(math.abs((mx - self.x)/math.sqrt((mx - self.x)^2 + (my - self.y)^2)))
        angle = angle + math.rad((math.random() - 0.5)*10)

        local xDirection = 1
        local yDirection = 1
        if self.x > mx then
            xDirection = xDirection * -1
        end
        if self.y > my then
            yDirection = yDirection * -1
        end

        table.insert(Bullets, #Bullets + 1, NewBullet(true, self.x, self.y, angle, xDirection, yDirection, 30, 3))

        self.canFire = false
        self.fireCooldown = 0
    end
    }
end