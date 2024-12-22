function NewEnemy()

    local size = 30
    local hp, speed, x, y = math.random(5, 20), 
                            1 + math.random()*2, 
                            math.random(0,1) * love.graphics.getWidth(), 
                            math.random(0,1) * love.graphics.getHeight()
            
    local willToMoveToPlayer = math.random(0, 1)
    -- print(x, y)
    local sizem = 0

    if willToMoveToPlayer == 0 then
        sizem = 1
    else
        sizem = 0
    end

    return 
    {
    isAlive = true,
    hp = hp,
    maxHp = hp,
    speed = speed,
    sx = 0,
    sy = 0,
    x = x,
    y = y,
    willToMoveToPlayer = willToMoveToPlayer,
    size = size + 30 * sizem,
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
        if willToMoveToPlayer == 1 then
            if self.speed >= 3 then
                love.graphics.setColor(1, 0.639, 0, 0.5)
                love.graphics.circle("line", 0, 0, self.size/1.5, 3)
            else
                love.graphics.setColor(1, 0, 0, 0.5)
                love.graphics.rectangle("line", -self.size/2, -self.size/2, self.size, self.size, 5, 5)
            end
        else
            love.graphics.setColor(0.639, 0.776, 1, 0.5)
            love.graphics.circle("line", 0, 0, self.size/1.5, 6)
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
        if willToMoveToPlayer == 1 then
            if self.speed >= 3 then
                love.graphics.setColor(1, 0.639, 0)
                love.graphics.circle("line", 0, 0, self.size/1.5, 3)
            else
                love.graphics.setColor(1, 0, 0)
                love.graphics.rectangle("line", -self.size/2, -self.size/2, self.size, self.size, 5, 5)
            end
        else
            love.graphics.setColor(0.639, 0.776, 1)
            love.graphics.circle("line", 0, 0, self.size/1.5, 6)
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
        local dx = 0
        local dy = 0
        -- local nearEnemiesCount = 0
        for i=1, #Enemies do
            if Enemies[i].x == self.x then goto continue end
            if Enemies[i].y == self.y then goto continue end
            local distanceToOthers = math.sqrt((Enemies[i].x - self.x)^2 + (Enemies[i].y - self.y)^2)
            if distanceToOthers > self.size*3 then goto continue end
            -- nearEnemiesCount = nearEnemiesCount + 1
            
            local newAngleToEnemy = math.asin(math.abs((Enemies[i].x - self.x)/distanceToOthers))

            local ddx = -math.sin(newAngleToEnemy)*self.speed* 7/(distanceToOthers - self.size*1.2)
            local ddy = -math.cos(newAngleToEnemy)*self.speed* 7/(distanceToOthers - self.size*1.2)

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
        local distanceToPlayer = math.sqrt((Player.x - self.x)^2 + (Player.y - self.y)^2)
        local newAngle = math.asin(math.abs((Player.x - self.x)/distanceToPlayer))

        self.angle = lerp(self.angle, newAngle, 0.1)

        local ddx = math.sin(self.angle)*self.speed * self.willToMoveToPlayer
        local ddy = math.cos(self.angle)*self.speed * self.willToMoveToPlayer

        if Player.x < self.x then
            ddx = ddx * -1
        end
        if Player.y < self.y then
            ddy = ddy * -1
        end
        
        dx = dx + ddx
        dy = dy + ddy


        -- if IsOnTheEdge(self.x, self.y, self.size) then
        --     print "on the edge"
        --     local distanceToCenter = math.sqrt((self.x)^2 + (self.y)^2)
        --     local newAngleToCenter = math.asin(math.abs((self.x)/distanceToCenter))

        --     local ddx1 = math.sin(newAngleToCenter)*self.speed
        --     local ddy1 = math.cos(newAngleToCenter)*self.speed

        --     if 0 < self.x then
        --         ddx1 = ddx1 * -1
        --     end
        --     if 0 < self.y then
        --         ddy1 = ddy1 * -1
        --     end
            
        --     dx = dx + ddx1
        --     dy = dy + ddy1
        -- end

        
        self.sx = self.sx * 0.5 + dx
        self.sy = self.sy * 0.5 + dy

        self.x = self.x + self.sx * DeltaTime * 60
        self.y = self.y + self.sy * DeltaTime * 60

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