function NewCamera()
    return
    {
    transform = love.math.newTransform(),
    x = 0,
    y = 0,
    rotation = 0,
    Move = function (self)
        local dx = 1*DeltaTime*60
        local dy = 1*DeltaTime*60
        local dr = 0

        self.transform:translate(dx, dy)
        self.transform:rotate(dr)

        self.x = self.x - dx
        self.y = self.y - dy
        
        self.rotation = self.rotation + dr
    end
    }
end