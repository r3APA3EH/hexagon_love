require("Enemies.DumbEnemy")
require("Enemies.LazyEnemy")
function NewEnemy(type, hp, speed)
    if type == "random" then
        type = RandomChoice({"lazy", "dumb", "dumb", "dumb"})
    end
    print (type)
    local x,y = GetRandomSpotOnScreenPerimeter()
    local size
    if type == "lazy" then
        return LazyEnemy(x, y, hp)
    elseif type == "dumb" then
        return DumbEnemy(x, y, hp, speed)
    end
end