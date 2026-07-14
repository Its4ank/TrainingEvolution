local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local XPModule = require(game.ServerScriptService.Modules.XPModule)

Players.PlayerAdded:Connect(function(player)
	XPModule.setupPlayer(player)
end)
