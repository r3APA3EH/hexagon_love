require("Enemies.DumbEnemy")
require("Enemies.LazyEnemy")
require("Enemies.BombEnemy")
function NewEnemy(type, hp, speed)
    if type == "random" then
        type = RandomChoice({"bomb", "lazy", "lazy", "dumb", "dumb"})
    end
    local x,y = GetRandomSpotOnScreenPerimeter()
    local size
    if type == "lazy" then
        return LazyEnemy(x, y, hp)
    elseif type == "dumb" then
        return DumbEnemy(x, y, hp, speed)
    elseif type == "bomb" then
        return BombEnemy(x, y, 30, speed)
    end
end