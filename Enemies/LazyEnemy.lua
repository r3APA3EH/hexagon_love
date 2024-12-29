require("Enemies.AbstractEnemy")

function LazyEnemy(x, y, hp)
    local ParentObject = AbstractEnemy(x, y, hp, 5)

    local newMoveFunctions = {
        
    }
    MergeTables(ParentObject.MoveFunctions, newMoveFunctions)

    local uniqueBehaviour =
    {
    size = 60,
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
    end
    }
    return MergeTables(ParentObject, uniqueBehaviour)
end