function NewPlayer()

    local size = 30

    local shape = function ()
        love.graphics.setLineWidth(5)
        love.graphics.setColor(1, 1, 1, 0.5)
        local lineWidth = love.graphics.getLineWidth()
        love.graphics.circle("line", (size + lineWidth)/2, (size + lineWidth)/2, size/2)
    end

    local image = DrawFunctionToImage(size, size, shape)

    local psystem = love.graphics.newParticleSystem(image)
	psystem:setParticleLifetime(0.5) -- Particles live at least 2s and at most 5s.
	psystem:setEmissionRate(20)
	psystem:setColors(1, 1, 1, 1, 1, 1, 1, 0) -- Fade to transparency.

    return 
    {
    particleSystem = psystem,
    size = size,
    x = love.graphics.getWidth()/2 + Camera.x,
    y = love.graphics.getHeight()/2 + Camera.y,
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
    fireDelay = 1,
    shotsNumber = 2,
    bulletDamage = 1,
    GetHitbox = function (self)
        return self.x - self.size/2, self.y - self.size/2, self.size, self.size
    end,
    Draw = function (self)
        love.graphics.setLineWidth(5)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(self.particleSystem, 0, 0)
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.circle("line", self.x, self.y, self.size/2)

        local maskHeight = self.size/2 - (self.size / self.maxHp * self.hp)
        if self.hp == self.maxHp then maskHeight = maskHeight - 5 end

        love.graphics.setScissor(0, -Camera.y + self.y + maskHeight, love.graphics.getWidth(), love.graphics.getHeight())

        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("line", self.x, self.y, self.size/2)
        love.graphics.setScissor()

        -- variable preview
        -- love.graphics.setColor(0, 1, 0)
        -- love.graphics.print(self.hp, self.x, self.y - 30)
        DrawSpeed(self.x, self.y, self.sx, self.sy)
        DrawHitbox({self:GetHitbox()})
    end,
    Move = function (self)

        local dx = 0
        local dy = 0
        local mx, my = love.mouse.getPosition()
        mx  = mx + Camera.x
        my = my + Camera.y

        local distanceToCursor = math.sqrt((mx - self.x)^2 + (my - self.y)^2)
        self.angle = math.atan2((my - self.y), (mx - self.x))
        local speed = self.speed

        if distanceToCursor < speed then
            speed = distanceToCursor
        end
        if distanceToCursor < self.size/2 then
            speed = 0
        end
        
        local ddx = math.cos(self.angle)*speed
        local ddy = math.sin(self.angle)*speed
        
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
        -- firing
        self.canFireTimer = self.canFireTimer + DeltaTime
        if self.canFireTimer > self.fireDelay then
            self.canFireTimer = 0
            self.canFire = true
        end

        if self.hp > self.maxHp then
            self.maxHp = self.hp
        end

        -- colliding
        if self.collideCooldown > 0 then
            self.collideCooldown = self.collideCooldown + DeltaTime
        end
        if self.collideCooldown >= 1 then self.collideCooldown = 0 end
        for i=1, #Enemies do
            local enemy = Enemies[i]
            if enemy.timeFromDeath > 0 then goto continue end
            if 0 < self.collideCooldown and self.collideCooldown < 1 then 
                self.isColliding = false 
                break
            end
            -- Просто передать 2 функции аргументами не получается. начинает жаловаться на то что w2 это nil
            local x1,y1,w1,h1 = self:GetHitbox()
            local x2,y2,w2,h2 = enemy:GetHitbox()
            self.isColliding = CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
            if self.isColliding then 
                self.collideCooldown = self.collideCooldown + DeltaTime
                break
            end
        
            ::continue::
        end
        for i=1, #Bullets do
            if Bullets[i].isShotByPlayer then goto continue end
            if 0 < self.collideCooldown and self.collideCooldown < 1 then 
                self.isColliding = false 
                break
            end
            -- Просто передать 2 функции аргументами не получается. начинает жаловаться на то что w2 это nil
            local x1,y1,w1,h1 = self:GetHitbox()
            local x2,y2,w2,h2 = Bullets[i]:GetHitbox()
            self.isColliding = CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
            if self.isColliding then 
                Bullets[i].isAlive = false
                self.collideCooldown = self.collideCooldown + DeltaTime
                break
            end
            ::continue::
        end

        if self.isColliding then
            self.hp = self.hp - 1
            if self.hp < 0 then self.hp = 0 end 
        end

        if self.hp == 0 then
            GameState.state.menu = true
            GameState.state.running = false
        end

    end,
    Fire = function (self)
        if not self.canFire then return end

        local fire = function (index)
            if index > #Enemies then return end
            local enemy = Enemies[index]

            local angle = math.atan2((enemy.y - self.y), (enemy.x - self.x))
            angle = angle + math.rad((math.random() - 0.5)*6)

            table.insert(Bullets, #Bullets + 1, NewBullet(true, self.x, self.y, 5, angle, 50, self.bulletDamage))
        end

        for i=1, self.shotsNumber do
            fire(i)
        end

        self.canFire = false
        self.canFireTimer = 0
    end
    }
end