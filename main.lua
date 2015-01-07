-- DISCLAIMER -- CODE IS INTENDATED FOR ROLLING UP IN IDE 

-- Hide status bar

	display.setStatusBar( display.HiddenStatusBar )

-- Set anchor points - registration point of display - upper left side

	display.setDefault( "anchorX", 0 )
	display.setDefault( "anchorY", 0 )

-- Random generator for code

	math.randomseed( os.time( ) )

-- Calling Composer library to our game

	local composer = require "composer"

-- Load start screen (it sends application to file 'start.lua'), existing scene is hidden

	composer.gotoScene( "start" )