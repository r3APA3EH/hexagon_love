require("player")
require("enemy")
require("bullet")
require("utils")

function love.focus(f) GameIsPaused = not f end

function love.load()
    ShowHitboxes = false

    EnemySpawnCooldown = math.random(2, 5)
    TimeFromLastEnemySpawn = 0

    love.graphics.setLineStyle("smooth")
    love.graphics.setLineJoin("bevel")

    Player = NewPlayer()


    Enemies = {}
    EnemiesToDelete = {}
    table.insert(Enemies, #Enemies + 1, NewEnemy(10, 2, 100, 100))
    table.insert(Enemies, #Enemies + 1, NewEnemy(10, 1, 500, 500))

    Bullets = {}
    BulletsToDelete = {}
    
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
        table.insert(Enemies, #Enemies + 1, NewEnemy(math.random(5, 20), math.random(1, 4), math.random(0,1) * love.graphics.getWidth(), math.random(0,1) * love.graphics.getHeight()))
        TimeFromLastEnemySpawn = 0
        EnemySpawnCooldown = math.random(2, 5)
    end
end
function love.draw()
    love.graphics.print(love.timer.getFPS())
    love.graphics.print(#Bullets, 0, 30)

    for i=1, #Enemies do
        Enemies[i]:Draw()
    end

    for i=1, #Bullets do
        Bullets[i]:Draw()
    end

    Player:Draw()
end