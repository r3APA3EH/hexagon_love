require("player")
require("enemy")
require("bullet")
require("utils")
require("camera")


function love.keypressed( key, scancode, isrepeat )
    if scancode == "space" then
        ShowHitboxes = not ShowHitboxes
    end
end

function love.focus(f) GameIsPaused = not f end

function love.load()
    CurrentOS = love.system.getOS()
    StartTime = love.timer.getTime()
    love.window.setMode(800, 600, {resizable=true, vsync=0, minwidth=400, minheight=300})
    ShowHitboxes = false
    love.window.setVSync(0)

    Camera = NewCamera()
    Background = NewBackground()

    EnemySpawnCooldown = math.random(2, 5)
    TimeFromLastEnemySpawn = 0

    love.graphics.setLineStyle("smooth")
    love.graphics.setLineJoin("bevel")

    Player = NewPlayer()


    Enemies = {}
    math.randomseed(tonumber(tostring(1):reverse():sub(1, 9)))
    table.insert(Enemies, #Enemies + 1, NewEnemy())
    math.randomseed(tonumber(tostring(3):reverse():sub(1, 9)))
    table.insert(Enemies, #Enemies + 1, NewEnemy())

    Bullets = {}

    
end

function love.update(dt)
    DeltaTime = dt
    if GameIsPaused then return end
    Camera:Move()

    for i=1, #Bullets do
        Bullets[i]:Move()
    end

    for i=1, #Enemies do
        Enemies[i]:Move()
    end
    table.sort(Enemies, function (a, b) return a.distanceToPlayer < b.distanceToPlayer end)

    -- if love.mouse.isDown(1) then
        Player:Move()
    -- end
    Player:Fire()
    
    for i=1, #Bullets do
        Bullets[i]:UpdateState()
    end

    for i=1, #Enemies do
        Enemies[i]:UpdateState()
    end

    Player:UpdateState()

    Background:Update()

    DeleteRedundantObjects()

    TimeFromLastEnemySpawn = TimeFromLastEnemySpawn + dt

    if TimeFromLastEnemySpawn >= EnemySpawnCooldown then
        table.insert(Enemies, #Enemies + 1, NewEnemy())
        TimeFromLastEnemySpawn = 0
        EnemySpawnCooldown = math.random()
    end
end
function love.draw()
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

    Background:Draw()

    love.graphics.setColor(0,1,0)
    love.graphics.print(love.timer.getFPS())
    love.graphics.print(#Enemies, 0, 50)
    -- love.graphics.print(Player.x, 0, 100)
    -- love.graphics.print(Player.y, 200, 100)
    -- love.graphics.print(Camera.x, 0, 150)
    -- love.graphics.print(Camera.y, 200, 150)

end