-- The actual calculator for the program
calculator = {}

local suit = require("SUIT")

local gridSpacing = 100  -- Distance between grid lines
local mainAxisColor = {1, 1, 1}  -- main x and y axis
local minorGridColor = {0.7, 0.7, 0.7}  -- minor grid lines
local labelColor = {1, 1, 1}  -- labels
local lineWidth = 2  -- grid line thickness
local mainAxisLineWidth = 3  -- x and y axis thickness

local centerX = love.graphics.getWidth() / 2
local centerY = love.graphics.getHeight() / 2

local isDragging = false
local dragStartX, dragStartY = 0, 0

local vectorTable = {}

local textInput = {text = ""}
local savedText = {}
local requestedData = 0
local saveTable = {}

local prevVectorx, prevVectory = 0

local golfBallImage = love.graphics.newImage("Sprites/golfBall.png")
local golfBallRotationX = golfBallImage:getWidth() / 2
local golfBallRotationY = golfBallImage:getHeight() / 2
local golfBallAnimationTimer = 0

function calculator.load()
    love.window.setTitle("Paraxi Golf - Calculator")
    screenWidthA = love.graphics.getWidth()
    screenHeightA = love.graphics.getHeight()
    screenWidth = 1920
    screenHeight = 1080

    love.math.setRandomSeed(os.time())

    -- Load sound(s)
    -- bgSong = love.audio.newSource("Sounds/bgmusic.mp3", "stream")
    -- bgSong:setLooping(true)
    -- bgSong:setVolume(0.2)

    selectSound = love.audio.newSource("Sounds/select.wav", "stream")
    deselectSound = love.audio.newSource("Sounds/deselect.wav", "stream")

    -- Play bg song
    -- bgSong:play()

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
    love.keyboard.setKeyRepeat(true)

    -- print(love.filesystem.read("saveFile.txt"))
end

function calculator.update(dt)
    if isDragging then
        local mouseX, mouseY = love.mouse.getPosition()

        -- print(mouseX .. ", " .. mouseY)
        
        -- how far the mouse has moved
        local dx = mouseX - dragStartX
        local dy = mouseY - dragStartY

        -- Update the grid position
        centerX = centerX + dx
        centerY = centerY + dy

        dragStartX, dragStartY = mouseX, mouseY

        -- Cursor wrapping // my masterpiece >:)
        -- I love it when apps do this
        if mouseX <= 0 then
            love.mouse.setPosition(screenWidthA - 1, mouseY)
            dragStartX = screenWidthA - 1
        elseif mouseX >= screenWidthA - 1 then
            love.mouse.setPosition(0, mouseY)
            dragStartX = 0
        end

        if mouseY <= 0 then
            love.mouse.setPosition(mouseX, screenHeightA - 1)
            dragStartY = screenHeightA - 1
        elseif mouseY >= screenHeightA - 1 then
            love.mouse.setPosition(mouseX, 0)
            dragStartY = 0
        end
    end

    suit.Input(textInput, screenWidthA - 350, 50, 300, 50)

    golfBallAnimationTimer = golfBallAnimationTimer + dt
end

function love.mousepressed(x, y, button)
    if button == 1 then  -- LMB
        isDragging = true
        dragStartX, dragStartY = x, y
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then  -- LMB
        isDragging = false
    end
end

function calculator.draw()
    love.graphics.clear(2 / 255, 10 / 255, 14 / 255)

    love.graphics.setFont(font3)

    local screenWidth, screenHeight = love.graphics.getDimensions()

    -- Draw grid lines
    love.graphics.setColor(minorGridColor)
    love.graphics.setLineWidth(lineWidth)
    drawGridLines(centerX, centerY, gridSpacing, screenWidth, screenHeight)

    -- Draw the x and y axes
    love.graphics.setColor(mainAxisColor)
    love.graphics.setLineWidth(mainAxisLineWidth)
    love.graphics.line(0, centerY, screenWidth, centerY)  -- x axis
    love.graphics.line(centerX, 0, centerX, screenHeight)  -- y axis

    -- Label the axes
    love.graphics.setColor(labelColor)
    labelGridLines(centerX, centerY, gridSpacing, screenWidth, screenHeight)

    -- Draw vectors
    addVectors(vectorTable)

    love.graphics.setFont(font2)
    if requestedData == 0 then
        love.graphics.print("Magnitude?", screenWidth - 350, 100)
    elseif requestedData == 1 then
        love.graphics.print("Angle?", screenWidth - 350, 100)
    end
    for i, vector in ipairs(vectorTable) do
        love.graphics.print("<" .. vectorTable[i][1]
        .. "," .. vectorTable[i][2] .. ">", screenWidth - 350, (25 * i) + 100)
        -- if i == #vectorTable then
        --     love.graphics.print("Ans: <" .. screenEndX
        --     .. "," .. screenEndY .. ">", screenWidth - 350, (25 * (i + 1)) + 100)
        -- end
        if i ~= nil and i == #vectorTable then
            printFinal(i)
        end
    end

    love.graphics.setFont(font3)
end

function printFinal(i)
    local finalVectorMagnitude = math.sqrt((finalVectorx^2) + (finalVectory^2)) -- Magnitude
    local finalVectorAngle = math.deg(math.atan(finalVectory / finalVectorx)) -- Angle
    print(finalVectorMagnitude .. "," .. finalVectorAngle)
    
    love.graphics.print("Ans: <" .. finalVectorMagnitude .. "," .. finalVectorAngle .. ">", screenWidthA - 350, (25 * (i + 1)) + 100)
end

