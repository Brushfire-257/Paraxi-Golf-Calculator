-- The main menu for the program
mainMenu = {}

local suit = require("SUIT")

love.graphics.setDefaultFilter("nearest", "nearest")
local paraxiLogo = love.graphics.newImage("Sprites/paraxiLogo.png")
local golfBallImage = love.graphics.newImage("Sprites/golfBall.png")
-- local optionsIcon = love.graphics.newImage("Sprites/gearIcon.png")

local golfBallRotationX = golfBallImage:getWidth() / 2
local golfBallRotationY = golfBallImage:getHeight() / 2

-- misc.
local golfBalls = {}
local golfSpawnTimer = 0

function mainMenu.load()
    love.window.setTitle("Horizon Driving - Main Menu")
    screenWidthA = love.graphics.getWidth()
    screenHeightA = love.graphics.getHeight()
    screenWidth = 1920
    screenHeight = 1080

    love.math.setRandomSeed(os.time())

    -- Load sound(s)
    bgSong = love.audio.newSource("Sounds/bgmusic.mp3", "stream")
    bgSong:setLooping(true)
    bgSong:setVolume(0.2)

    selectSound = love.audio.newSource("Sounds/select.wav", "stream")

    -- Play bg song
    bgSong:play()

    -- Set SUIT colors
    suit.theme.color.normal.fg = {255,255,255}
    suit.theme.color.hovered = {bg = {200,230,255}, fg = {0,0,0}}
    suit.theme.color.active = {bg = {150,150,150}, fg = {0,0,0}}

    -- Load font
    font = love.graphics.newFont("Fonts/VCR_OSD_MONO.ttf", 100 * math.min(scaleStuff("w"), scaleStuff("h"))) -- The font
    font1 = love.graphics.newFont("Fonts/VCR_OSD_MONO.ttf", 75 * math.min(scaleStuff("w"), scaleStuff("h")))
    font2 = love.graphics.newFont("Fonts/VCR_OSD_MONO.ttf", 50 * math.min(scaleStuff("w"), scaleStuff("h")))
    font3 = love.graphics.newFont("Fonts/VCR_OSD_MONO.ttf", 25 * math.min(scaleStuff("w"), scaleStuff("h")))
    love.graphics.setFont(font)

    -- print(love.filesystem.read("saveFile.txt"))
end

function mainMenu.update(dt)
    -- Move GUI a bit
    menuGUIUpdate(dt)
    
    -- Create and move golf balls radially out from a point
    golfBallsUpdate(dt)
    
    -- Create suit GUI elements
    if suit.Button("Start", ((screenWidth / 2) - 200) * scaleStuff("w"), (screenHeight - 275) * scaleStuff("h"),
            400 * scaleStuff("w"), 150 * scaleStuff("h")).hit then
                bgSong:stop()
                selectSound:play()
                return "startCalculator"
    end
end

function mainMenu.draw()
    -- Draw Background
    love.graphics.clear(2 / 255, 51 / 255, 79 / 255)

    -- Draw golf balls
    for i, golfBall in ipairs(golfBalls) do
        love.graphics.draw(golfBallImage, golfBall.x, golfBall.y, golfBall.rotation, golfBall.scaleX, golfBall.scaleY,
        golfBallRotationX, golfBallRotationY)
    end
    -- love.graphics.draw(golfBallImage, math.floor(100), math.floor(200),
    -- 0, 3, 3,
    -- golfBallRotationX, golfBallRotationY)

    -- Draw non SUIT GUI
end

function mainMenu.drawSUIT() -- Draws SUIT Elements
    suit.draw()
end

function menuGUIUpdate(dt)
    
end

function golfBallsUpdate(dt)
    golfSpawnTimer = golfSpawnTimer - dt
    if golfSpawnTimer < 0 then golfSpawnTimer = 0 end

    if golfSpawnTimer == 0 then
        local golfBall = {
            x = screenWidth/2 + math.random(-150, 150),
            y = 1100,
            rotation = 0,
            rotationSpeed = math.random(-100, 100) / 200,
            scaleX = 3,
            scaleY = 3,
        }
        print("Spawned Golf Ball")
        table.insert(golfBalls, golfBall)
        golfSpawnTimer = math.random(0.04, 0.05)
    end
    -- Move em
    for i, golfBall in ipairs(golfBalls) do
        golfBall.x = golfBall.x + math.sin(golfBall.rotation)
        golfBall.y = golfBall.y - 100 * dt
        -- golfBall.y = golfBall.y - math.cos(golfBall.rotation)
        golfBall.rotation = golfBall.rotation + golfBall.rotationSpeed * dt
    end

    -- Delete ones that are off screen
    local newGolfBalls = {}

    for i = 1, #golfBalls do
        if golfBalls[i].y >= -100 then
            table.insert(newGolfBalls, golfBalls[i])
        end
    end

    golfBalls = newGolfBalls

    -- Sort for rendering
    table.sort(golfBalls, function(a, b)
        return math.sin(a.rotation) < math.sin(b.rotation)
    end)
end

function love.keypressed(key)
    if key == "1" then -- Exit the game (Debug)
      love.event.quit()
    end
end

function scaleStuff(widthorheight)
    local scale = 1
    if widthorheight == "w" then -- width calc
        scale = screenWidthA / screenWidth
    elseif widthorheight == "h" then -- height calc
        scale = screenHeightA / screenHeight
    else
        print("Function usage error: scaleStuff() w/h not specified.")
    end

    return scale
end

return mainMenu