game.Players.LocalPlayer.CharacterAdded:Wait()
game.Players.LocalPlayer.Character:WaitForChild("Humanoid")

local controls = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
controls:Disable()

local UserInputService = game:GetService("UserInputService")
UserInputService.ModalEnabled = true
