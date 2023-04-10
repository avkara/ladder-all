local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)

local LadderService = Knit.CreateService({
	Name = "LadderService",
	Client = {
		LadderSignal = Knit.CreateSignal(),
	},
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ladders = {}

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

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

function LadderService.Client:SpawnLadder(player)
	if not ladders[player] then
		return
	end
	if ladders[player].ladderSpawned and (os.clock() - ladders[player].cd) > 1 then
		ladders[player].ladder:Destroy()
		ladders[player].ladderSpawned = false
		ladders[player].cd = os.clock()
		LadderService.Client.LadderSignal:Fire(player)
		return
	end
	if not ladders[player].ladderSpawned then
		local character = player.Character or player.CharacterAdded:Wait()
		local primaryPart = character.PrimaryPart
		ladders[player].ladder:Destroy()
		ladders[player] = {
			ladder = ReplicatedStorage.Ladder:Clone(),
			ladderSpawned = true,
		}
		if primaryPart then
			local rayCastResult = workspace:Raycast(primaryPart.Position, primaryPart.CFrame.LookVector * 6, rayParams)
			if rayCastResult then
				ladders[player].ladder:PivotTo(
					CFrame.lookAt(rayCastResult.Position, rayCastResult.Position + rayCastResult.Normal)
				)
				ladders[player].ladder:PivotTo(
					(ladders[player].ladder:GetPivot() + ladders[player].ladder:GetPivot().LookVector * 0.5)
						* CFrame.new(0, 1, 0)
				)
			else
				ladders[player].ladder:PivotTo(primaryPart.CFrame * CFrame.new(0, 1, -5))
			end
			ladders[player].ladder.Parent = workspace
			ladders[player].cd = os.clock()
			LadderService.Client.LadderSignal:Fire(player)
		end
	end
end

function LadderService:KnitStart() end

function LadderService:KnitInit()
	Players.PlayerAdded:Connect(function(player)
		ladders[player] = {
			ladder = ReplicatedStorage.Ladder:Clone(),
			ladderSpawned = false,
			cd = os.clock(),
		}
		ladders[player].ladder.Name = "Ladder" .. player.Name

		addToFilter(player.Character or player.CharacterAdded:Wait())
		player.CharacterAdded:Connect(addToFilter)
		player.CharacterRemoving:Connect(removeFromFilter)
	end)

	Players.PlayerRemoving:Connect(function(player)
		if ladders[player].ladderSpawned then
			ladders[player].ladder:Destroy()
		end
		ladders[player] = nil
	end)

	for _, player in Players:GetPlayers() do
		ladders[player] = {
			ladder = ReplicatedStorage.Ladder:Clone(),
			ladderSpawned = false,
			cd = os.clock(),
		}
		ladders[player].ladder.Name = "Ladder" .. player.Name
		player.CharacterAdded:Connect(addToFilter)
		player.CharacterRemoving:Connect(removeFromFilter)
		if player.Character then
			addToFilter(player.Character)
		end
	end
end

return LadderService
