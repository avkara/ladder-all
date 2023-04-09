local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.knit)

Knit.AddControllers(ReplicatedStorage.Replicate.Controllers)

Knit.Start():catch(warn)
