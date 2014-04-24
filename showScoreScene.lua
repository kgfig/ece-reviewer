--[[
	----------------------------
		Show score scene
	----------------------------
--]]

-- Import modules

local images = require "appImages"
local storyboard = require "storyboard"
require "storyboardex"

-- Initialize static module-specific info

local scorePercent, scorePercentRoundOff
local scorePercentCategories = {
	{ percentMin=0, percentMax=49, remarkFilename=images.tryAgain },
	{ percentMin=50, percentMax=74, remarkFilename=images.youPassed },
	{ percentMin=75, percentMax=84, remarkFilename=images.goodJob },
	{ percentMin=85, percentMax=94, remarkFilename=images.awesome },
	{ percentMin=95, percentMax=100, remarkFilename=images.crazyAwesome }
}

-- Declare scene objects

local background, chosenSubject, scorePercentTitle, scorePercentText, remarkText, exitButton, newTextButton

-- Make new storyboard scene

local scene = storyboard.newScene()

--[[
	Object event handlers
--]]

local function onNewButtonTap( self, event )

	storyboard.state.currentScore = 0
	storyboard.state.currentScorePercentage = 0
	storyboard.state.currentQuestionNumber = 0
	storyboard.state.questionCount = 0
	storyboard.state.chosenMode = "None"
	storyboard.state.chosenSubject = "None"
	storyboard.state.currentTestQuestions = nil
	storyboard.state.userChoice = nil
	
	storyboard.removeScene( scene )
	storyboard.gotoScene( "subjectMenuScene", { effect = "slideLeft", time = 500, params = {} } )
end

local function onExitButtonTap( self, event )

	storyboard.state.currentScore = 0
	storyboard.state.currentScorePercentage = 0
	storyboard.state.currentQuestionNumber = 0
	storyboard.state.questionCount = 0
	storyboard.state.chosenMode = "None"
	storyboard.state.chosenSubject = "None"
	storyboard.state.currentTestQuestions = nil
	storyboard.state.userChoice = nil
	os.exit()
end

--[[
	Scene event handlers
--]]

-- Create scene event handler

function scene:createScene( event )
	scene:setScene( event )
end

function scene:setScene( event )
	-- Get score percent
	
	scorePercent = storyboard.state.currentScorePercentage
	scorePercentRoundOff = math.floor( scorePercent + 0.5 )
	
	-- Display scene group

	local group = scene.view

	background = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	background:setFillColor( 255, 255, 255 )

	chosenSubject = display.newText( "GEAS", 20, 20, nil, 28 )
	chosenSubject:setTextColor( 10, 10, 10 )

	scorePercentTitle = display.newImage( images.totalScoreTitle )
	scorePercentTitle.x = display.contentWidth / 2
	scorePercentTitle.y = display.contentHeight / 3.5

	scorePercentText = display.newImage( string.format( images.scorePercentTitle, scorePercentRoundOff ) )
	scorePercentText.x = display.contentWidth / 2
	scorePercentText.y = display.contentHeight / 2.5

	for category, cProperty in pairs( scorePercentCategories ) do
		if scorePercent >= cProperty.percentMin and scorePercent <= cProperty.percentMax then
			remarkText = display.newImage( cProperty["remarkFilename"])
			remarkText.x = display.contentWidth / 2
			remarkText.y = display.contentHeight / 2
			break
		end
	end

	newTextButton = display.newImage( images.newTest )
	newTextButton.x = display.contentWidth - 150
	newTextButton.y = display.contentHeight - 50
	
	exitButton = display.newImage( images.exitButton )
	exitButton.x = 70
	exitButton.y = display.contentHeight - 50

	-- Add objects to display group
	
	group:insert( background )
	group:insert( chosenSubject )
	group:insert( scorePercentTitle )
	group:insert( scorePercentText )
	group:insert( remarkText )
	group:insert( newTextButton )
	group:insert( exitButton )

end

function scene:enterScene( event )
	newTextButton.tap = onNewButtonTap
	exitButton.tap = onExitButtonTap
	
	newTextButton:addEventListener( "tap", newTextButton )
	exitButton:addEventListener( "tap", exitButton )
end

function scene:exitScene( event )
	newTextButton:removeEventListener( "tap", newTextButton )
	exitButton:removeEventListener( "tap", exitButton )
end

-- Add scene handlers

scene:addEventListener( "createScene", scene)
scene:addEventListener( "setScene", scene )
scene:addEventListener( "enterScene", scene)
scene:addEventListener( "exitScene", scene)

return scene