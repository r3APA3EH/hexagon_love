require("player")
require("enemy")
require("bullet")
require("utils")


function love.keypressed( key, scancode, isrepeat )
    if scancode == "space" then
        ShowHitboxes = not ShowHitboxes
    end
end

function love.focus(f) GameIsPaused = not f end

function love.load()
    love.window.setMode(800, 600, {resizable=true, vsync=0, minwidth=400, minheight=300})
    ShowHitboxes = false
    love.window.setVSync(0)

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
    if love.mouse.isDown(1) then
        Player:Fire()
    end

    DeltaTime = dt
    if GameIsPaused then return end

    Player:Move()

    for i=1, #Enemies do
        Enemies[i]:Move()
    end
    for i=1, #Bullets do
        Bullets[i]:Move()
    end

    Player:UpdateState()
    
    for i=1, #Bullets do
        Bullets[i]:UpdateState()
    end

    for i=1, #Enemies do
        Enemies[i]:UpdateState()
    end

    DeleteRedundantObjects()

    TimeFromLastEnemySpawn = TimeFromLastEnemySpawn + dt

    if TimeFromLastEnemySpawn >= EnemySpawnCooldown then
        table.insert(Enemies, #Enemies + 1, NewEnemy())
        TimeFromLastEnemySpawn = 0
        EnemySpawnCooldown = math.random()
    end
end
function love.draw()
    love.graphics.setColor(0,1,0)
    love.graphics.print(love.timer.getFPS())
    love.graphics.print(#Enemies, 0, 50)
    
    Player:Draw()

    for i=1, #Bullets do
        Bullets[i]:Draw()
    end
    for i=1, #Enemies do
        Enemies[i]:Draw()
    end

    

    

    -- arrow
    -- love.graphics.ellipse("fill", 100, 100, 50, 55, 3)
    -- love.graphics.rectangle("fill", 25, 75, 75, 50, 3, 10, 10)
end