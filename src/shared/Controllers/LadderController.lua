local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)

local LadderController = Knit.CreateController({ Name = "LadderController" })

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")

local LadderService

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local ladder = ReplicatedStorage:WaitForChild("LadderGhost"):Clone()
local ladderState = false
rayParams.FilterDescendantsInstances = { ladder }

function LadderController:KnitStart()
	LadderService.LadderSignal:Connect(function()
		ladderState = not ladderState
	end)

	local function SpawnLadder(_, inputState, _)
		if inputState == Enum.UserInputState.Begin then
			LadderService:SpawnLadder()
		end
	end

	RunService.Heartbeat:Connect(function()
		if ladderState then
			if ladder.Parent then
				ladder.Parent = nil
			end
			return
		end

		local character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
		local primaryPart = character.PrimaryPart

		if primaryPart then
			local rayCastResult = workspace:Raycast(primaryPart.Position, primaryPart.CFrame.LookVector * 6, rayParams)
			if rayCastResult then
				ladder:PivotTo(CFrame.lookAt(rayCastResult.Position, rayCastResult.Position + rayCastResult.Normal))
				ladder:PivotTo((ladder:GetPivot() + ladder:GetPivot().LookVector * 0.5) * CFrame.new(0, 1, 0))
			else
				ladder:PivotTo(primaryPart.CFrame * CFrame.new(0, 1, -5))
			end
			ladder.Parent = workspace
		end
	end)

	ContextActionService:BindAction("SpawnLadder", SpawnLadder, false, Enum.KeyCode.R)
end

function LadderController:KnitInit()
	LadderService = Knit.GetService("LadderService")
	Players.LocalPlayer.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid").JumpHeight = 0
		character.Humanoid.AutoJumpEnabled = false
	end)

	if Players.LocalPlayer.Character then
		local character = Players.LocalPlayer.Character
		if character then
			character:WaitForChild("Humanoid").JumpHeight = 0
			character.Humanoid.AutoJumpEnabled = false
		end
	end

	local function addToFilter(obj)
		local tempParam = rayParams.FilterDescendantsInstances
		table.insert(tempParam, obj)
		rayParams.FilterDescendantsInstances = tempParam
	end

	local function removeFromFilter(obj)
		local tempParam = rayParams.FilterDescendantsInstances
		for i, instance in tempParam do
			if instance == obj then
				table.remove(tempParam, i)
			end
		end
		rayParams.FilterDescendantsInstances = tempParam
	end

	local function hookCharacterEvents(player: Player)
		addToFilter(player.Character or player.CharacterAdded:Wait())

		player.CharacterAdded:Connect(addToFilter)
		player.CharacterRemoving:Connect(removeFromFilter)
	end

	Players.PlayerAdded:Connect(hookCharacterEvents)

	for _, player in Players:GetPlayers() do
		hookCharacterEvents(player)
	end
end

return LadderController
