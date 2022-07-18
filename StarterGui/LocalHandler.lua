local tweenService = game:GetService("TweenService")
local repStorage = game:GetService("ReplicatedStorage")

local localPlayer = game.Players.LocalPlayer

-- Menu ui
local menu = script.Parent:WaitForChild("Menu")
local title = menu.Title
local readyBack = menu:WaitForChild("ReadyBack")
local readyButton = readyBack:WaitForChild("ReadyButton")
local instructionsBack = menu:WaitForChild("InstructionsBack")
local instructionsButton = instructionsBack:WaitForChild("InstructionsButton")
local instructionsMenu = menu:WaitForChild("Instructions")
local exitInstructionsButton = instructionsMenu:WaitForChild("Leave")

local playerListMenu = menu.PlayerFrame

local playerCardMenu = menu:WaitForChild("PlayerCard")
local playerImg = playerCardMenu:WaitForChild("PlayerImg")
local playerName = playerCardMenu:WaitForChild("PlayerName")

-- Role ui
local roles = script.Parent:WaitForChild("Roles")
local detectiveFrame = roles.DetectiveFrame
local spyFrame = roles.SpyFrame

-- Main ui
local main = script.Parent:WaitForChild("Main")
local playerListMain = main:WaitForChild("PlayerList")
local localPlayerCardMain = main:WaitForChild("LocalPlayerCard")
local playerCardMain = main:WaitForChild("PlayerCard")
local mainDirections = main:WaitForChild("Directions")
local wordLabel = main.Word

local wordFrame = main.WordFrame
local topicLabel = wordFrame.Topic
local wordBox = wordFrame.Words

-- Vote ui
local vote = script.Parent:WaitForChild("Vote")
local voteButton = vote:WaitForChild("VoteBack")
local voteList = vote.VoteList
local voteDirectionFrame = vote.Directions
local voteDirections = voteDirectionFrame.TextLabel
local playerListVote

-- Results ui
local results = script.Parent:WaitForChild("Results")

local votedContainer = results:WaitForChild("VotedContainer")
local votedFrameResults = votedContainer.VotedPlayer

local spyContainer = results:WaitForChild("SpyContainer")
local spyFrameResults = spyContainer.SpyPlayer

-- Waitscreen
local waitScreen = script.Parent:WaitForChild("WaitScreen")
local waitScreenText = waitScreen.TextLabel

-- End game ui
local endGame = script.Parent:WaitForChild("EndGameFrame")
local endGameText = endGame:WaitForChild("TextLabel")

-- Audio
local musicFolder = workspace:WaitForChild("Audio")
local menuMusic = musicFolder:WaitForChild("LobbyMusic")
local roleChosen = musicFolder:WaitForChild("RoleChosen")
local mainMusic = musicFolder:WaitForChild("MainMusic")
local turnChanged = musicFolder:WaitForChild("ChangeTurn")
local voteMusic = musicFolder:WaitForChild("VoteMusic")
local drumRoll = musicFolder:WaitForChild("Drumroll")
local spyAnnounced = musicFolder:WaitForChild("SpyAnnounced")
local errorSound = musicFolder:WaitForChild("Error")

-- Remote events
local rmtEvents = repStorage:WaitForChild("RmtEvents")
local playerJoined = rmtEvents.PlayerJoined
local playerLeft = rmtEvents.PlayerLeft
local readyVote = rmtEvents.ReadyVote
local unreadyVote = rmtEvents.UnreadyVote 
local startGame = rmtEvents.StartGame
local revealRoles = rmtEvents.RevealRoles
local showWords = rmtEvents.ShowWords
local changeTurn = rmtEvents.ChangeTurn
local showEnteredWord = rmtEvents.ShowEnteredWord
local turnEnded = rmtEvents.TurnEnded
local showVoteScreen = rmtEvents.ShowVoteScreen
local sendVote = rmtEvents.SendVote
local revealSpy = rmtEvents.RevealSpy
local resetGame = rmtEvents.ResetGame
local changeMainTimer = rmtEvents.ChangeMainTimer
local changeVoteTimer = rmtEvents.ChangeVoteTimer

local ready = false
local voted = false
local instructionsOpen = false
local inSession = repStorage.gameStarted.Value

local downTween = tweenService:Create(readyButton, TweenInfo.new(0.2), {Position = UDim2.new(0.5, 0, 0.5, 0)})
local upTween = tweenService:Create(readyButton, TweenInfo.new(0.2), {Position = UDim2.new(0.5, 0, 0.38, 0)})

local downTweenInstructions = tweenService:Create(instructionsButton, TweenInfo.new(0.2), {Position = UDim2.new(0.5, 0, 0.5, 0)})
local upTweenInstructions = tweenService:Create(instructionsButton, TweenInfo.new(0.2), {Position = UDim2.new(0.5, 0, 0.42, 0)})

