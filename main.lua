
-- Imports

local storyboard = require "storyboard"
local db = require "app_db"

-- storboard state variables
storyboard.state = {}
storyboard.state.db = db
storyboard.state.chosenSubject = "None"
storyboard.state.chosenMode = "None"
storyboard.state.questionCount = 0
storyboard.state.currentScore = 0
storyboard.state.currentScorePercentage = 0
storyboard.state.currentQuestionNumber = 0
storyboard.state.currentTestQuestions = {}

storyboard.gotoScene( "subjectMenuScene", "slideRight", 500 )