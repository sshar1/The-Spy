local GameController = {}

local repStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")
local players = game:GetService("Players")

local wordDict = require(repStorage:WaitForChild("WordDict"))

-- Remote Events
local rmtEvents = repStorage:WaitForChild("RmtEvents")
local startGame = rmtEvents:WaitForChild("StartGame")
local revealRoles = rmtEvents:WaitForChild("RevealRoles")
local showWords = rmtEvents:WaitForChild("ShowWords")
local changeTurn = rmtEvents:WaitForChild("ChangeTurn")
local showVoteScreen = rmtEvents:WaitForChild("ShowVoteScreen")
local revealSpy = rmtEvents:WaitForChild("RevealSpy")
local resetGame = rmtEvents:WaitForChild("ResetGame")

local spyValue = serverStorage:WaitForChild("Spy").Value
local spy

local inSession = repStorage.gameStarted.Value
local waitingForTurn = repStorage.WaitingForTurn.Value

local MAX_WAIT_TIME = 30
local ROLE_WAIT_TIME = 5

local function randSpy(tbl)
	return tbl[math.random(1, #tbl)].UserId -- Return random element
end

local function getMostVoted(tbl)
	local highest = 0
	local mostVoted
	
	for player, votes in pairs(tbl) do
		if votes > highest then
			mostVoted = player
			highest = votes
		end
	end
	return mostVoted
end

local function getPlayerFromName(playerName)
	for _, player in ipairs(game.Players:GetPlayers()) do
		if player.Name == playerName then
			return player
		end
	end
end

function GameController.startGame(inGamePlrs)

	-- Put players in table
	for _, player in pairs(game.Players:GetPlayers()) do
		table.insert(inGamePlrs, player)
	end
	
	-- Get spy
	spyValue = randSpy(inGamePlrs)
	spy = players:GetPlayerByUserId(spyValue)
	
	-- Shift ui and reveal roles
	revealRoles:FireAllClients(spy)
	task.wait(ROLE_WAIT_TIME) 
	
	-- Set up words
	local topic, word, wordList = wordDict.getRandWord()
	showWords:FireAllClients(topic, word, wordList, spy)
	
	-- Start game
	startGame:FireAllClients(spy, inGamePlrs)
	inSession = true
end

--[[
function GameController.loopTurns(tbl)
	for _, player in ipairs(tbl) do

		waitingForTurn = true
		changeTurn:FireAllClients(player)

		local count = 0
		repeat 
			task.wait(1)
			count += 1
		until not waitingForTurn or count == MAX_WAIT_TIME -- Give 30 secs
	end
end ]]--

function GameController.voteScreen(inGamePlrs)
	if #inGamePlrs < 3 then
		return
	end
	
	showVoteScreen:FireAllClients(inGamePlrs)
end

function GameController.revealSpy(votedPlrs, inGamePlrs)
	if #inGamePlrs < 3 then
		return
	end
	
	revealSpy:FireAllClients(votedPlrs, getPlayerFromName(getMostVoted(votedPlrs)), spy)
end

function GameController.resetGame(gameInterrupted, text)
	spyValue = 0
	inSession = false
	resetGame:FireAllClients(gameInterrupted, text)
end

return GameController
