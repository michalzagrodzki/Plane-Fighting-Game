-- DISCLAIMER -- CODE IS INTENDATED FOR ROLLING UP IN IDE 

-- Hide status bar

	display.setStatusBar( display.HiddenStatusBar )

-- Set anchor points - registration point of display - upper left side

	display.setDefault( "anchorX", 0 )
	display.setDefault( "anchorY", 0 )

-- Random generator for code

	math.randomseed( os.time( ) )

-- Calling Storyboard library to our game

	local storyboard = require "storyboard"

-- Load start screen (it sends application to file 'start.lua')

	storyboard.gotoScene( "start" )