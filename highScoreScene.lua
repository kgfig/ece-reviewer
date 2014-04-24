--[[
	------------------------
		View high scores
	------------------------
--]]

-- Import modules

local createGrid = require "grid"
local storyboard = require "storyboard"
require "storyboardex"

-- Initialize static module-specific info

local gridDesign = {
	cols = { display.contentWidth / 4, display.contentWidth / 4 - 20, display.contentWidth / 4 - 20, display.contentWidth / 4 - 20},
	toprowfontfix = -12, 
	leftcolfontfix = 8, 
	headerfontfix = 1, cellfontfix = 2,
	header = {
		bg = { r = 159, g = 197, b = 248, a = 100 },
		border = { r = 0, g = 0, b = 0, a = 100},
		height = 50
	},
	row = {
		bg = { r = 255, g = 255, b = 255, a = 100 },
		border = { r = 0, g = 0, b = 0, a = 100 },
		height = 50
	}
}

-- Declare scene objects

local background, temp, bestScoreGrid

-- Make new scene object

local scene = storyboard.newScene()

--[[
	Object event handlers
--]]

local function onTouchSlide( self, event )

	if event.phase == "moved" then
		if event.x > event.xStart then
			storyboard.gotoScene( "subjectMenuScene", { effect = "slideRight", time = 500, params = {} } )
		end	
	end	
	
	return true
	
end

--[[
	Scene event handlers
--]]

-- Create scene event handler

function scene:createScene( event )
	scene:setScene( event )
end

function scene:setScene( event )

	-- load data from database
	
	local allBestScores = storyboard.state.db.getBestScores()
	local itemIndex = {}
	itemIndex["Short Quiz"] = 2
	itemIndex["Long Exam"] = 3
	itemIndex["Practice Test"] = 4
	
	local gridData = {
		{ "Subject", "Short", "Long", "Practice"}
	}
	
	for subject, modeBestScores in pairs( allBestScores ) do
		gridItem = { subject, modeBestScores["Short Quiz"], modeBestScores["Long Exam"], modeBestScores["Practice Test"] }
		table.insert( gridData, gridItem )
	end

	-- Scene display group

	local group = scene.view
	
	-- Static UI elements
	
	background = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	background:setFillColor( 255, 255, 255 )
	
	temp = display.newText( "Your High Scores", display.contentWidth / 4 + 20, display.contentHeight / 4, nil, 28 )
	temp:setTextColor( 0, 0, 0 )
	
	bestScoreGrid = createGrid( gridDesign, gridData )
	bestScoreGrid.x = 30
	bestScoreGrid.y = display.contentHeight / 3
	
	-- Add objects to group
	
	group:insert( background )
	group:insert( temp )
	group:insert( bestScoreGrid )
	
	-- Add event handling functions as object properties
	
	background.touch = onTouchSlide
end

-- Enter scene handler

function scene:enterScene( event )

	-- Add event handlers to objects

	background:addEventListener( "touch", background )
end

-- Exit scene handler

function scene:exitScene( event )

	-- Add event handlers to objects
	
	background:removeEventListener( "touch", background )
end

-- Add event handlers to scene

scene:addEventListener( "createScene", scene )
scene:addEventListener( "setScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )

return scene