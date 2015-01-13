
-- Call Composer

    local composer = require( "composer" )
    local scene = composer.newScene( )

-- Variables - elements of game

    local gameOverText
    local newGameButton

-- required in module

    return scene


-- Create 'game scene'

    function scene:create( event )

        local sceneGroup = self.view

            -- show objects on screen
            local background = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
            background:setFillColor( 0, .39, .75 )
            group:insert( background )

            -- properties of game over text
            gameOverText = display.newText( "Game Over", display.contentHeight / 2, 400, native.systemFont, 16 )
            gameOverText:setFillColor( 1, 1, 0 )
            gameOverText.anchorX = .5
            gameOverText.anchorY = .5
            group:insert( gameOverText )

            -- properties of new game button
            newGameButton = display.newImage( "newgamebutton.png", 264, 670 )
            group:insert(newGameButton)
            newGameButton.isVisible = false
    end

-- Enter 'game scene'

    function scene:show( event )

        local sceneGroup = self.view

        -- hiding gamelevel scene
        composer.removeScene( "gamelevel" )

        -- transition of game over text, after 2 seconds shows button new game
        transition.to( gameOverText, {xScale = 4.0, yScale = 4.0, time = 2000, onComplete = showButton } )

        -- event listener for new game
        newGameButton:addEventListener( "tap", startNewGame )
    end

-- changes game over text into new game button

    function showButton( )
        gameOverText.isVisible = false
        newGameButton.isVisible = true
    end

-- function start new game

    function startNewGame ( )
        composer.gotoScene( "gamelevel" )
    end