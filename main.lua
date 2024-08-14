-- It begins.

-- Get the game running on computer then port over to android. (No iphone, too much work...)

-- Game version
gameVersion = 0.1

-- Hold the current state of the game
local state = {}

-- misc. setup (Planning on adding intro later)
firstStart = true -- After intro set this to false

-- Define the load function
function love.load()
    -- Load High Scores
    -- loadHighscores()

    -- Load window values
    love.window.setFullscreen(true)
    -- love.window.setMode(1280, 720) -- Set to 1920 x 1080 on launch
    love.window.setTitle("Horizon Driving")
    love.math.setRandomSeed(os.time())

    -- Load the menu state
    state.current = require("Scenes/mainMenu")
    state.current.load()
end

function love.update(dt) -- Runs every frame.
    -- Update the current state
    local nextState = state.current.update(dt)

    if nextState == "startCalculator" then
        -- Switch to the game scene
        print("Switching to the calculator scene")
        state.current = require("Scenes/calculator")
        state.current.load()
    elseif nextState == "mainMenu" then
        -- Switch to the main menu scene
        print("Switching to the main menu scene")
        state.current = require("Scenes/mainMenu")
        state.current.load()
    end
end

function love.draw() -- Draws every frame / Runs directly after love.update()
    -- Draw the current state
    state.current.draw()
    state.current.drawSUIT()
end