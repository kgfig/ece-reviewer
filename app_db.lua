local sqlite3 = require "sqlite3"
local settings = require "settings"
local allQuestions = require "questionsRepository"

local dbPath = system.pathForFile( "app_db.db", system.ResourceDirectory )
local db = sqlite3.open( dbPath )
local userDbPath = system.pathForFile( "user_db.db", system.DocumentsDirectory )
local userDb = sqlite3.open( userDbPath )
--print( dbPath .. "\t" .. userDbPath )

local allSubjects = settings.subjects
local allModes = settings.modes

local module = {}

local function onSystemEvent( event )
	if event.type == "applicationExit" then
		if db and db:isopen() then
			db:close()
		end
		
		if userDb and userDb:isopen() then
			userDb:close()
		end
	end
end

-- Define database queries

local queries = {

	-- Create table queries
	createQuestionsTable = [[CREATE TABLE IF NOT EXISTS questions (question_id INTEGER PRIMARY KEY NOT NULL, subject text, question_text text NOT NULL, correct_answer text NOT NULL, UNIQUE (question_id), UNIQUE (question_text) );]],
	createChoicesTable = [[CREATE TABLE IF NOT EXISTS choices (choice_id INTEGER PRIMARY KEY AUTOINCREMENT, question_id INTEGER, answer text NOT NULL, FOREIGN KEY (question_id) REFERENCES questions (question_id));]],
	createBestScoresTable = [[CREATE TABLE IF NOT EXISTS best_scores (best_score_id INTEGER PRIMARY KEY AUTOINCREMENT, subject text NOT NULL, mode text NOT NULL, percent_score INTEGER, UNIQUE (subject, mode));]],
	--createCurrentTestTable = [[CREATE TABLE IF NOT EXISTS current_test (question_id INTEGER, user_answer DEFAULT NULL, FOREIGN KEY (question_id) REFERENCES questions(question_id));]],
	
	-- Insert data queries
	insertQuestion = [[INSERT INTO questions VALUES (%d, "%s", "%s", "%s");]],
	insertChoicePrefix = [[INSERT INTO choices VALUES ]],
	insertChoiceValue = [[(NULL, %d, "%s")]],
	insertBestScorePrefix = [[INSERT INTO best_scores VALUES ]],
	insertBestScoreValue = [[(NULL, "%s", "%s", %d)]],
		
	-- Select queries
	selectMinMaxQuestionIdBySubject = [[SELECT MIN(question_id) as min, MAX(question_id) as max FROM questions WHERE subject="%s";]],
	selectAllQuestions = [[SELECT question_id, subject, question_text as question, correct_answer FROM questions;]],
	selectQuestionsBySubject = [[SELECT question_id, subject, question_text as question, correct_answer FROM questions WHERE subject="%s";]],
	selectQuestionsBySubjectAndIdRange = [[SELECT question_id, subject, question_text as question, correct_answer FROM questions WHERE subject="%s" and question_id in (%s);]],
	selectChoicesByQuestionId = [[SELECT choice_id, question_id, answer FROM choices WHERE question_id=%d;]],
	selectAllBestScores = [[SELECT best_score_id, subject, mode, percent_score FROM best_scores;]],
	selectBestScoreBySubjectMode = [[SELECT best_score_id, percent_score FROM best_scores WHERE subject="%s" and mode="%s";]],
	selectQuestionsCount = [[SELECT COUNT(*) as count FROM questions;]],
	selectBestScoresCount = [[SELECT COUNT(*) as count FROM best_scores;]],
	
	-- Update queries
	updateBestScoreBySubject = [[UPDATE best_scores SET percent_score=%d WHERE subject="%s" and mode="%s"]]
}

module.getMinMaxQuestionIdBySubject = function( chosenSubject )
	local idTable = { minId = 0, maxId = 0 }
	local query = string.format( queries.selectMinMaxQuestionIdBySubject, chosenSubject )
	
	for row in db:nrows( query ) do
		idTable.min = row.min
		idTable.max = row.max
	end
	
	return idTable
end

module.getQuestionsBySubject = function( chosenSubject )
	local subjectQuestions = {}
	local selectSubjectQuestionsQuery = string.format( queries.selectQuestionsBySubject, chosenSubject )
	
	for questionRow in db:nrows( selectSubjectQuestionsQuery ) do
		local selectAllQuery = string.format( queries.selectChoicesByQuestionId, questionRow.question_id )
		local questionItem = { 
			id = questionRow.question_id, 
			question = questionRow.question, 
			choices = {},
			correctChoice = nil 
		}
		
		for choice in db:nrows( selectAllQuery ) do
			local choiceItem = { id = choice.choice_id, answer = choice.answer }
			questionItem.choices[choiceItem.id] = choiceItem
			
			if questionRow.correct_answer == choice.answer then
				questionItem.correctChoice = choiceItem
			end
		end
		
		subjectQuestions[questionItem.id] = questionItem	
	end
	
	return subjectQuestions
end

