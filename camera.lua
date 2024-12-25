function NewCamera()
    return
    {
    transform = love.math.newTransform(),
    x = 0,
    y = 0,
    rotation = 0,
    speed = 1,
    Move = function (self)
        local dx = self.speed*math.cos(self.rotation) *DeltaTime*60
        local dy = self.speed*math.sin(self.rotation) *DeltaTime*60
        local dr = love.math.noise(love.timer.getTime()*math.random()/1000) - 0.5
        -- print (dr)
        -- print (math.floor(love.timer.getTime()))

        self.transform:translate(dx, dy)
        -- self.transform:rotate(dr)

        self.x = self.x - dx
        self.y = self.y - dy
        
        self.rotation = self.rotation + dr
    end
    }
end