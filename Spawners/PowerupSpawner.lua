function NewPowerup(type, x, y)
    if type == "random" then
        type = RandomChoice({"bulletDamage", "hp", "speed", "shots", "fireSpeed"}, {2, 15, 100, 2, 8})
    end
    local pickupFunction
    local drawFunction
    if type == "hp" then
        pickupFunction = function ()
            Player.hp  = Player.hp + 2
        end
        drawFunction = function (self)
            love.graphics.setColor(0.498, 0.902, 0.259)
            love.graphics.circle("fill", self.x, self.y, self.size/2)
        end
    elseif type == "speed" then
        pickupFunction = function ()
            Player.speed  = Player.speed *1.01
        end
        drawFunction = function (self)
            love.graphics.setColor(0.227, 0.647, 1)
            love.graphics.circle("fill", self.x, self.y, self.size/2)
        end
    elseif type == "shots" then
        pickupFunction = function ()
            Player.shotsNumber  = Player.shotsNumber + 1
        end 
        drawFunction = function (self)
            love.graphics.setColor(0.957, 1, 0.227)
            love.graphics.circle("fill", self.x, self.y, self.size/2, 4)
        end
    elseif type == "fireSpeed" then
        pickupFunction = function ()
            Player.fireDelay  = Player.fireDelay *.99
        end 
        drawFunction = function (self)
            love.graphics.setColor(0.227, 0.647, 1)
            love.graphics.circle("fill", self.x, self.y, self.size/2, 4)
        end
    elseif type == "bulletDamage" then
        pickupFunction = function ()
            Player.bulletDamage  = Player.bulletDamage + 1
        end 
        drawFunction = function (self)
            love.graphics.setColor(1, 0.278, 0.227)
            love.graphics.circle("fill", self.x, self.y, self.size/2, 4)
        end
    end
    return Pickupable(x, y, 10, pickupFunction, drawFunction)
end