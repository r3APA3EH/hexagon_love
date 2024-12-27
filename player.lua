function NewPlayer()

    local size = 30

    local playerCanvas = love.graphics.newCanvas(size*2, size*2)
    love.graphics.setCanvas(playerCanvas)
    love.graphics.setLineWidth(5)
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.circle("line", size, size, size/2)
    love.graphics.setCanvas()
    
    local image = love.graphics.newImage(playerCanvas:newImageData())

    local psystem = love.graphics.newParticleSystem(image)
	psystem:setParticleLifetime(0.5) -- Particles live at least 2s and at most 5s.
	psystem:setEmissionRate(20)
	psystem:setColors(1, 1, 1, 1, 1, 1, 1, 0) -- Fade to transparency.

    return 
    {
    particleSystem = psystem,
    size = size,
    x = love.graphics.getWidth()/2,
    y = love.graphics.getHeight()/2,
    sx = 0,
    sy = 0,
    angle = 0,
    isColliding = false,
    collideCooldown = 0,
    maxHp = 10,
    hp = 10,
    speed = 10,
    canFire = true,
    canFireTimer = 0,
    fireCooldown = 0,
    GetHitbox = function (self)
        return self.x - self.size/2, self.y - self.size/2, self.size, self.size
    end,
    Draw = function (self)
        -- love.graphics.push()
        love.graphics.setLineWidth(5)
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.circle("line", self.x, self.y, self.size/2)
        local mask = function ()
            local maskHeight = self.size/2 - (self.size / self.maxHp * self.hp)
            if self.hp == self.maxHp then maskHeight = maskHeight - 5 end
            love.graphics.rectangle("fill", Camera.x, self.y + maskHeight, love.graphics.getWidth(), love.graphics.getHeight())
        end
        love.graphics.stencil(mask, "replace", 1)
        love.graphics.setStencilTest("gequal", 1)
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("line", self.x, self.y, self.size/2)
        love.graphics.setStencilTest()
        love.graphics.draw(self.particleSystem, 0, 0)

        -- variable preview
        -- love.graphics.setColor(0, 1, 0)
        -- love.graphics.print(self.hp, self.x, self.y - 30)

        DrawHitbox({self:GetHitbox()})
    end,
    Move = function (self)

        local dx = 0
        local dy = 0
        local mx, my = love.mouse.getPosition()
        mx  = mx + Camera.x
        my = my + Camera.y

        local distanceToCursor = math.sqrt((mx - self.x)^2 + (my - self.y)^2)
        local newAngle = math.asin(math.abs((mx - self.x)/distanceToCursor))

        self.angle = lerp(self.angle, newAngle, 0.1)
        self.speed = 10
        if distanceToCursor < self.speed then
            self.speed = distanceToCursor
        end

        local ddx = math.sin(self.angle)*self.speed
        local ddy = math.cos(self.angle)*self.speed

        if mx < self.x then
            ddx = ddx * -1
        end
        if my < self.y then
            ddy = ddy * -1
        end
        
        dx = dx + ddx
        dy = dy + ddy

        self.sx = self.sx * 0.5 + dx
        self.sy = self.sy * 0.5 + dy

        self.x = self.x + self.sx * DeltaTime * 60
        self.y = self.y + self.sy * DeltaTime * 60

        self.particleSystem:moveTo(self.x, self.y)
        self.particleSystem:setRotation(Player.angle, Player.angle)
        self.particleSystem:update(DeltaTime)
    end,
    UpdateState = function (self)
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
            if self.hp < 0 then self.hp = 0 end 
        end

        if self.hp == 0 then
            GameState.state.menu = true
            GameState.state.running = false
        end

        


        Player.canFireTimer = Player.canFireTimer + DeltaTime
        if Player.canFireTimer > 0.4 then
            Player.canFireTimer = 0
            Player.canFire = true
        end

    end,
    Fire = function (self)
        if not self.canFire then return end

        local fire = function (index)
            if #Enemies < index then return end
            local enemyX, enemyY = Enemies[index].x, Enemies[index].y

            local xDirection = 1
            local yDirection = 1
            if self.x > enemyX then
                xDirection = xDirection * -1
            end
            if self.y > enemyY then
                yDirection = yDirection * -1
            end

            local angle = math.asin(math.abs((enemyX - self.x)/math.sqrt((enemyX - self.x)^2 + (enemyY - self.y)^2)))
            angle = angle + math.rad((math.random() - 0.5)*10)

            table.insert(Bullets, #Bullets + 1, NewBullet(true, self.x, self.y, angle, xDirection, yDirection, 30, 1))
        end

        for i=1, 4 do
            fire(i)
        end

        self.canFire = false
        self.fireCooldown = 0
    end
    }
end