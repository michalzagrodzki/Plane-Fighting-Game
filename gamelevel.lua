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
    local numberofEnemiesToGenerate = 0
    local numberOfEnemiesGenerated = 0

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

        -- start timers
        startTimers( )

        -- generate enemies
        generateEnemies( )


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

            -- function regarding player
            movePLayer( )
            movePlayerBullets( )
            checkPlayerBulletsOutOfBounds( )

            -- functions regarding islands
            moveIslands( )
            checkIslandsOutOfBounds( )

            -- functions regarding extra lifes
            moveFreeLifes( )
            checkFreeLifesOutOfBounds( )
            checkPlayerCollidesWithFreeLife( )

            -- functions regarding enemy planes
            moveEnemyPlane( )
            moveEnemyBullets( )
            checkEnemyBulletsOutOfBounds( )
            checkEnemyPlanesOutOfBounds( )
            checkEnemyPlanesCollideWithPlayer( )

        end

-- start timers

    -- firing bullets (firePlayerBullet) all the time
    -- creating islands all the time
    -- creating extra lifes all the time
    function startTimers( )
        firePlayerBulletTimer   = timer.performWithDelay( 2000, firePlayerBullet, -1 )
        generateIslandTimer     = timer.performWithDelay( 5000, generateIsland, -1 )
        generateFreeLife        = timer.performWithDelay( 7000, generateFreeLife, -1 )
        fireEnemyBulletsTimer   = timer.performWithDelay( 2000, fireEnemyBullets, -1 )
    end

-- create bullet fired by player

    function firePlayerBullet ( )
        local tempBullet = display.newImage( "bullet.png" (player.x + playerWidth / 2) - bulletWidth, player.y - bulletHeight )
        -- insert for later reference in table playerBullets
        table.insert( playerBullets, tempBullet )
        planeGroup:insert(tempBullet)
    end

