-- The actual calculator for the program
calculator = {}

function calculator.load()

end

function calculator.update(dt)

end

function calculator.draw()

end

function calculator.drawSUIT()

end

function love.keypressed(key)
    if key == "1" then -- Exit the game (Debug)
      love.event.quit()
    end
end

return calculator