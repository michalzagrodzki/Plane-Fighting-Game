-- Call Composer

	local composer = 	require( "composer" )
	local scene = 		composer.newScene( )

-- Variables - elements of game

    -- properties of player
    local playerSpeedY = 0
    local playerSpeedX = 0
    local playerMoveSpeed = 7
    local playerWidth  = 60
    local playerHeight = 48

    local bulletWidth  = 8
    local bulletHeight =  19

    -- properties of island
    local islandHeight = 81
    local islandWidth = 100

    -- properties of enemies
    local numberofEnemysToGenerate = 0
    local numberOfEnemysGenerated = 0

    -- stores bullets fired by player
    local playerBullets = {}

    -- stores bullets fired by enemy
    local enemyBullets = {}

    -- stores islands
    local islands = {}

    -- makes grid system of game (11 elements, every with value 0 or 1)
    local planeGrid = {} -- Holds 0 or 1 (11 of them for making a grid system)

    -- stores enemy planes
    local enemyPlanes = {}

    -- stores 'free life' images
    local livesImages = {}
    local numberOfLives = 3

    -- stores number of lives in game
    local freeLifes = {}

    local playerIsInvincible = false
    local gameOver = false

    -- value incremented in each frame of game
    local numberOfTicks = 0

    -- group holding all island of game
    local islandGroup

    -- group holding all planes, bullets and so on
    local planeGroup

    -- variable for player
    local player

    -- sound channel for plane
    local  planeSoundChannel

    -- timers
    local firePlayerBulletTimer
    local generateIslandTimer
    local fireEnemyBulletsTimer
    local generateFreeLifeTimer

    -- variables for controlling player on DPAD
        -- up control
        local rectUp

        -- down control
        local rectDown

        -- left control
        local rectLeft

        -- right control
        local rectRight


-- Create 'game scene'

    function scene:create( event )

        -- group object for entire view of this scene
        local sceneGroup = self.view
        setupBackground( )
        setupGroups( )
        setupDisplay( )
        setupPlayer( )
        setupLiveImages( )
        setupDPad( )
        resetPlaneGrid ( )
    end

-- Function starts scene:create when scene's view does not exist

    scene:addEventListener( "create", scene )

-- Enter 'game scene'

    function scene:enter ( event )
        local sceneGroup = self.view

        -- removes previous instance of scene
        local previousScene = getSceneName( "previous" )
        composer.removeScene( previousScene )

        -- Listeners for DPad - only available when entered scene
        rectUp:addEventListener( "touch", movePlane )
        rectDown:addEventListener( "touch", movePlane )
        rectLeft:addEventListener( "touch", movePlane )
        rectRight:addEventListener( "touch", movePlane )

        -- loading sound of plane
        local planeSound = audio.loadStream( "planesound.mp3" )
        planeSoundChannel = audio.play( planeSound, {loops = -1} )

        -- function that keeps triggering gameLoop
        Runtime:addEventListener( "enterFrame", gameLoop )
    end

-- Function adds event listeners when player enters scene
    scene:addEventListener( "enter", scene )

-- Setting background

    function setupBackground( )
        local background = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
        background:setFillColor( 0, 0, 1 )
        scene.view:insert( background )
    end

-- Setting groups for planes and islands

    function setupGroups( )
        islandGroup = display.newGroup( )
        planeGroup  = display.newGroup( )
        -- adding to view group
        scene.view:insert( islandGroup )
        scene.view:insert( planeGroup )
    end

-- Adding display controls  to scene

    function setupDisplay ( )
        -- black backgound: setup, give color, add to scene view
        local tempRect = display.newRect( 0, display.contentHeight - 70, display.contentWidth, 124 )
        tempRect:setFillColor( 0, 0, 0 )
        scene.view:insert( tempRect )

        -- plane image: setup, give color, add to scene view
        local logo = display.newImage( "logo.png", display.contentWidth - 139, display.contentHeight - 70 )
        scene.view:insert( logo )

        -- dpad image: setup, give color, add to scene view
        local dpad = display.newImage( "dpad.png", 10, display.contentHeight - 70 )
        scene.view:insert( dpad )
    end

