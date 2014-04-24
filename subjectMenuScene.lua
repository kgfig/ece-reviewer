--[[
	-------------------------------------
			Choose a subject scene
	-------------------------------------
--]]

-- Import modules

local images = require "appImages"
local storyboard = require "storyboard"
require "storyboardex"

-- Initialize static module-specific info

local subjects = {}
subjects["GEAS"] = { buttonX=display.contentWidth / 3, buttonY=display.contentHeight / 3, buttonFilename=images.geasIcon }
subjects["Math"] = { buttonX=display.contentWidth / 3 * 2, buttonY=display.contentHeight / 3, buttonFilename=images.mathIcon }
subjects["ELEX"] = { buttonX=display.contentWidth / 3, buttonY=display.contentHeight / 2, buttonFilename=images.elexIcon }
subjects["EST"] = { buttonX=display.contentWidth / 3 * 2, buttonY=display.contentHeight / 2, buttonFilename=images.estIcon }

-- Declare scene objects

local background, chooseSubject, subjectButtons, highScoreButton, exitButton

-- Make new scene object

local scene = storyboard.newScene()

--[[
	Object event handlers
--]]

local function onSubjectButtonTap( self, event )
	storyboard.state.chosenSubject = self.subjectName
	storyboard.gotoScene( "chooseModeScene", { effect = "slideLeft", time = 500, params = {} } )
end

local function onExitButtonTap( self, event )
	os.exit()
end

local function onHighScoreButtonTap( self, event )
	storyboard.gotoScene( "highScoreScene", { effect = "slideLeft", time = 500, params = {} } )
end

--[[
	Scene event handlers
--]]

-- Create scene event handler

function scene:createScene( event )
	scene:setScene( event )
end

function scene:setScene( event )

	-- Scene display group
	
	local group = scene.view
	
	-- Static UI elements
	
	background = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	background:setFillColor( 255, 255, 255 )

	chooseSubject = display.newImage( images.chooseASubject )
	chooseSubject.x = display.contentWidth / 2
	chooseSubject.y = display.contentHeight / 5

	-- High score button and exit button

	highScoreButton = display.newImage( images.highScores )
	highScoreButton.x = display.contentWidth - 120
	highScoreButton.y = display.contentHeight - 50

	exitButton = display.newImage( images.exitButton )
	exitButton.x = 80
	exitButton.y = display.contentHeight - 50
	
	-- Subject buttons
	
	subjectButtons = {}
	for subjectName, subjectProperty in pairs( subjects ) do
		subjectButtons[subjectName] = display.newImage( subjectProperty.buttonFilename )
		subjectButtons[subjectName].x = subjectProperty.buttonX
		subjectButtons[subjectName].y = subjectProperty.buttonY
		subjectButtons[subjectName].subjectName = subjectName
	end
	
	-- Add objects to group
	
	group:insert( background )
	group:insert( chooseSubject )
	group:insert( highScoreButton)
	group:insert( exitButton )
	
	for subjectName, subjectButton in pairs( subjectButtons ) do
		group:insert( subjectButton )
	end
	
	-- Add event handling functions as object properties
	
	highScoreButton.tap = onHighScoreButtonTap
	exitButton.tap = onExitButtonTap
	
	for subjectName, subjectButton in pairs( subjectButtons ) do
		subjectButton.tap = onSubjectButtonTap
	end
	
end

-- Enter scene handler

function scene:enterScene( event )

	-- Add event handlers to objects

	highScoreButton:addEventListener( "tap", highScoreButton )
	exitButton:addEventListener( "tap", exitButton )
	
	for subjectName, subjectButton in pairs( subjectButtons ) do
		subjectButton:addEventListener( "tap", subjectButton )
	end

end

-- Exit scene handler

function scene:exitScene()

	-- Remove event handlers from objects
	
	highScoreButton:removeEventListener( "tap", highScoreButton )
	exitButton:removeEventListener( "tap", exitButton )
	
	for subjectName, subjectButton in pairs( subjectButtons ) do
		subjectButton:removeEventListener( "tap", subjectButton )
	end

end

-- Add event handlers to scene

scene:addEventListener( "createScene", scene )
scene:addEventListener( "setScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )

return scene