module.getQuestionsBySubjectAndIdRange = function( chosenSubject, questionIds )
	local subjectQuestions, idSet, selectSubjectQuestionsQuery
	
	subjectQuestions = {}
	idSet = ""
	
	for i, qid in pairs( questionIds ) do
		idSet = idSet .. qid .. ", "
	end
	
	idSet = string.sub( idSet, 1, string.len( idSet ) - 2 )
	selectSubjectQuestionsQuery = string.format( queries.selectQuestionsBySubjectAndIdRange, chosenSubject, idSet )
	
	for questionRow in db:nrows( selectSubjectQuestionsQuery ) do
		local selectAllQuery = string.format( queries.selectChoicesByQuestionId, questionRow.question_id )
		local questionItem = { 
			id = questionRow.question_id, 
			question = questionRow.question, 
			choices = {},
			correctChoice = nil 
		}
		
		for choice in db:nrows( selectAllQuery ) do
			local choiceItem = { id = choice.choice_id, answer = choice.answer }
			questionItem.choices[choiceItem.id] = choiceItem
			
			if questionRow.correct_answer == choice.answer then
				questionItem.correctChoice = choiceItem
			end
		end
		
		subjectQuestions[questionItem.id] = questionItem	
	end
	
	return subjectQuestions
end

module.initQuestions = function( allQuestions )

	local qid = 1
	
	for subject, questionItems in pairs( allQuestions ) do
		for qnum, questionItem in pairs( questionItems ) do
		
			local insertQuestionQuery = string.format( queries.insertQuestion, qid, subject, questionItem.question, questionItem.answer ) 
			local insertChoicesQuery = queries.insertChoicePrefix 
			local numChoices = # questionItem.choices
			
			for cnum, choice in pairs( questionItem.choices ) do
				local appendChoice
				
				if cnum == numChoices then
					appendChoice = string.format( queries.insertChoiceValue, qid, choice ) .. ";" 
				else
					appendChoice = string.format( queries.insertChoiceValue, qid, choice ) .. ", "
				end
				
				insertChoicesQuery = insertChoicesQuery .. appendChoice
			end
			
			db:exec( insertQuestionQuery )
			db:exec( insertChoicesQuery )
			qid = qid + 1
			print( insertQuestionQuery )
		end
	end
	
	return qid
end

module.getQuestionsCount = function()
	local query = queries.selectQuestionsCount
	local count = 0
	
	for row in db:nrows( query ) do
		count = row.count
	end
	
	return count
end

module.initBestScores = function( subjects, modes )
	local query = queries.insertBestScorePrefix
	local numScoreItems = # subjects * # modes
	local defaultScore = 0
	local scoreItemCount = 1
	
	for sidx, subject in pairs( subjects ) do
		for midx, mode in pairs( modes ) do
		
			if scoreItemCount == numScoreItems then
				query = query .. string.format( queries.insertBestScoreValue, subject, mode, defaultScore ) .. ";"
			else
				query = query .. string.format( queries.insertBestScoreValue, subject, mode, defaultScore ) .. ", "
			end
			
			scoreItemCount = scoreItemCount + 1
		end
	end
	
	userDb:exec( query )
	return scoreItemCount
end

module.getBestScores = function()
	local query = queries.selectAllBestScores
	local bestScores = {}
	
	for bestScore in userDb:nrows( query ) do
		
		if bestScores[bestScore.subject] == nil then
			bestScores[bestScore.subject] = {}
		end
		
		bestScores[bestScore.subject][bestScore.mode] = bestScore.percent_score
	end
	
	return bestScores
end

module.getBestScoreBySubjectMode = function( subject, mode )
	local query = string.format( queries.selectBestScoreBySubjectMode, subject, mode )
	local bestScore = 0
	
	for row in userDb:nrows( query ) do
		bestScore = tonumber( row.percent_score )
	end
	
	return bestScore
end

module.getBestScoresCount = function()
	local query = queries.selectBestScoresCount
	local count = 0
	
	for row in userDb:nrows( query ) do
		count = row.count
	end
	
	return count
end

module.editBestScore = function( subject, mode, newBestScore )
	local query = string.format( queries.updateBestScoreBySubject, newBestScore, subject, mode)
	userDb:exec( query )
	return true
end

--[[
	-----------------------
		Begin main proc
	-----------------------
--]]

-- Create DB schema	and populate database

--db:exec( [[DROP TABLE questions;]] )
--db:exec( [[DROP TABLE choices;]] )
--userDb:exec( [[DROP TABLE best_scores;]] )

--[[
db:exec( queries.createQuestionsTable )
db:exec( queries.createChoicesTable )
if module.getQuestionsCount() == 0 then
	module.initQuestions( allQuestions )
	print( "initialized questions" )
end
--]]

userDb:exec( queries.createBestScoresTable )
	
if module.getBestScoresCount() == 0 then
	module.initBestScores( allSubjects, allModes )
	print( "initialized best scores" )
end



Runtime:addEventListener( "system", onSystemEvent )

return module