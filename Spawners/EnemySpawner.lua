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
        size = 60
        return LazyEnemy(x, y, size, hp)
    elseif type == "dumb" then
        size = 30
        return DumbEnemy(x, y, size, hp, speed)
    end
end