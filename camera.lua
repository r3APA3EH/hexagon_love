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
        self.speed = love.math.noise((love.timer.getTime()+self.seed+100000)/10)*6
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

    local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
    local shape = function (self)
        love.graphics.setLineWidth(5)
        for width=0, windowWidth + 200, 100 do
            for height=0, windowHeight + 200, 100 do
                love.graphics.setColor(1,1,1, 0.4)
                -- if Player ~= nil then
                --     local x = width + self.offsetX
                --     local y = height + self.offsetY
                --     local distanceToPlayer = math.sqrt((Player.x - x - Camera.x)^2 + (Player.y - y -Camera.y)^2) *7.5
                --     local increment = distanceToPlayer/2500
                --     -- print(increment)

                --     love.graphics.setColor(increment, increment, 1, 0.15 + 0.0333/increment)
                -- end
                

                love.graphics.circle("line", width, height, 10)
            end
        end
    end

    local sprite = DrawFunctionToImage(windowWidth + 200, windowHeight + 200, shape)


    return
    {
    sprite = sprite,
    offsetX = 0,
    offsetY = 0,
    Draw = function (self)
        love.graphics.setColor(1,1,1)
        love.graphics.draw(self.sprite, self.offsetX-100, self.offsetY-100)
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
    end,
    RerenderBackground = function (self)
        local windowWidth, windowHeight = love.graphics.getWidth(), love.graphics.getHeight()
        local shape = function (self)
            love.graphics.setLineWidth(5)
            for width=0, windowWidth + 200, 100 do
                for height=0, windowHeight + 200, 100 do
                love.graphics.setColor(1,1,1, 0.4)
                    -- if Player ~= nil then
                    --     local x = width + self.offsetX
                    --     local y = height + self.offsetY
                    --     local distanceToPlayer = math.sqrt((Player.x - x - Camera.x)^2 + (Player.y - y -Camera.y)^2) *7.5
                    --     local increment = distanceToPlayer/2500
                    --     -- print(increment)

                    --     love.graphics.setColor(increment, increment, 1, 0.15 + 0.0333/increment)
                    -- end
                    

                    love.graphics.circle("line", width, height, 10)
                end
            end
        end

    self.sprite = DrawFunctionToImage(windowWidth + 200, windowHeight + 200, shape)
    end
    }
end