-- move bullet fired by player

    function movePlayerBullets( )
        if ( #playerBullets > 0 ) then
            for i = 1, #playerBullets do
                playerBullets[ i ].y = playerBullets[ i ].y - 7
            end
        end
    end

-- remove bullets out of screen

    -- table is looped in reversed order
    function checkPlayerBulletsOutOfBounds( )
        if ( #playerBullets > 0 ) then
            -- reverse loop through table
            for i = #playerBullets, 1, -1 do
                if (playerBullets[i].y - 18) then
                    playerBullets[i]:removeSelf( )
                    playerBullets[i] = nil
                    table.remove( playerBullets, i )
                end
            end
        end
    end

-- generate islands - decorator elements of gameplay

    function generateIsland( )
        local tempIsland = display.newImage( "island.png", (math.random(0, display.contentWidth - islandWidth)), (-islandHeight) )
        -- insert for later reference in table islands
        table.insert( islands, tempIsland )
    end

-- movement of islands

    function moveIslands ( )
        if ( #islands > 0 ) then
            for i = 1, #islands do
                islands[ i ].y = islands[ i ].y + 3
            end
        end
    end

-- remove islands out of screen

    function checkIslandsOutOfBounds ( )
        if ( #islands > 0 ) then
            -- reverse loop through table
            for i = #islands, 1, -1 do
                if (islands[i].y > display.contentHeight) then
                    islands[i]:removeSelf( )
                    islands[i] = nil
                    table.remove(islands, i)
                end
            end
        end
    end

-- generate of lifes

    function generateFreeLife ( )
        -- if number of lifes is bigger than 6 then do nothing
        if ( numberOfLives >= 6 ) then
            return
        end

        local freeLife = display.newImage( "newlife.png", math.random( 0, display.contentWidth - 40 ), 0 )
        -- insert for later reference in table freeLifes
        table.insert( freeLifes, freeLife )
        planeGroup:insert( freeLife )
    end

-- movement of lifes

    function moveFreeLifes ( )
        if (#freeLifes > 0) then
            for i = 1, #freeLifes do
                freeLifes[ i ].y = freeLifes[ i ].y + 5
            end
        end
    end

-- remove lifes out of screen

    function checkFreeLifesOutOfBounds ( )
        if ( #freeLifes > 0 ) then
            -- reverse loop through table
            for i = #freeLifes, 1, -1 do
                if (freeLifes[ i ].y > display.contentHeight) then
                    freeLifes[ i ]:removeSelf( )
                    freeLifes[ i ] = nil
                    table.remove( freeLifes, i )
                end
            end
        end
    end

-- general simplified logic for collision of two objects

    function hasCollided( object1, object2 )
        -- boundary conditions
        if (object1 == nil) then
            return false
        end
        if (object2 == nil) then
            return false
        end

        local left      = object1.contentBounds.xMin <= object2.contentBounds.xMin and object1.contentBounds.xMax >= object2.contentBounds.xMin
        local right     = object1.contentBounds.xMin >= object2.contentBounds.xMin and object1.contentBounds.xMin <= object2.contentBounds.xMax
        local up        = object1.contentBounds.yMin <= object2.contentBounds.yMin and object1.contentBounds.yMax >= object2.contentBounds.yMin
        local down      = object1.contentBounds.yMin >= object2.contentBounds.yMin and object1.contentBounds.yMin <= object2.contentBounds.yMax

        return (left or right) and (up or down)
    end

-- collision of player and freeLife

    function checkPlayerCollidesWithFreeLife( )
        if (#freeLifes > 0) then
            -- reverse loop through table
            for i = #freeLifes, 1, -1 do
                -- when there is collision between player and free life
                if (hasCollided (freeLifes[i], player )) then
                    -- remove life from table
                    freeLifes[i]:removeSelf( )
                    freeLifes[i] = nil
                    table.remove( freeLifes, i )
                    -- add extra life to player
                    numberOfLives = numberOfLives + 1
                    hideLives()
                    showLives()
                end
            end
        end
    end

-- hides all lifes between 1 and 6 in table

    function hideLives( )
        for i = 1, 6 do
            livesImages[ i ].isVisible = false
        end
    end

-- shows all lifes between 1 and numberOfLives in table

    function showLives( )
        for i = 1, numberOfLives do
            livesImages[ i ].isVisible = true
        end
    end

-- generation of enemies - number of enemies to be called (between 3 and 7 every 2 seconds)

    function generateEnemies( )
        numberofEnemiesToGenerate = math.random( 3, 7 )
        timer.performWithDelay( 2000, generateEnemyPlane, numberofEnemiesToGenerate )
    end

-- generate single enemy plane

    -- Three types of enemy planes
        -- regular - moves down the screen in straight line
        -- waver - moves on wave pattern on x axis
        -- chaser - chases the players plane

    function generateEnemyPlane( )
        -- check if game is not over
        -- generate randomGridSpace - to position enemy plane
        -- generate randomEnemyNumber - to select type of enemy
        if ( gameOver ~= true ) then
            local randomGridSpace = math.random( 11 )
            local randomEnemyNumber = math.random( 3 )
            local tempEnemy

            -- if slot of planeGrid is taken, we return function (end it)
            if ( planeGrid[randomGridSpace] ~= 0 ) then
                generateEnemyPlane( )
            return

            -- generate specific type of enemy (regular, waver, chaser) based on randomEnemyNumber
            else
                    if ( randomEnemyNumber == 1 ) then
                        tempEnemy = display.newImage( "enemy1.png", (randomGridSpace*65) - 28, -60 )
                        tempEnemy.type = "regular"
                    elseif ( randomEnemyNumber == 2 ) then
                        tempEnemy = display.newImage( "enemy2.png", display.contentWidth / 2 - playerWidth / 2, -60 )
                        tempEnemy.type = "waver"
                    else
                        tempEnemy = display.newImage( "ënemy3.png",  )
                        tempEnemy.type = "chaser"
                    end
                -- set up slot to 1, insert enemyPlane for later reference
                planeGrid[randomGridSpace] = 1
                table.insert( enemyPlanes, tempEnemy )
                planeGroup:insert( tempEnemy )
                numberOfEnemiesGenerated = numberOfEnemiesGenerated + 1
            end

            -- checks if number of enemies on screen is between 3 and 7, if it is true we reset counter, reset grid and delay function for 2 seconds
            if (numberOfEnemiesGenerated == numberofEnemiesToGenerate) then
                numberofEnemiesToGenerate = 0
                resetPlaneGrid()
                timer.performWithDelay( 2000, generateEnemies, 1 )
            end
        end
    end

-- movement of enemy planes

    -- setting different types of movement (regular, waver, chaser)
    function moveEnemyPlane( )
        if (#enemyPlanes > 0) then
            for i = 1 , #enemyPlanes do
                -- movement of 'regular' plane
                if (enemyPlanes[ i ].type == "regular") then
                    moveRegularPlane(enemyPlanes[i])
                -- movement of 'waver' plane
                elseif( enemyPlanes[ i ].type == "waver" ) then
                    moveWaverPlane(enemyPlanes[i])
                -- movement of 'chaser' plane
                else
                    moveChaserPlane(enemyPlane[i])
                end
            end
        end
    end

-- movement of regular plane

    function moveRegularPlane( )
        plane.y = plane.y + 4
    end

-- movement of waver plane

    function moveWaverPlane( )
        plane.y = plane.y + 4
        plane.x = (display.contentWidth / 2) + 250 * math.cos( numberOfTicks * 0.5 * math.pi / 30 )
    end

-- movement of chaser plane (towards plane)

    function moveChaserPlane( plane )
        if ( plane.x < player.x ) then
            plane.x = plane.x + 4
        end

        if ( plane.x > player.x ) then
            plane.x = plane.x -4
        end

        plane.y = plane.y + 4
    end

-- create bullet fired by enemy

    function fireEnemyBullets( )
        -- checks if there are at least two planes
        if ( #enemyBullets >= 2 ) then
            -- returns integer smaller or equal than half of #enemyPlanes
            local numberOfEnemyPlanesToFire = math.floor( #enemyPlanes / 2 )
            -- copy table from enemyPlanes to make independent manipulations
            local tempEnemyPlanes = table.copy( enemyPlanes )

            -- function for firing bullets
            local function fireBullet( )
                -- chooses enemy from table of enemy planes
                local randIndex = math.random( #tempEnemyPlanes )
                -- bullet fired
                local tempBullet = display.newImage( "bullet.png", (tempEnemyPlanes[randIndex].x + playerWidth / 2) + bulletWidth, tempEnemyPlanes[randIndex].y + playerHeight + bulletHeight )
                tempBullet.rotation = 180
                -- reference input
                planeGroup:insert( tempBullet )
                table.insert( enemyBullets, tempBullet )
                table.remove( tempEnemyPlanes, randIndex )
            end

            -- choose enemy to fire from range of 0 and half of the enemies in enemy table
            for i = 0 , numberOfEnemyPlanesToFire do
                fireBullet()
            end
        end
    end

-- movement of enemy bullets

    function moveEnemyBullets( )
        if ( #enemyBullets > 0 ) then
            for i = 1, #enemyBullets do
                enemyBullets[ i ].y = enemyBullets[ i ] + 7
            end
        end
    end

-- remove bullets out of screen

    function checkEnemyBulletsOutOfBounds( )
        if ( #enemyBullets > 0 ) then
            for i = 1, #enemyBullets do
                if (enemyBullets[ i ].y > display.contentHeight) then
                    enemyBullets[ i ]:removeSelf( )
                    enemyBullets[ i ] = nil
                    table.remove( enemyBullets, i )
                end
            end
        end
    end

-- remove enemy planes out of screen

    function checkEnemyPlanesOutOfBounds( )
        if (#enemyPlanes > 0) then
            for i = 1 , #enemyPlanes do
                if (enemyPlanes[ i ].y > display.contentHeight) then
                    enemyPlanes[ i ]:removeSelf( )
                    enemyPlanes[ i ] = nil
                    table.remove( enemyPlanes, i )
                end
            end
        end
    end

-- collision of enemy bullets with player

    function checkEnemyBulletsCollideWithPlayer( )
        if (#enemyBullets > 0) then
            -- loop through table of bullets and check if it had collided with player
            for i = #enemyBullets, 1, -1 do
                -- when collided, remove bullet
                if ( hasCollided( enemyBullets[ i ], player ) ) then
                    enemyBullets[ i ]:removeSelf( )
                    enemyBullets[ i ] = nil
                    table.remove( enemyBullets, i )
                        -- when player is not invincible - kill him
                        if (playerIsInvincible == false) then
                            killPlayer()
                        end
                end
            end
        end
    end

-- kills player - checks if game is over when number of lives is less then 0, if not respawns player

    function killPlayer( )
        -- reduces number of lifes by 1 when killed
        numberOfLives = numberOfLives - 1

        -- goes to gameover screen when player have 0 lives
        if ( numberOfLives == 0 ) then
            gameOver = true
            doGameOver( )

        -- if player is killed and still have lifes - respawns new player and make him invincible for period
        else
            spawnNewPlayer( )
            hideLives( )
            showLives( )
            playerIsInvincible = true
        end
    end

-- go to 'gameover scene'

    function gameOver( )
        composer.gotoScene( "gameover" )
    end

-- spawn new player

    function spawnNewPlayer( )
        -- fading player five times
        local numberOfTimesToFadePlayer = 5
        local numberOfTimesPlayerHasFaded = 0

            -- function that will fade player
            local function fadePlayer( )
                player.alpha = 0
                transition.to( player, {time = 200, alpha = 1} )
                numberOfTimesPlayerHasFaded = numberOfTimesPlayerHasFaded + 1
                -- ending invincibleness of player
                if (numberOfTimesPlayerHasFaded == numberOfTimesToFadePlayer) then
                    playerIsInvincible = false
                end
            end
        -- timer for fading in and out of player
        timer.performWithDelay( 400, fadePlayer, numberOfTimesToFadePlayer )

    end

-- Element return - required for module

	return scene