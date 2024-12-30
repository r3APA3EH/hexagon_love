require("player")
require("bullet")
require("utils")
require("camera")
require("gamestate")
require("button")


function love.keypressed( key, scancode, isrepeat )
    if scancode == "space" then
        ShowHitboxes = not ShowHitboxes
    end
    if scancode == "escape" then
        GameState.state.menu = not GameState.state.menu
    end
end

function love.mousereleased( x, y, button, istouch, presses )
    for i=1, #Buttons do
        Buttons[i]:Click()
    end
end

function love.resize( w, h )
    Background:RerenderBackground()
end

-- function love.focus(f) GameState.state.paused = not f end

function love.load()
    CurrentOS = love.system.getOS()
    StartTime = love.timer.getTime()
    love.window.setMode(800, 600, {resizable=true, vsync=0, minwidth=400, minheight=300})
    ShowHitboxes = false
    love.window.setVSync(0)

    love.graphics.setLineStyle("smooth")
    love.graphics.setLineJoin("miter")
    MenuSetup()

    Camera = NewCamera()
    Background = NewBackground()
    -- love.graphics.setBackgroundColor(1, 1, 1, 1)
end

function love.update(dt)
    DeltaTime = dt

    Camera:Move()
    Background:Update()

    if GameState.state.paused then return end
    if GameState.state.menu then Menu() return end
    if GameState.state.running then MainLoop() return end
end
function love.draw()
    Background:Draw()
    
    if GameState.state.paused then return end
    if GameState.state.menu then MenuDraw() return end
    if GameState.state.running then MainDraw() return end
end