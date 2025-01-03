require("Particles.DeathEffect")
require("Spawners.EnemySpawner")
require("pickupable")
require("Spawners.PowerupSpawner")
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

end

MenuDraw = function ()
    for i=1, #Buttons do
        Buttons[i]:Draw()
    end
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
end
MainSetup = function ()

    EnemySpawnCooldown = math.random(2, 5)
    TimeFromLastEnemySpawn = 0

    Player = NewPlayer()

    Enemies = {}
    Enemies[#Enemies + 1] = NewEnemy("random", math.random(3, 10),2 + math.random()*4)
    Enemies[#Enemies + 1] = NewEnemy("random", math.random(3, 10),2 + math.random()*4)

    Bullets = {}
    LastRespawnTime = math.floor(love.timer.getTime())

    Powerups = {}
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
    for i=1, #Powerups do
        Powerups[i]:UpdateState()
    end

    DeleteRedundantObjects()

    TimeFromLastEnemySpawn = TimeFromLastEnemySpawn + DeltaTime

    if TimeFromLastEnemySpawn >= EnemySpawnCooldown then
        table.insert(Enemies, #Enemies + 1, NewEnemy("random", 1 + math.random(3, 5) * math.sqrt(love.timer.getTime() - LastRespawnTime)/10, 1 + math.random()))
        TimeFromLastEnemySpawn = 0
        EnemySpawnCooldown = math.random()*#Enemies/10 / math.sqrt(love.timer.getTime() - LastRespawnTime)
    end
end

function MainDraw()
    love.graphics.push()
    love.graphics.applyTransform(Camera.transform)

    for i=1, #Bullets do
        Bullets[i]:Draw()
    end
    for i=1, #Powerups do
        Powerups[i]:Draw()
    end
    for i=1, #Enemies do
        Enemies[i]:Draw()
        love.graphics.setBlendMode("alpha")
        love.graphics.draw(Enemies[i].deathEffect, 0, 0)
    end
    Player:Draw()
    love.graphics.pop()
    love.graphics.setBlendMode("alpha")
    
    love.graphics.setColor(0,1,0)
    love.graphics.print(love.timer.getFPS())
    love.graphics.printf(math.floor(love.timer.getTime()) - LastRespawnTime, love.graphics.getWidth()/2, 30, 100, "left", 0, 3, 3)
    love.graphics.print(#Enemies, 0, 50)
    love.graphics.print(Player.hp, 0, 100)
    love.graphics.print(#Powerups, 0, 150)
end
    
