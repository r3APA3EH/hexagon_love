function NewEnemy()

    local size = 30
    local hp, speed = math.random(1, 10), 2 + math.random()*4
    local x, y

    local side = math.random(1,4)

    if side == 1 then
        x, y = 0, math.random(0, love.graphics.getHeight())
    elseif side == 2 then
        x, y = math.random(0, love.graphics.getWidth()), 0
    elseif side == 3 then
        x, y = love.graphics.getWidth(), math.random(0, love.graphics.getHeight())
    elseif side == 4 then
        x, y = math.random(0, love.graphics.getWidth()), love.graphics.getHeight()
    end
    x = x + Camera.x
    y = y + Camera.y
    local willToMoveToPlayer = 1
    if math.random(1,3) == 1 then
        willToMoveToPlayer = 0
        hp = hp * 2
    end
    local sizem = 0

    if willToMoveToPlayer == 0 then
        sizem = 1
    else
        sizem = 0
    end

    local color

    if willToMoveToPlayer == 1 then
        if speed >= 4 then
            color = {1, 0.639, 0}
        else
            color = {1, 0, 0}
        end
    else
        color = {0.639, 0.776, 1}
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
    color = color,
    distanceToPlayer = 0,
    willToMoveToPlayer = willToMoveToPlayer,
    size = size + 30 * sizem,
    angle = 0,
    isColliding = false,
    collideCooldown = 0,
    saveTime = 0.1,
    Draw = function (self)
        love.graphics.setLineWidth(5)

        local transform = love.math.newTransform(self.x, self.y, self.angle)

        love.graphics.setLineWidth(5)
        love.graphics.applyTransform(transform)

        love.graphics.setColor(self.color, 0.5)
        if willToMoveToPlayer == 1 then
            if self.speed >= 4 then
                love.graphics.circle("line", 0, 0, self.size/1.5, 3)
            else
                love.graphics.rectangle("line", -self.size/2, -self.size/2, self.size, self.size, 5, 5)
            end
        else
            love.graphics.circle("line", 0, 0, self.size/1.5, 6)
        end
        love.graphics.applyTransform(transform:inverse())


        local mask = function ()
            local maskHeight = self.size/2 - (self.size / self.maxHp * self.hp)
            if self.hp == self.maxHp then maskHeight = maskHeight - 8 end
            love.graphics.rectangle("fill", Camera.x, self.y + maskHeight, love.graphics.getWidth(), love.graphics.getHeight())
        end

        love.graphics.stencil(mask, "replace", 1)
        love.graphics.setStencilTest("gequal", 1)
        love.graphics.applyTransform(transform)
        love.graphics.setColor(self.color)
        if willToMoveToPlayer == 1 then
            if self.speed >= 4 then
                love.graphics.circle("line", 0, 0, self.size/1.5, 3)
            else
                love.graphics.rectangle("line", -self.size/2, -self.size/2, self.size, self.size, 5, 5)
            end
        else
            love.graphics.circle("line", 0, 0, self.size/1.5, 6)
        end
        if IndexOf(Enemies, self) <= 4 then
            love.graphics.setColor(0, 1, 0)
            love.graphics.setLineWidth(3)
            love.graphics.circle("line", 0, 0, self.size/1.2)
        end
        love.graphics.applyTransform(transform:inverse())
        love.graphics.setStencilTest()



        DrawHitbox({self:GetHitbox()})
    end,
    Move = function (self)
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
        local dx = 0
        local dy = 0
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
        self.distanceToPlayer = math.sqrt((Player.x - self.x)^2 + (Player.y - self.y)^2)
        local newAngle = math.asin(math.abs((Player.x - self.x)/self.distanceToPlayer))

        self.angle = lerp(self.angle, newAngle, 0.1)

        local ddx = math.sin(self.angle)*self.speed * self.willToMoveToPlayer
        local ddy = math.cos(self.angle)*self.speed * self.willToMoveToPlayer
        ddx = ddx - math.sin(self.angle)*self.speed * 7/(self.distanceToPlayer - self.size*0.8)
        ddy = ddy - math.cos(self.angle)*self.speed * 7/(self.distanceToPlayer - self.size*0.8)

        if Player.x < self.x then
            ddx = ddx * -1
        end
        if Player.y < self.y then
            ddy = ddy * -1
        end
        
        dx = dx + ddx
        dy = dy + ddy


        if IsOnTheEdge(self.x, self.y, self.size) then
            local distanceToCenter = math.sqrt((love.graphics.getWidth()/2 - self.x)^2 + (love.graphics.getHeight()/2 - self.y)^2)
            local newAngleToCenter = math.asin(math.abs((love.graphics.getWidth()/2 - self.x)/distanceToCenter))

            local ddx1 = math.sin(newAngleToCenter)*self.speed
            local ddy1 = math.cos(newAngleToCenter)*self.speed

            if love.graphics.getWidth()/2 < self.x then
                ddx1 = ddx1 * -1
            end
            if love.graphics.getHeight()/2 < self.y then
                ddy1 = ddy1 * -1
            end
            
            dx = dx + ddx1
            dy = dy + ddy1
        end

        
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
                    ps:moveTo(self.x - Camera.x, self.y - Camera.y)
                    -- local t = {{unpack(self.color), 0}, self.color, 1, self.color, 0.5, self.color, 0}
                    -- ps:setColors({unpack(self.color), 0}, {unpack(self.color), 1}, {unpack(self.color), 0.5}, {unpack(self.color), 0})
                    ps:start()
                    ps:emit(16)
                    self.isAlive = false
                end
                
                self.collideCooldown = self.collideCooldown + DeltaTime
                break
            end
        
        end

        
    end
    }
end