local showInstructions = tweenService:Create(instructionsMenu, TweenInfo.new(0.5), {Position = UDim2.new(0.5, 0, 0.5, 0)})
local hideInstructions = tweenService:Create(instructionsMenu, TweenInfo.new(0.5), {Position = UDim2.new(0.5, 0, 1.5, 0)})

local currentFrame

print("get out of the console, nerd. This is none of your business")

local function removeWhitespace(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function blinkText()
	errorSound:Play()
	for i = 1, 3 do
		mainDirections.TextColor3 = Color3.fromRGB(217, 0, 0)
		task.wait(0.2)
		mainDirections.TextColor3 = Color3.fromRGB(0, 0, 0)
		task.wait(0.2)
	end
end

local function uniqueWord(word, list)
	for _, frame in ipairs(list:GetChildren()) do
		
		if frame.Name == localPlayer.Name or not frame:IsA("Frame") then
			continue
		end
		
		local text = frame.EnteredWord.WordEntered.Text
		if word == text then
			return false
		end
	end
	return true
end

local function validWord(word) 
	word = removeWhitespace(word)
	
	return string.find(word, " ") == nil and string.len(word) < 12 and uniqueWord(word, playerListMain) 
end

local function cloneCard(card, player, parent) 
	local content, isReady = game.Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

	local plrCard = card:Clone()
	plrCard.Name = player.Name
	plrCard.PlayerImg.Image = content
	plrCard.PlayerName.Text = player.DisplayName
	plrCard.Parent = parent
end

local function cloneMainCard(card, player, parent)
	local content, isReady = game.Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

	local plrCard = card:Clone()
	plrCard.Name = player.Name
	plrCard.NameCard.PlayerImg.Image = content
	plrCard.NameCard.PlayerName.Text = player.DisplayName
	plrCard.Parent = parent
	
	local textBox = plrCard.EnteredWord:FindFirstChild("TextBox")
	
	if textBox then -- if local text box
		textBox.FocusLost:Connect(function(enterPressed)
			if enterPressed and textBox.Text ~= nil and textBox.Text ~= "" then
				if validWord(textBox.Text) then
					showEnteredWord:FireServer(textBox.Text)
				else
					blinkText()
					textBox.Text = ""
				end
			end
		end)
	end
end

local function makeVoteGray(list)
	for _, card in ipairs(list:GetDescendants()) do

		if card:IsA("Frame") then
			card.BackgroundColor3 = Color3.fromRGB(61, 61, 61)

		elseif card:IsA("TextButton") then
			card.BackgroundColor3 = Color3.fromRGB(129, 129, 129)
		end
	end
end

local function cloneVoteCard(card, player, parent)
	
	local voteCard = card:Clone()
	voteCard.Name = player.Name
	voteCard.VoteButton.Text = "Vote "..player.DisplayName
	voteCard.Parent = parent
	
	local voteButton = voteCard.VoteButton
	local buttonPos = voteButton.Position
	local downPos = voteCard.Position
	
	if player == localPlayer then
		voteCard.BackgroundColor3 = Color3.fromRGB(61, 61, 61)
		voteButton.BackgroundColor3 = Color3.fromRGB(129, 129, 129)
	else
		voteButton.MouseButton1Up:Connect(function()
			if not voted then
				--tweenService:Create(voteButton, TweenInfo.new(0.2), {Position = buttonPos}):Play()
				makeVoteGray(parent)
				voted = true
				sendVote:FireServer(player.Name)
			end
		end)

		voteButton.MouseButton1Down:Connect(function()
			if not voted then
				--tweenService:Create(voteButton, TweenInfo.new(0.2), {Position = downPos}):Play()
			end
		end)
	end
end

local function makeRed()
	readyBack.BackgroundColor3 = Color3.fromRGB(116, 0, 0)
	readyButton.BackgroundColor3 = Color3.fromRGB(207, 0, 0)
	readyButton.Text = "Unready!"
end

local function makeGreen()
	readyBack.BackgroundColor3 = Color3.fromRGB(47, 134, 7)
	readyButton.BackgroundColor3 = Color3.fromRGB(80, 221, 9)
	readyButton.Text = "Ready!"
end

local function makeGray()
	readyBack.BackgroundColor3 = Color3.fromRGB(61, 61, 61)
	readyButton.BackgroundColor3 = Color3.fromRGB(129, 129, 129)
	
	if ready then
		readyButton.Text = "Unready!"
	else
		readyButton.Text = "Ready!"
	end
end

local function stopSounds()
	for _, sound in ipairs(musicFolder:GetChildren()) do
		if sound.Playing then
			tweenService:Create(sound, TweenInfo.new(0.6, Enum.EasingStyle.Linear), {Volume = 0.5}):Play()
			task.wait(0.6)
			sound:Stop()
			sound.Volume = 0.5
		end
	end
end

local function switchSlide(exitFrame, enterFrame, sound)
	stopSounds()
	
	enterFrame.Position = UDim2.new(1.5, 0, 0.5, 0)
	tweenService:Create(exitFrame, TweenInfo.new(1, Enum.EasingStyle.Bounce), {Position = UDim2.new(-0.5, 0, 0.5, 0)}):Play()
	task.wait(0.6)
	tweenService:Create(enterFrame, TweenInfo.new(1, Enum.EasingStyle.Bounce), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
	
	if sound ~= nil then
		sound:Play()
	end
	
	currentFrame = enterFrame
end

local function loadPlayerList(card, tbl, parent)
	for _, player in ipairs(tbl) do
		cloneCard(card, player, parent)
	end
end

local function loadMainPlayerList(card, localCard, tbl, parent)
	for _, player in ipairs(tbl) do
		
		if player == localPlayer then
			cloneMainCard(localCard, player, parent)
		else
			cloneMainCard(card, player, parent)
		end
	end
end

local function loadVoteList(card, tbl, parent)
	for _, player in ipairs(tbl) do
		cloneVoteCard(card, player, parent)
	end
end

local function loadWordList(frame, wordList)
	local count = 1
	for _, element in pairs(frame:GetDescendants()) do
		if element:IsA("TextLabel") then
			element.Text = wordList[count] 
			count += 1
		end
	end
end

local function loadResultFrame(frame, player, votes)
	local content, isReady = game.Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
	
	frame.PlayerImg.Image = content
	frame.PlayerName.Text = player.Name
	
	if votes ~= nil then
		frame.NumVotes.Text = votes.." votes"
	else
		frame.NumVotes.Text = "0 votes"
	end
end

local function clearList(tbl)
	for _, frame in pairs(tbl) do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
end

local function delPlayerFromList(list, target)
	for _, frame in ipairs(list) do
		if frame:IsA("Frame") and frame.Name == target.Name then
			frame:Destroy()
		end
	end
end

instructionsButton.MouseButton1Down:Connect(function()
	downTweenInstructions:Play()
end)

instructionsButton.MouseButton1Up:Connect(function()
	upTweenInstructions:Play()
	
	if instructionsOpen then
		hideInstructions:Play()
	else
		showInstructions:Play()
	end

	instructionsOpen = not instructionsOpen
end)

exitInstructionsButton.MouseButton1Up:Connect(function()
	hideInstructions:Play()
	instructionsOpen = false
end)

playerJoined.OnClientEvent:Connect(function(player)
	if #game.Players:GetPlayers() <= 2 then
		makeGray()
	elseif ready then
		makeRed()
	else
		makeGreen()
	end
	
	if player ~= localPlayer then
		cloneCard(playerCardMenu, player, playerListMenu)
	end
end)

playerLeft.OnClientEvent:Connect(function(player)
	if #game.Players:GetPlayers() <= 2 then
		readyBack.BackgroundColor3 = Color3.fromRGB(61, 61, 61)
		readyButton.BackgroundColor3 = Color3.fromRGB(129, 129, 129)
	elseif ready then
		makeRed()
	else
		makeGreen()
	end
	
	delPlayerFromList(playerListMenu:GetChildren(), player)
	delPlayerFromList(playerListMain:GetChildren(), player)
	delPlayerFromList(voteList:GetChildren(), player)
	
	if playerListVote ~= nil then
		delPlayerFromList(playerListVote:GetChildren(), player)
	end
end)

readyButton.MouseButton1Down:Connect(function()
	if #game.Players:GetPlayers() > 2 then
		downTween:Play()
	end
end)

readyButton.MouseButton1Up:Connect(function()
	if #game.Players:GetPlayers() > 2 then
		upTween:Play()

		ready = not ready

		if ready then
			readyVote:FireServer()
			makeRed()
		else
			unreadyVote:FireServer()
			makeGreen()
		end	
	end
end)

readyVote.OnClientEvent:Connect(function(plr)
	playerListMenu[plr.Name].ReadyFrame.BackgroundColor3 = Color3.fromRGB(80, 221, 9) -- Make green
end)

unreadyVote.OnClientEvent:Connect(function(plr)
	playerListMenu[plr.Name].ReadyFrame.BackgroundColor3 = Color3.fromRGB(207, 0, 0) -- Make red
end)

revealRoles.OnClientEvent:Connect(function(spy)
	
	if spy == localPlayer then
		-- Show spy, hide detective
		spyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		detectiveFrame.Position = UDim2.new(0.5, 0, -0.5, 0)
	else
		-- Show detective, hide spy
		detectiveFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		spyFrame.Position = UDim2.new(0.5, 0, -0.5, 0) 
	end
	
	hideInstructions:Play()
	instructionsOpen = false
	switchSlide(menu, roles, roleChosen)
end)

showWords.OnClientEvent:Connect(function(topic, word, wordList, spy)
	
	if spy ~= localPlayer then
		wordLabel.Text = "The word is "..word
	else
		wordLabel.Text = "Try to guess the word!"
	end
	
	topicLabel.Text = topic
	loadWordList(wordBox, wordList)
end)

startGame.OnClientEvent:Connect(function(spy, inGamePlrs)
	
	loadMainPlayerList(playerCardMain, localPlayerCardMain, inGamePlrs, playerListMain)
	
	switchSlide(roles, main, mainMusic)
end)

changeTurn.OnClientEvent:Connect(function(plr)
	-- Make card gray
	playerListMain[plr.Name].EnteredWord.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	playerListMain[plr.Name].NameCard.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	playerListMain[plr.Name].NameCard.PlayerImg.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	
	if plr == localPlayer then
		playerListMain[localPlayer.Name].EnteredWord.TextBox.TextEditable = true
	else
		mainDirections.Text = "Enter ONE associated unique word when it's your turn"
	end
	
	turnChanged:Play()
end)

showEnteredWord.OnClientEvent:Connect(function(plr, text)
	if plr ~= localPlayer then
		playerListMain[plr.Name].EnteredWord.WordEntered.Text = text
	end
end)

turnEnded.OnClientEvent:Connect(function(plr)
	-- Turn to original color
	playerListMain[plr.Name].EnteredWord.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	playerListMain[plr.Name].NameCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	playerListMain[plr.Name].NameCard.PlayerImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	
	playerListMain[localPlayer.Name].EnteredWord.TextBox.TextEditable = false
end)

showVoteScreen.OnClientEvent:Connect(function(inGamePlrs)
	
	playerListVote = playerListMain:Clone()
	playerListVote.Parent = vote
	
	voted = false
	
	loadVoteList(voteButton, inGamePlrs, voteList)
	
	switchSlide(main, vote, voteMusic)
end)

revealSpy.OnClientEvent:Connect(function(votedPlrs, mostVoted, spy)
	
	loadResultFrame(votedFrameResults, mostVoted, votedPlrs[mostVoted.Name])
	loadResultFrame(spyFrameResults, spy, votedPlrs[spy.Name])
	
	switchSlide(vote, results)
	task.wait(3)
	
	-- Tween most voted
	tweenService:Create(votedContainer, TweenInfo.new(0.5), {Position = UDim2.new(0.13, 0, 0.5, 0)}):Play()
	
	task.wait(0.5)
	drumRoll:Play()
	task.wait(drumRoll.TimeLength)
	spyAnnounced:Play()
	
	--Tween spy
	tweenService:Create(spyContainer, TweenInfo.new(0.5), {Position = UDim2.new(0.87, 0, 0.5, 0)}):Play()
end)

changeMainTimer.OnClientEvent:Connect(function(count)
	mainDirections.Text = "Enter ONE associated unique word when it's your turn. You have "..tostring(count).." seconds."
end)

changeVoteTimer.OnClientEvent:Connect(function(count)
	voteDirections.Text = "Vote for who you think the spy is! You have "..tostring(count).." seconds."
end)

resetGame.OnClientEvent:Connect(function(gameInterrupted, text)
	
	-- Reload menu
	ready = false
	voted = false
	
	if gameInterrupted then
		endGameText.Text = text
		switchSlide(currentFrame, endGame)
		task.wait(3)
	end
	
	if #game.Players:GetPlayers() > 2 then
		makeGreen()
	else
		makeGray()
	end
	
	clearList(playerListMenu:GetChildren())
	loadPlayerList(playerCardMenu, game.Players:GetPlayers(), playerListMenu)
	
	if currentFrame ~= nil then
		switchSlide(currentFrame, menu, menuMusic)
	end
	
	-- Reload main
	clearList(playerListMain:GetChildren())
	
	-- Reload vote
	clearList(voteList:GetChildren())
	
	if vote:FindFirstChild("PlayerList") then
		vote.PlayerList:Destroy()
	end
	
	-- Reload results
	votedContainer.Position = UDim2.new(0.13, 0, -0.4, 0)
	spyContainer.Position = UDim2.new(0.87, 0, -0.4, 0)
	
	if script.Parent:FindFirstChild("WaitScreen") then
		task.wait(0.6) 
		waitScreen:Destroy()
	end
end)


if not inSession then
	waitScreen:Destroy()
	loadPlayerList(playerCardMenu, game.Players:GetPlayers(), playerListMenu)
	menuMusic:Play()
	menu.Position = UDim2.new(0.5, 0, 0.5, 0)
else
	currentFrame = waitScreen
end

while task.wait(1.5) do
	title.Rotation = math.random(-10, 10)
	waitScreenText.Rotation = math.random(-10, 10)
end
