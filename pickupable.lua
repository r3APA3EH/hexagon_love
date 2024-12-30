function NewPickupable(x, y, PickupFunction)
    
    return
    {
    x = x,
    y = y,
    size = 30,
    isAlive = true,
    PickupFunction = PickupFunction,
    GetHitbox = function (self)
        return self.x - self.size/2, self.y - self.size/2, self.size, self.size
    end,
    Draw = function (self)
        love.graphics.circle("fill", self.x, self.y, self.size/2)
    end,
    UpdateState = function ()
        
    end



    
    }
end