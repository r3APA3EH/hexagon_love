require("Enemies.AbstractEnemy")

function DumbEnemy(x, y, hp, speed)
    local ParentObject = AbstractEnemy(x, y, hp, speed)

    local newMoveFunctions = {
        MoveToPlayer = function (self)
            local dx, dy = 0, 0
            local newAngle = math.asin(math.abs((Player.x - self.x)/self.distanceToPlayer))

            self.angle = lerp(self.angle, newAngle, 0.1)

            local ddx = math.sin(self.angle)*self.speed
            local ddy = math.cos(self.angle)*self.speed
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
    }
    MergeTables(ParentObject.MoveFunctions, newMoveFunctions)
    local uniqueBehaviour =
    {
    size = 30,
    type = math.random(2),
    Draw = function (self)
        if self.timeFromDeath > 0 and self.timeFromDeath < 0.5 then return end
        love.graphics.setLineWidth(5)

        local transform = love.math.newTransform(self.x, self.y, self.angle)

        love.graphics.setLineWidth(5)
        love.graphics.setLineJoin("miter")
        love.graphics.applyTransform(transform)
        
        if self.type == 1 then
            love.graphics.setColor(1, 0.639, 0, 0.5)
            love.graphics.setLineJoin("bevel")
            love.graphics.circle("line", 0, 0, self.size/1.5, 3)
        elseif self.type == 2 then
            love.graphics.setColor(1, 0, 0, 0.5)
            love.graphics.rectangle("line", -self.size/2, -self.size/2, self.size, self.size, 5, 5)
        end
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
        if self.type == 1 then
            love.graphics.setColor(1, 0.639, 0)
            love.graphics.setLineJoin("bevel")
            love.graphics.circle("line", 0, 0, self.size/1.5, 3)
        elseif self.type == 2 then
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("line", -self.size/2, -self.size/2, self.size, self.size, 5, 5)
        end
        if IndexOf(Enemies, self) <= 4 then
            love.graphics.setColor(0, 1, 0)
            love.graphics.setLineWidth(3)
            love.graphics.circle("line", 0, 0, self.size/1.2)
        end

        love.graphics.applyTransform(transform:inverse())
        love.graphics.setStencilTest()



        DrawHitbox({self:GetHitbox()})
    end
    }

    return MergeTables(ParentObject, uniqueBehaviour)
end