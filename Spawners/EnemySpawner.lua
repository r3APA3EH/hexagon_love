require("Enemies.DumbEnemy")
require("Enemies.LazyEnemy")
require("Enemies.BombEnemy")
function NewEnemy(type, hp, speed)
    if type == "random" then
        type = RandomChoice({"lazy", "dumb", "bomb"}, {3, 5, 2})
    end
    print(type)
    local x,y = GetRandomSpotOnScreenPerimeter()
    if type == "lazy" then
        return LazyEnemy(x, y, hp)
    elseif type == "dumb" then
        return DumbEnemy(x, y, hp, speed)
    elseif type == "bomb" then
        return BombEnemy(x, y, hp, speed)
    end
end