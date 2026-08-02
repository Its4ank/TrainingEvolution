local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpdateConfig = require(ReplicatedStorage.Modules.UpdateConfig)

local updateEventFolder = ReplicatedStorage:WaitForChild("UpdateEvent")
local updateViewedEvent = updateEventFolder:WaitForChild("UpdateViewedEvent")

updateViewedEvent.OnServerEvent:Connect(function(player, viewedUpdate)
	if player:GetAttribute("DataReady") ~= true then
		return
	end
	
	if viewedUpdate ~= UpdateConfig.CurrentUpdate then
		warn("Player tried to mark invalid update as viewed:", player.Name, viewedUpdate)
		return
	end
	
	local playerData = player:FindFirstChild("PlayerData")
	if not playerData then
		return
	end
	
	local lastSeenUpdate = playerData:FindFirstChild("LastSeenUpdate")
	if not lastSeenUpdate or not lastSeenUpdate:IsA("StringValue") then
		return
	end
	
	if lastSeenUpdate.Value == viewedUpdate then
		return
	end
	
	lastSeenUpdate.Value = viewedUpdate
	
	print("UPDATE VIEWED:", player.Name, viewedUpdate)
end)
