function NewCamera()
    local seed = math.random(10000)
    return
    {
    seed = seed,
    transform = love.math.newTransform(),
    x = 0,
    y = 0,
    rotation = 0,
    speed = 0,
    Move = function (self)
        self.speed = love.math.noise((love.timer.getTime()+self.seed+1000)/10)*6
        local dx, dy, dr = self:GetDeltas()

        self.transform:translate(dx, dy)

        self.x = self.x - dx
        self.y = self.y - dy
        
        self.rotation = dr
    end,
    GetDeltas = function (self)
        return 
        self.speed*math.cos(self.rotation) *DeltaTime*60, -- dx
        self.speed*math.sin(self.rotation) *DeltaTime*60, -- dy
        math.rad(love.math.noise((love.timer.getTime()+self.seed)/10)*360) -- dr
    end,
    GetPosition = function (self) return self.x, self.y end
    }
end

function NewBackground()
    return
    {
    offsetX = 0,
    offsetY = 0,
    Draw = function (self)
        love.graphics.setLineWidth(5)
        local segments = 2 + math.ceil(love.math.noise((love.timer.getTime()/10))*6)
        for width=-100, love.graphics.getWidth() + 100, 100 do
            for height=-100, love.graphics.getHeight() + 100, 100 do
                love.graphics.setColor(1,1,1,0.15)
                if Player ~= nil then
                    local x = width + self.offsetX
                    local y = height + self.offsetY
                    local distanceToPlayer = math.sqrt((Player.x - x - Camera.x)^2 + (Player.y - y -Camera.y)^2) *7.5
                    local increment = distanceToPlayer/math.sqrt((love.graphics.getWidth())^2 + (love.graphics.getHeight())^2)
                    -- print(increment)

                    love.graphics.setColor(increment, increment, 1, 0.15 + 0.0333/increment)
                end
                

                love.graphics.circle("line", width + self.offsetX, height + self.offsetY, 10, segments)
            end
        end
    end,
    Update = function (self)
        if self.offsetX >= 100 or self.offsetX <= -100 then
            self.offsetX = 0
        end
        if self.offsetY >= 100 or self.offsetY <= -100 then
            self.offsetY = 0
        end
        local cdx, cdy = Camera:GetDeltas()
        self.offsetX = self.offsetX + cdx
        self.offsetY = self.offsetY + cdy
    end
    }
end