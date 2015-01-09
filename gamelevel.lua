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
        setupBackground()
    end

-- Setting background

    function setupBackground(  )
        local background = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
        background:setFillColor( 0, 0, 1 )
        scene.view:insert( background )
    end

-- Adding Listeners to scene

    scene:addEventListener( "create", scene )

-- Element return - required for module

	return scene