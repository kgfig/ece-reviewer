--[[
	--------------------------
		Ask question scene
	--------------------------
--]]

-- Import modules

local images = require "appImages"
local storyboard = require "storyboard"
require "storyboardex"

-- Initialize static module-specific info

local questionItem, userChoice, chosenSubject

-- Declare scene objects

local background, chosenSubjectText, questionNumber, scoreBar, questionText, choicesText, submitButton

-- Make new storyboard scene

local scene = storyboard.newScene()

--[[
	Object event handlers
--]]

local function onChoiceTextTap( self, event )
	userChoice = self.choice
	
	-- Show selected answer
	for choiceId, choiceText in pairs( choicesText ) do
		if userChoice.answer == choiceText.choice.answer then
			choiceText:setTextColor( 53, 134, 244 )
		else
			choiceText:setTextColor( 0, 0, 0 )
		end
	end
end

local function onSubmitButtonTap( self, event )
	if userChoice then	
	
		if userChoice.answer == questionItem.correctChoice.answer then
			storyboard.state.currentScore = storyboard.state.currentScore + 1 
			storyboard.state.currentScorePercentage = storyboard.state.currentScore / storyboard.state.questionCount * 100
		end
		
		storyboard.removeScene( scene )
		storyboard.gotoScene( "showAnswerScene", { params = { userChoice = userChoice, questionItem = questionItem } } )
	end
end

--[[
	Scene event handlers
--]]

-- Create scene handler

function scene:createScene( event )
	scene:setScene( event )
end

function scene:setScene( event )

	-- Get current question item
	
	questionItem = nil
	userChoice = nil
	
	chosenSubject = storyboard.state.chosenSubject
	questionItem = storyboard.state.currentTestQuestions[storyboard.state.currentQuestionNumber]
	userChoice = storyboard.state.userChoice
	
	-- Display scene group
	
	local group = scene.view
	
	-- Initialize UI objects
	
	background = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	background:setFillColor( 255, 255, 255 )
	
	submitButton = display.newImage( images.submitButton )
	submitButton.x = display.contentWidth - 100
	submitButton.y = display.contentHeight - 50
	
	chosenSubjectText = display.newText( chosenSubject, 20, 20, nil, 32 )
	chosenSubjectText:setTextColor( 10, 10, 10 )
	
	questionNumber = display.newText( "Question " .. storyboard.state.currentQuestionNumber .. " of " .. storyboard.state.questionCount, display.contentWidth - 230, 60, nil, 28 )
	questionNumber:setTextColor( 10, 10, 10 )

	-- Note: resize all progress bars to 70% smaller maintaining aspect ratio, then 60% horizontal only
	local roundOff = math.floor( storyboard.state.currentScorePercentage + 0.5 )
	scoreBar = display.newImage( string.format( images.scoreProgressBar, roundOff ) )
	scoreBar.x = display.contentWidth - 120
	scoreBar.y = questionNumber.y + 45

	questionText = display.newText( questionItem.question, 20, display.contentHeight / 4, display.contentWidth - 40, 0, nil, 24 )
	questionText:setTextColor ( 0, 0, 0 )

	choicesText = nil
	choicesText = {}
	local previousY = questionText.contentBounds.yMax + 30
	local letters = { "a", "b", "c", "d", "e" }
	local letterIdx = 1

	for choiceId, choiceItem in pairs( questionItem.choices ) do
		choicesText[choiceId] = display.newText( letters[letterIdx] .. ". " .. choiceItem.answer, 35, previousY, display.contentWidth - 50, 0, nil, 24 )
		choicesText[choiceId]:setTextColor( 0, 0, 0 )
		choicesText[choiceId].choice = choiceItem
		
		previousY = choicesText[choiceId].contentBounds.yMax + 20
		letterIdx = letterIdx + 1
	end

	-- Add objects to group

	group:insert( background )
	group:insert( submitButton )
	
	group:insert( chosenSubjectText )
	group:insert( questionNumber )
	group:insert( scoreBar )
	group:insert( questionText )
	
	for letter, choiceText in pairs( choicesText ) do
		group:insert( choiceText )
	end
	
end

-- Enter scene handler

function scene:enterScene( event )
	-- Add UI controls
	
	submitButton.tap = onSubmitButtonTap
	submitButton:addEventListener( "tap", submitButton )
	
	for letter, choiceText in pairs( choicesText ) do
		choiceText.tap = onChoiceTextTap
		choiceText:addEventListener( "tap", choiceText )
	end
	
end

-- Exit scene handler

function scene:exitScene( event )
	-- Remove UI controls
	
	for id, choiceText in pairs( choicesText ) do
		choiceText:removeEventListener( "tap", choiceText )
	end
		
	submitButton:removeEventListener( "tap", submitButton )
	
	background:removeSelf()
	submitButton:removeSelf()
	
	chosenSubjectText:removeSelf()
	questionNumber:removeSelf()
	scoreBar:removeSelf()
	questionText:removeSelf()
	
	for letter, choiceText in pairs( choicesText ) do
		choiceText:removeSelf()
	end
	
end

scene:addEventListener( "createScene", scene)
scene:addEventListener( "setScene", scene)
scene:addEventListener( "enterScene", scene)
scene:addEventListener( "exitScene", scene)

return scene