function drawGridLines(centerX, centerY, spacing, screenWidth, screenHeight)
    -- Vertical lines
    for x = centerX % spacing, screenWidth, spacing do
        love.graphics.line(x, 0, x, screenHeight)
    end
    -- Horizontal lines
    for y = centerY % spacing, screenHeight, spacing do
        love.graphics.line(0, y, screenWidth, y)
    end
end

function labelGridLines(centerX, centerY, spacing, screenWidth, screenHeight) -- No idea how to do this // this AI code is more right then I was, but still wrong
    -- grid top-left corner in world coordinates
    local worldOriginX = centerX % spacing
    local worldOriginY = centerY % spacing

    -- Label x-axis
    for x = worldOriginX, screenWidth, spacing do
        local gridX = math.floor((x - centerX) / spacing)
        local label = tostring(gridX)
        love.graphics.print(label, x + 2, centerY + 2)
    end

    -- Label y-axis
    for y = worldOriginY, screenHeight, spacing do
        local gridY = math.floor((centerY - y) / spacing)
        local label = tostring(gridY)
        love.graphics.print(label, centerX + 2, y + 2)
    end
end

function drawLine(startX, startY, endX, endY, thickness, color)
    -- grid coordinates to screen coordinates
    local screenStartX = centerX + startX * gridSpacing
    local screenStartY = centerY - startY * gridSpacing
    local screenEndX = centerX + endX * gridSpacing
    local screenEndY = centerY - endY * gridSpacing

    love.graphics.setLineWidth(thickness)
    love.graphics.setColor(color[1], color[2], color[3])
    love.graphics.line(screenStartX, screenStartY, screenEndX, screenEndY)
    love.graphics.circle("fill", screenEndX, screenEndY, 10 * golfBallScale / 3)

    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1)
end

function deconstructVector(magnitude, direction) -- Oh yeahh
    local vectorx = magnitude * math.cos(math.rad(direction))
    local vectory = magnitude * math.sin(math.rad(direction))
    return vectorx, vectory
end

function addVectors(vectorTable) -- Add vectors in table
    local vectorx, vectory = 0
    for i, vector in ipairs(vectorTable) do

        if i == 1 then
            vectorx, vectory = deconstructVector(vectorTable[i][1], vectorTable[i][2])
        else
            vectorx, vectory = deconstructVector(vectorTable[i][1], vectorTable[i][2])
            vectorx = prevVectorx + vectorx
            vectory = prevVectory + vectory
        end
        
        -- color stuff
        local color1 = {50 / 255, 150 / 255, 200 / 255}
        local color2 = {200 / 255, 200 / 255, 255 / 255}
        local normalized = (i - 1) / (#vectorTable - 1)
        local r = (1 - normalized) * color1[1] + normalized * color2[1]
        local g = (1 - normalized) * color1[2] + normalized * color2[2]
        local b = (1 - normalized) * color1[3] + normalized * color2[3]

        if i == 1 then
            drawLine(0, 0, vectorx, vectory, 5, {50 / 255, 150 / 255, 200 / 255})
        else
            drawLine(prevVectorx, prevVectory, vectorx, vectory, 5, {r, g, b})
        end
        prevVectorx, prevVectory = vectorx, vectory
    end

    golfBallScale = math.sin(golfBallAnimationTimer) / 2 + 4
    if vectorTable[1] ~= nil then
        -- grid coordinates to screen coordinates
        local screenEndX = centerX + vectorx * gridSpacing
        local screenEndY = centerY - vectory * gridSpacing
        finalVectorx = vectorx
        finalVectory = vectory
        -- print(vectorx .. "," .. vectory)
        love.graphics.draw(golfBallImage, screenEndX, screenEndY, 0, golfBallScale, golfBallScale,
        golfBallRotationX, golfBallRotationY)
    else
        local screenEndX = centerX
        local screenEndY = centerY
        love.graphics.draw(golfBallImage, screenEndX, screenEndY, 0, golfBallScale, golfBallScale,
        golfBallRotationX, golfBallRotationY)
    end
end

function love.wheelmoved(x, y)
    if y > 0 then
        -- Zoom in
        gridSpacing = math.floor(((gridSpacing * 1.1) + 5) / 10) * 10 -- May this answer lie in the depths of hell, as I should have found it 10 minutes ago...
    elseif y < 0 then
        -- Zoom out
        gridSpacing = math.floor(((gridSpacing / 1.1) + 5) / 10) * 10
    end

    -- Clamp gridSpacing to a reasonable range
    if gridSpacing < 10 then
        gridSpacing = 10
    elseif gridSpacing > 200 then
        gridSpacing = 200
    end
end

function calculator.drawSUIT()
    suit.draw()
end

function love.textinput(t)
    suit.textinput(t)
end

function love.keypressed(key)
    suit.keypressed(key)
    if key == "]" then -- Exit the game (Debug)
      love.event.quit()
    elseif key == "return" then
        local savedValue = tonumber(textInput.text)

        if requestedData == 0 then
            if savedValue ~= nil then
                saveTable[1] = savedValue
                textInput.text = ""
                print(saveTable[1] .. ", ")
                requestedData = 1
            end
        elseif requestedData == 1 then
            if savedValue ~= nil then
                saveTable[2] = savedValue
                textInput.text = ""
                print(saveTable[1] .. ", " .. saveTable[2])
                table.insert(vectorTable, saveTable)
                saveTable = {}
                requestedData = 0
            end
        end 
    elseif key == "c" then
        centerX = love.graphics.getWidth() / 2
        centerY = love.graphics.getHeight() / 2
    elseif key == "r" then
        vectorTable = {}
    end
end

return calculator