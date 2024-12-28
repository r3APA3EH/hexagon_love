require("Enemies.AbstractEnemy")

function LazyEnemy(x, y, size, hp)
    local ParentObject = AbstractEnemy(x, y, size, hp, 0)
    local uniqueBehaviour =
    {
    angle = math.rad(math.random(0, 360)),
    Draw = function (self)
        if self.timeFromDeath > 0 and self.timeFromDeath < 0.5 then return end
        love.graphics.setLineWidth(5)

        local transform = love.math.newTransform(self.x, self.y, self.angle)

        love.graphics.setLineWidth(5)
        love.graphics.setLineJoin("miter")
        love.graphics.applyTransform(transform)
        
        love.graphics.setColor(0.639, 0.776, 1, 0.5)
        love.graphics.circle("line", 0, 0, self.size/1.5, 6)

        love.graphics.applyTransform(transform:inverse())


        local mask = function ()
            local maskHeight = self.size/2 - (self.size / self.maxHp * self.hp)
            if self.hp == self.maxHp then maskHeight = maskHeight - 8 end
            love.graphics.rectangle("fill", Camera.x, self.y + maskHeight, love.graphics.getWidth(), love.graphics.getHeight())
        end

        -- mask()
        love.graphics.stencil(mask, "replace", 1)
        love.graphics.setStencilTest("gequal", 1)
        love.graphics.applyTransform(transform)
        love.graphics.setLineWidth(5)
        
        love.graphics.setColor(0.639, 0.776, 1)
        love.graphics.circle("line", 0, 0, self.size/1.5, 6)
        
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
        if self.timeFromDeath > 0 and self.timeFromDeath < 0.5 then return end
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

        self.sx = self.sx * 0.5 + dx
        self.sy = self.sy * 0.5 + dy

        self.x = self.x + self.sx * DeltaTime * 60
        self.y = self.y + self.sy * DeltaTime * 60

        self.distanceToPlayer = math.sqrt((Player.x - self.x)^2 + (Player.y - self.y)^2)

    end
    }
    return MergeTables(ParentObject, uniqueBehaviour)
end