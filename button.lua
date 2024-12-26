function NewButton(DrawFunction, ClickFunction, x, y, width, height)
    return
    {
    x = x,
    y = y,
    width = width,
    height = height,
    DrawFunction = DrawFunction,
    ClickFunction = ClickFunction,
    GetHitbox = function (self)
        return self.x, self.y, self.x + self.width, self.y + self.height
    end,
    Draw = function (self)
        local transform = love.math.newTransform(self.x, self.y, self.angle)

        local mask = function ()
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 20, 20)
        end
        
        
        love.graphics.stencil(mask, "replace", 1)
        love.graphics.setStencilTest("gequal", 1)
        love.graphics.applyTransform(transform)

        self.DrawFunction()
        love.graphics.applyTransform(transform:inverse())
        love.graphics.setStencilTest()
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setLineWidth(5)
        if IsHoveredByMouse(self:GetHitbox()) then
            love.graphics.setColor(1, 1, 0.6)
        love.graphics.setLineWidth(8)
        end
        
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 20, 20)
    end,
    Click = function (self)
        if not (IsHoveredByMouse(self:GetHitbox())) then return end
        self.ClickFunction()
    end
    
    
    }
end