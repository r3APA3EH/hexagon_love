function NewPlayer()

    local size = 30

    return 
    {
    size = size,
    x = love.graphics.getWidth()/2,
    y = love.graphics.getHeight()/2,
    GetHitbox = function (self)
        return self.x - size/2, self.y - size/2, size, size
    end,
    isColliding = false,
    collideCooldown = 0,
    maxHp = 10,
    hp = 10,
    speed = 5,
    canFire = true,
    fireCooldown = 0,
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

        if IsOnTheEdge(self.x + dx, self.y + dy, self.size) then return end

        self.x = self.x + dx
        self.y = self.y + dy
    end,
    UpdateState = function (self)
        -- firing
        self.fireCooldown = self.fireCooldown + DeltaTime
        if self.fireCooldown >= 1 then
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

    end,
    Fire = function (self)

        local mx, my = love.mouse.getPosition()

        local angle = math.asin(math.abs((mx - self.x)/math.sqrt((mx - self.x)^2 + (my - self.y)^2)))

        -- local xDirection = 1
        -- local yDirection = 1
        -- if self.x > mx then
        --     xDirection = xDirection * -1
        -- end
        -- if self.y > my then
        --     yDirection = yDirection * -1
        -- end

        table.insert(Bullets, #Bullets + 1, NewBullet(true, self.x, self.y, angle, 100, 1))

        self.canFire = false
        self.fireCooldown = 0
    end
    }
end

function NewEnemy(hp, speed, x, y)

    local size = 30

    return {
        hp = hp,
        speed = speed,
        x = x,
        y = y,
        angle = 0,
        Draw = function (self)
            love.graphics.setLineWidth(5)
            local transform = love.math.newTransform(self.x, self.y, self.angle)

            love.graphics.applyTransform(transform)
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("line", -size/2, -size/2, size, size)
            love.graphics.applyTransform(transform:inverse())
            DrawHitbox({self:GetHitbox()})
            
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
            return self.x - size/2, self.y - size/2, size, size
        end
    }
end

function NewBullet(isShotByPlayer ,x, y, angle, speed, damage)
    local size = 4
    return {
        isShotByPlayer = isShotByPlayer,
        x = x,
        y = y,
        size = size,
        angle = angle,
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
                DestroyObjectByIndex(Bullets, IndexOf(Bullets, self))
            end
        end,
        GetHitbox = function (self)
            return self.x - size/2, self.y - size/2, size, size
        end
    }
end

function love.focus(f) GameIsPaused = not f end

function love.load()
    ShowHitboxes = true
    love.graphics.setLineStyle("smooth")

    Player = NewPlayer()


    Enemies = {}
    table.insert(Enemies, #Enemies + 1, NewEnemy(10, 2, 100, 100))
    table.insert(Enemies, #Enemies + 1, NewEnemy(10, 1, 500, 500))

    Bullets = {}
    
end

function love.update(dt)
    DeltaTime = dt
    if GameIsPaused then return end
    Player:Move()

    for i=1, #Enemies do
        Enemies[i]:Move()
    end
    for i=1, #Bullets do
        Bullets[i]:Move()
    end

    Player:UpdateState()
    
    for i=1, #Bullets do
        Bullets[i]:UpdateState()
    end

    -- Player.canFireTimer = Player.canFireTimer + dt
    -- if Player.canFireTimer > 1 then
    --     Player.canFireTimer = 0
    --     Player.canFire = true
    -- end
    -- if love.mouse.isDown(1) and Player.canFire then
    --     Player:Fire()
    -- end
    -- Player:Fire()
    
    -- for i=1, #Bullets do
    --     Bullets[i]:Move()
    -- end

    

end

function love.mousepressed(x, y, button, istouch, presses )
    if button == 1 then
        Player:Fire()
        -- table.insert(Enemies, #Enemies + 1, NewEnemy(10, 1, 500, 500))
    end
end

-- function love.keypressed( key, scancode, isrepeat )
--     if key == "space" then
--         Player:Fire()
--     end
-- end

function love.draw()
    love.graphics.print(love.timer.getFPS())
    love.graphics.print(#Bullets, 0, 30)

    for i=1, #Enemies do
        Enemies[i]:Draw()
    end

    for i=1, #Bullets do
        Bullets[i]:Draw()
    end

    Player:Draw()
end


function lerp(a,b,t) return a + (b-a) * t end


function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end
function DrawHitbox(hitbox)
    if not ShowHitboxes then return end

    love.graphics.setColor(0, 1, 0)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", unpack(hitbox))
end

function IsOnTheEdge(x, y, size)
    local rightEdge = x + size/2 >= love.graphics.getWidth()
    local leftEdge = x - size/2 <= 0
    local bottomEdge = y + size/2 >= love.graphics.getHeight()
    local topEdge = y - size/2 <= 0
    if rightEdge or leftEdge or topEdge or bottomEdge then return true end
    return false
end

function DestroyObjectByIndex(space, pos)
    table.remove(space, pos)
end
function IndexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end