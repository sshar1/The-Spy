local repStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")

local gameController = require(repStorage:WaitForChild("GameController"))

--[[ TODO
	- Player can't leave while voting; causes problems with finding frame
	- *While loop doesn't reset when game is reset*
]]--


-- Remote Events
local rmtEvents = repStorage:WaitForChild("RmtEvents")
local readyVote = rmtEvents:WaitForChild("ReadyVote")
local unreadyVote = rmtEvents:WaitForChild("UnreadyVote")
local playerJoined = rmtEvents:WaitForChild("PlayerJoined")
local playerLeft = rmtEvents:WaitForChild("PlayerLeft")
local showEnteredWord = rmtEvents:WaitForChild("ShowEnteredWord")
local changeTurn = rmtEvents:WaitForChild("ChangeTurn")
local turnEnded = rmtEvents:WaitForChild("TurnEnded")
local changeMainTimer = rmtEvents:WaitForChild("ChangeMainTimer")
local changeVoteTimer = rmtEvents:WaitForChild("ChangeVoteTimer")
local sendVote = rmtEvents:WaitForChild("SendVote")

local waitingForTurn = false
local allVoted = false
local turnOverrided = false
local numVoted = 0

local MAX_WAIT_TIME = 30

local inSession = repStorage:WaitForChild("gameStarted").Value
local spyID = serverStorage:WaitForChild("Spy").Value

local inGamePlrs = {}
local votedPlrs = {}
local numReady = 0

-- function doesn't work in module, fix
local function loopTurns()
	for _, player in ipairs(inGamePlrs) do
		
		if table.find(inGamePlrs, player) ~= nil then
			
			waitingForTurn = true
			turnOverrided = false
			changeTurn:FireAllClients(player)

			local count = 0
			repeat 
				if #inGamePlrs < 3 then
					return
				end
				
				changeMainTimer:FireClient(player, MAX_WAIT_TIME - count)
				task.wait(1)
				count += 1
			until not waitingForTurn or turnOverrided or count == MAX_WAIT_TIME

			waitingForTurn = false

			turnEnded:FireAllClients(player)
		end
		
		if #inGamePlrs < 3 then
			return
		end
	end
end

local function voteTimer()
	local count = 0
	repeat 
		if #inGamePlrs < 3 then
			return
		end
		
		changeVoteTimer:FireAllClients(MAX_WAIT_TIME - count)
		task.wait(1)
		count += 1
	until allVoted or count == MAX_WAIT_TIME
end

local function getIndexFromPlayer(tbl, target)
	for i, player in ipairs(tbl) do
		if target == player then
			return i
		end
	end
	return nil
end


game.Players.PlayerAdded:Connect(function(plr)
	playerJoined:FireAllClients(plr)
end)

game.Players.PlayerRemoving:Connect(function(plr) -- check if num voted is equal to in game player if player leaves while voting
	playerLeft:FireAllClients(plr)
	
	if getIndexFromPlayer(inGamePlrs, plr) ~= nil then
		table.remove(inGamePlrs, getIndexFromPlayer(inGamePlrs, plr))
	end
	
	if #inGamePlrs <= 2 and inSession then
		gameController.resetGame(true, "Spy has left. Restarting game...")
		inSession = false
		
	elseif plr == game.Players:GetPlayerByUserId(spyID) and inSession then
		gameController.resetGame(true, "Not enough players. Restarting game...")
		inSession = false
		
	elseif numVoted == #inGamePlrs then
		turnOverrided =  true
	end
end)

readyVote.OnServerEvent:Connect(function(plr)
	numReady += 1
	readyVote:FireAllClients(plr)
end)

unreadyVote.OnServerEvent:Connect(function(plr)
	numReady -= 1
	unreadyVote:FireAllClients(plr)
end)

showEnteredWord.OnServerEvent:Connect(function(plr, text)
	showEnteredWord:FireAllClients(plr, text)
	waitingForTurn = false
end)

sendVote.OnServerEvent:Connect(function(client, plrName)
	
	if votedPlrs[plrName] == nil then
		votedPlrs[plrName] = 1
	else
		votedPlrs[plrName] += 1
	end
	
	numVoted += 1
	if numVoted == #inGamePlrs then
		allVoted = true
	end
end)


--game loop
while true do

	numReady = 0
	numVoted = 0
	allVoted = false
	turnOverrided = false
	inSession = false
	inGamePlrs = {}
	votedPlrs = {}

	repeat task.wait() until #game.Players:GetPlayers() > 1 and numReady >= #game.Players:GetPlayers() / 2.0

	gameController.startGame(inGamePlrs)
	inSession = true

	loopTurns()

	gameController.voteScreen(inGamePlrs)

	voteTimer(inSession)

	gameController.revealSpy(votedPlrs, inGamePlrs)
	task.wait(20.48)
	gameController.resetGame(false, nil)
end
