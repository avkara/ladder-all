local Knit = require(game:GetService("ReplicatedStorage").Packages.knit)

local ServerScriptService = game:GetService("ServerScriptService")

Knit.AddServices(ServerScriptService.Server.Services)

Knit.Start():catch(warn)
