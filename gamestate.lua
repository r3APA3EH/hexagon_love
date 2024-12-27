require("particleDeathEffect")
GameState =
{

state = {
    menu = true,
    paused = false,
    running = true,
    ended = false
}

}

Menu = function ()
    ps:update(DeltaTime)

end

MenuDraw = function ()
    for i=1, #Buttons do
        Buttons[i]:Draw()
    end

    -- At draw time:
    love.graphics.setBlendMode("alpha")
    ps:moveTo(love.mouse.getPosition())
    love.graphics.draw(ps, 0, 0)
end

MenuSetup = function ()
    Buttons = {}
    local buttonContent = function ()
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle("fill", 150, 50, 20, 3)
    end
    local buttonClickLogic = function () 
        GameState.state.menu = false 
        GameState.state.running = true
        MainSetup()
    end
    table.insert(Buttons, NewButton(buttonContent, buttonClickLogic, love.graphics.getWidth()/2 - 150, love.graphics.getHeight()/2 - 50, 300, 100, "menu"))

    -- At start time:
end

function love.mousepressed( x, y, button, istouch, presses )
    if button == 1 then
        ps:start()
        ps:emit(16)
    end
end

MainSetup = function ()

    EnemySpawnCooldown = math.random(2, 5)
    TimeFromLastEnemySpawn = 0

    Player = NewPlayer()

    Enemies = {}
    math.randomseed(tonumber(tostring(1):reverse():sub(1, 9)))
    table.insert(Enemies, #Enemies + 1, NewEnemy())
    math.randomseed(tonumber(tostring(3):reverse():sub(1, 9)))
    table.insert(Enemies, #Enemies + 1, NewEnemy())

    Bullets = {}
end

MainLoop = function ()

    for i=1, #Bullets do
        Bullets[i]:Move()
    end

    for i=1, #Enemies do
        Enemies[i]:Move()
    end
    table.sort(Enemies, function (a, b) return a.distanceToPlayer < b.distanceToPlayer end)
    Player:Move()

    Player:Fire()
    
    for i=1, #Bullets do
        Bullets[i]:UpdateState()
    end

    for i=1, #Enemies do
        Enemies[i]:UpdateState()
    end

    Player:UpdateState()
    ps:update(DeltaTime)

    DeleteRedundantObjects()

    TimeFromLastEnemySpawn = TimeFromLastEnemySpawn + DeltaTime

    if TimeFromLastEnemySpawn >= EnemySpawnCooldown then
        table.insert(Enemies, #Enemies + 1, NewEnemy())
        TimeFromLastEnemySpawn = 0
        EnemySpawnCooldown = math.random()
    end
end

function MainDraw()
    love.graphics.push()
    love.graphics.applyTransform(Camera.transform)

    for i=1, #Bullets do
        Bullets[i]:Draw()
    end
    for i=1, #Enemies do
        Enemies[i]:Draw()
    end
    Player:Draw()
    
    -- love.graphics.applyTransform(Camera.transform)

    -- love.graphics.polygon("line", Camera.x, Camera.y, love.graphics.getWidth()+Camera.x, Camera.y, love.graphics.getWidth()+Camera.x, love.graphics.getHeight()+Camera.y, Camera.x, love.graphics.getHeight()+Camera.y)
    -- love.graphics.applyTransform(Camera.transform:inverse())
    

    -- arrow
    -- love.graphics.ellipse("fill", 100, 100, 50, 55, 3)
    -- love.graphics.rectangle("fill", 25, 75, 75, 50, 3, 10, 10) 
    love.graphics.pop()
    love.graphics.setBlendMode("alpha")
    love.graphics.draw(ps, 0, 0)
    
    love.graphics.setColor(0,1,0)
    love.graphics.print(love.timer.getFPS())
    love.graphics.print(#Enemies, 0, 50)
    -- love.graphics.print(Player.x, 0, 100)
    -- love.graphics.print(Player.y, 200, 100)
    -- love.graphics.print(Camera.x, 0, 150)
    -- love.graphics.print(Camera.y, 200, 150)
end
    
