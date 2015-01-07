
-- Call Composer

	local composer = 	require( "composer" )
	local scene = 		composer.newScene( )

-- Variable for connection to storyboard, it starts the scene

	local startButton

-- Create 'start scene'

	function scene:create( event )

		-- group object for entire view of this scene
		local sceneGroup = self.view

		-- add graphic elements to screen
		local background 	= display.newRect( sceneGroup, 0, 0, display.contentWidth, display.contentHeight )
							background:setFillColor( 0, .39, .75 )
		local bigPlane 		= display.newImage( sceneGroup, "bigplane.png", 0, 0 )
		startButton 		= display.newImage( sceneGroup, "starbutton.png", 264, 670 )
	end

-- Show 'start scene'

	function scene:show( event )
		startButton:addEventListener( "tap", startGame )
	end

-- Hide 'start scene'

	function scene:hide( event )
		startButton:removeEventListener( "tap", startGame )
	end

-- Function which sends to 'gamelevel'
	
	function startGame( )
		composer.gotoScene( 'gamelevel' )
	end

-- Adding Listeners to scene

	scene:addEventListener( "create", scene )
	scene:addEventListener( "show", scene )
	scene:addEventListener( "hide", scene )

-- Element return - required for module

	return scene