-- Adding player image to scene

    function setupPlayer ( )
        player = display.newImage( "player.png", (display.contentWidth / 2) - (playerWidth / 2), (display.contentHeight - 70) - playerHeight )
        player.name = "Player"
        scene.view:insert( player )
    end

-- Adding images of lifes in scene

    function setupLiveImages( )
        for i = 1, 6 do
            local tempLifeImage = display.newImage( "life.png", 40 * i - 20, 10 )

            -- insert 'life image' into table
            table.insert( livesImages, tempLifeImage)
            scene.view:insert( tempLifeImage )

                -- hide life images when it is bigger than 3
                if (i > 3) then
                    tempLifeImage.isVisible = false
                end
        end
    end

-- Setup input controls for player (DPAD)
    -- rectangles will be invisible, but will be functional by property 'isHitTestable'
    function setupDPad( )

        -- direction UP
        -- setting color
        rectUp = display.newRect( 34, display.contentHeight - 70, 23, 23 )
        rectUp:setFillColor( 1, 0, 0 )
        rectUp.id = "up"
        -- setting visibility
        rectUp.isVisible = false
        rectUp.isHitTestable = true
        -- adding to view
        scene.view:insert(rectUp)

        -- direction DOWN
        -- setting color
        rectDown = display.newRect( 34, display.contentHeight - 23, 23, 23 )
        rectDown:setFillColor( 1, 0, 0 )
        rectDown.id = "down"
        -- setting visibility
        rectDown.isVisible = false
        rectDown.isHitTestable = true
        -- adding to view
        scene.view:insert(rectDown)

        -- direction LEFT
        -- setting color
        rectLeft = display.newRect( 10, display.contentHeight - 47, 23, 23 )
        rectLeft:setFillColor( 1, 0, 0 )
        rectLeft.id = "left"
        -- setting visibility
        rectLeft.isVisible = false
        rectLeft.isHitTestable = true
        -- adding to view
        scene.view:insert(rectLeft)

        -- direction RIGHT
        -- setting color
        rectRight = display.newRect( 58, display.contentHeight - 47, 23, 23 )
        rectRight:setFillColor( 1, 0, 0 )
        rectRight.id = "right"
        -- setting visibility
        rectRight.isVisible = false
        rectRight.isHitTestable = true
        -- adding to view
        scene.view:insert(rectRight)

    end

-- Setting empty grid for showing enemies

    function resetPlaneGrid( )
        planeGrid = { }
            -- reset all fields in planeGrid
            for i = 1, 11 do
                table.insert( planeGrid, 0 )
            end
    end

-- Movement of Plane on scene

    -- when player touches the DPad ('began') - planes moves in desierd location, when player stops pressing button ('ended') - planes stops moving
    function movePlane ( event )
        if event.phase == "began" then
            -- moving up
            if (event.target.id == "up") then
                playerSpeedY = -playerMoveSpeed
            end

            -- moving down
            if (event.target.id == "down") then
                playerSpeedY = playerMoveSpeed
            end

            -- moving left
            if (event.target.id == "left") then
                playerSpeedY = -playerMoveSpeed
            end

            -- moving right
            if (event.target.id == "right") then
                playerSpeedY = playerMoveSpeed
            end

        elseif event.phase == "ended" then
            playerSpeedX = 0
            playerSpeedY = 0
        end
    end

-- Movement of Plane on scene, on every frame of game this function is triggered
-- when movePlayer is triggered each time position of player.x and player.y is updated

    function movePLayer ( )
        -- position of player on screen
        player.x = player.x + playerSpeedX
        player.y = player.y + playerSpeedY

        -- boundary conditions

            -- state when X is smaller then 0
            if (player.x < 0) then
                player.x = 0
            end

            -- state when X is out of screen
            if (player.x > display.contentWidth - playerWidth) then
                player.x = display.contentWidth - playerWidth
            end

            -- state when Y is smaller then 0
            if (player.y < 0) then
                player.y = 0
            end

            -- state when Y is out of screen
            if (player.y > display.contentHeight - 70 - playerHeight) then
                player.y = display.contentHeight - 70 - playerHeight
            end
    end

-- function, that updates position of every sprite element on each frame
        function gameLoop ( )
            numberOfTicks = numberOfTicks + 1
            movePLayer()
        end


-- Adding Listeners to scene






-- Element return - required for module

	return scene