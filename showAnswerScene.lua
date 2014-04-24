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

local background, chosenSubjectText, questionNumber, scoreBar, questionText, choicesText, nextButton

-- Make new storyboard scene

local scene = storyboard.newScene()

--[[
	Object event handlers
--]]

local function onNextButtonTap( self, event )
	if storyboard.state.currentQuestionNumber < storyboard.state.questionCount then
		storyboard.state.currentQuestionNumber = storyboard.state.currentQuestionNumber + 1
		storyboard.removeScene( scene )
		storyboard.gotoScene( "askQuestionScene", { effect = "slideLeft", time = 500, params={} } )
	else
		storyboard.removeScene( scene )
		-- save score to database if new high score
		if storyboard.state.currentScorePercentage > storyboard.state.db.getBestScoreBySubjectMode( storyboard.state.chosenSubject, storyboard.state.chosenMode ) then
			storyboard.state.db.editBestScore( storyboard.state.chosenSubject, storyboard.state.chosenMode, storyboard.state.currentScorePercentage )
		end
		storyboard.gotoScene( "showScoreScene", { effect = "slideLeft", time = 500, params={} } )
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
	questionItem = event.params.questionItem
	userChoice = event.params.userChoice
	--questionItem = storyboard.state.currentTestQuestions[storyboard.state.currentQuestionNumber]
	--userChoice = storyboard.state.userChoice
	
	-- Display scene group
	
	local group = scene.view
	
	-- Initialize UI objects
	
	background = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	background:setFillColor( 255, 255, 255 )
	
	nextButton = display.newImage( images.nextButton )
	nextButton.x = display.contentWidth - 100
	nextButton.y = display.contentHeight - 50
	
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
		choicesText[choiceId]:setTextColor( 0, 0, 0)
		previousY = choicesText[choiceId].contentBounds.yMax + 20
		letterIdx = letterIdx + 1
	end
	
	choicesText[userChoice.id]:setTextColor( 208, 43, 40 )
	choicesText[questionItem.correctChoice.id]:setTextColor( 1, 159, 16 )

	-- Add objects to group

	group:insert( background )
	group:insert( nextButton )
	
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
	
	nextButton.tap = onNextButtonTap
	nextButton:addEventListener( "tap", nextButton )
	
end

-- Exit scene handler

function scene:exitScene( event )
	-- Remove UI controls
	
	nextButton:removeEventListener( "tap", nextButton )
end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "setScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )

return scene