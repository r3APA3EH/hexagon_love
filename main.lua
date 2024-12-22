require("player")
require("enemy")
require("bullet")
require("utils")

function love.focus(f) GameIsPaused = not f end

function love.load()
    ShowHitboxes = true
    love.graphics.setLineStyle("smooth")

    Player = NewPlayer()


    Enemies = {}
    table.insert(Enemies, #Enemies + 1, NewEnemy(10, 2, 100, 100))
    table.insert(Enemies, #Enemies + 1, NewEnemy(10, 1, 500, 500))

    Bullets = {}
    BulletsToDelete = {}
    
end

function love.update(dt)
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

    DeleteRedundantObjects()

    -- Player.canFireTimer = Player.canFireTimer + dt
    -- if Player.canFireTimer > 1 then
    --     Player.canFireTimer = 0
    --     Player.canFire = true
    -- end
    -- if love.mouse.isDown(1) and Player.canFire then
    --     Player:Fire()
    -- end
    -- Player:Fire()
    
    -- for i=1, #Bullets do
    --     Bullets[i]:Move()
    -- end
end
function love.mousepressed(x, y, button, istouch, presses )
    if button == 1 then
        Player:Fire()
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