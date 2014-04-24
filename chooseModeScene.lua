--[[
	----------------------------
			Choose mode
	----------------------------
--]]

-- Import modules

local images = require "appImages"
local randomSelect = require "randomIdSelector"
local storyboard = require "storyboard"
require "storyboardex"

-- Initialize static module-specific info

local modes = {}
modes["Short Quiz"] = { 
	questionCount = 30,
	buttonX = display.contentWidth / 2, 
	buttonY = display.contentHeight / 3 + 50, 
	filename = images.shortQuiz
}

modes["Long Exam"] = { 
	questionCount = 50,
	buttonX = display.contentWidth / 2, 
	buttonY = display.contentHeight / 3 + 150, 
	filename = images.longExam
}

modes["Practice Test"] = { 
	questionCount = 100,
	buttonX = display.contentWidth / 2, 
	buttonY = display.contentHeight / 3 + 250, 
	filename = images.practiceTest
}

-- Declare scene objects

local background, chosenSubjectText, chooseMode, modeButtons

-- Make new storyboard scene

local scene = storyboard.newScene()

--[[
	Object event handlers
-]]

local function onTestModeButtonTap( self, event )

	if storyboard.state.chosenSubject == "ELEX" then
		storyboard.state.chosenMode = self.mode
		storyboard.state.questionCount = self.questionCount
		storyboard.state.currentTestQuestions = nil
		
		-- get min, max question id of questions for this subject
		local idTable = storyboard.state.db.getMinMaxQuestionIdBySubject( storyboard.state.chosenSubject )
		
		-- randomly select test questions based on ids
		local idSet = randomSelect( idTable.min, idTable.max, storyboard.state.questionCount )
		
		-- get subject test questions
		local subjectTestQuestions = storyboard.state.db.getQuestionsBySubjectAndIdRange( storyboard.state.chosenSubject, idSet )
		local currentTestQuestions = {}
		
		for qid, questionItem in pairs( subjectTestQuestions ) do
			table.insert( currentTestQuestions, questionItem )
		end
		
		storyboard.state.currentTestQuestions = currentTestQuestions
		storyboard.state.currentQuestionNumber = 1
		storyboard.state.currentScore = 0
		storyboard.state.currentScorePercentage = 0
		storyboard.state.userChoice = nil
		
		storyboard.gotoScene( "askQuestionScene", { effect = "slideLeft", time = 500, params = {} } )
	end
end

local function onTouchSlide( self, event )
	if event.phase == "moved" then
		if event.x > event.xStart then
			storyboard.state.chosenMode = "None"
			storyboard.state.chosenSubject = "None"
			storyboard.state.currentTestQuestions = {}
			storyboard.state.userChoice = nil
			storyboard.gotoScene( "subjectMenuScene", { effect = "slideRight", time = 500, params = {} } )
		end
	end
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

	-- Initialize static UI elements
	
	background = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	background:setFillColor( 255, 255, 255 )

	chosenSubjectText = display.newText( storyboard.state.chosenSubject, 20, 20, nil, 32 )
	chosenSubjectText:setTextColor( 10, 10, 10 )

	chooseMode = display.newImage( images.chooseMode )
	chooseMode.x = display.contentWidth / 2
	chooseMode.y = display.contentHeight / 4
	
	-- Mode buttons
	modeButtons = {}
	for mode,modeProperty in pairs( modes ) do
		modeButtons[mode] = display.newImage( modeProperty.filename )
		modeButtons[mode].x = modeProperty.buttonX
		modeButtons[mode].y = modeProperty.buttonY
		modeButtons[mode].mode = mode
		modeButtons[mode].questionCount = modeProperty.questionCount
	end
	
	-- Add objects to group
	
	group:insert( background )
	group:insert( chosenSubjectText )
	group:insert( chooseMode )
	
	for mode, modeButton in pairs( modeButtons ) do
		group:insert( modeButton )
	end
	
	-- Add local event handling functions as object properties
	
	background.touch = onTouchSlide
	
	for mode, modeButton in pairs( modeButtons ) do
		modeButton.tap = onTestModeButtonTap
	end
	
end

-- Enter scene event handler

function scene:enterScene( event ) 

	background:addEventListener( "touch", background )

	for mode, modeButton in pairs( modeButtons ) do
		modeButton:addEventListener( "tap", modeButton )
	end
	
end

-- Exit scene event handler

function scene:exitScene( event ) 

	background:removeEventListener( "touch", background )

	for mode, modeButton in pairs( modeButtons ) do
		modeButton:removeEventListener( "tap", modeButton )
	end
	
end

-- Add scene event handlers
	
scene:addEventListener( "createScene", scene )
scene:addEventListener( "setScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )

return scene