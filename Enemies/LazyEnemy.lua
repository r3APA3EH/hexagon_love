require("Enemies.AbstractEnemy")

function LazyEnemy(x, y, hp)
    local ParentObject = AbstractEnemy(x, y, hp, 5)

    local newMoveFunctions = {
       
    }
    MergeTables(ParentObject.MoveFunctions, newMoveFunctions)

    local size = 75

    local color = {0.639, 0.776, 1}

    local shape = function (self)
        love.graphics.setLineWidth(5)
        love.graphics.setColor(color)
        local lineWidth = love.graphics.getLineWidth()
        love.graphics.circle("line", (size + lineWidth)/2, (size + lineWidth)/2, size/2, 6)
    end

    local sprite = DrawFunctionToImage(size, size, shape)

    local uniqueBehaviour =
    {
    size = size,
    sprite = sprite,
    angle = math.rad(math.random(0, 360))
    }
    return MergeTables(ParentObject, uniqueBehaviour)
end