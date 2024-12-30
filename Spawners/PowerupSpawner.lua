function NewPowerup(type)
    if type == "random" then
        type = RandomChoice({"hp", "speed", "shots", "fireSpeed"})
    end
    local x,y = GetRandomSpotOnScreenPerimeter()
    local pickupFunction
    if type == "hp" then
        pickupFunction = function ()
            Player.hp  = Player.hp + 1
        end
    elseif type == "speed" then
        pickupFunction = function ()
            Player.speed  = Player.speed *1.1
        end
    elseif type == "shots" then
        pickupFunction = function ()
            Player.shotsNumber  = Player.shotsNumber + 1
        end 
    elseif type == "fireSpeed" then
        pickupFunction = function ()
            Player.fireDelay  = Player.fireDelay *.90
        end 
    end
    return Pickupable(x, y, pickupFunction, 10)
end