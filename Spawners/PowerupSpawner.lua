function NewPowerup(type)
    if type == "random" then
        type = RandomChoice({"bulletDamage", "hp", "speed", "speed", "speed", "speed", "speed", "speed", "speed", "speed", "speed", "speed", "speed", "speed", "shots", "fireSpeed", "fireSpeed", "fireSpeed", "fireSpeed", "fireSpeed", "fireSpeed", "fireSpeed", "fireSpeed", "fireSpeed"})
    end
    local x,y = GetRandomSpotOnScreenPerimeter()
    local pickupFunction
    if type == "hp" then
        pickupFunction = function ()
            Player.hp  = Player.hp + 2
        end
    elseif type == "speed" then
        pickupFunction = function ()
            Player.speed  = Player.speed *1.01
        end
    elseif type == "shots" then
        pickupFunction = function ()
            Player.shotsNumber  = Player.shotsNumber + 1
        end 
    elseif type == "fireSpeed" then
        pickupFunction = function ()
            Player.fireDelay  = Player.fireDelay *.99
        end 
    elseif type == "bulletDamage" then
        pickupFunction = function ()
            Player.bulletDamage  = Player.bulletDamage + 1
        end 
    end
    return Pickupable(x, y, pickupFunction, 10)
end