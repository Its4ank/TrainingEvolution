local function updateTopRanks()
	local rankedGroups = {}
	
	for _, player in pairs(game.Players:GetPlayers()) do
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local rebirth = leaderstats:FindFirstChild("Rebirth")
			local top = leaderstats:FindFirstChild("Top")
			
			if rebirth and top then
				local rebirthValue = rebirth.Value
				
				if not rankedGroups[rebirthValue] then
					rankedGroups[rebirthValue] = {}
				end
				
				table.insert(rankedGroups[rebirthValue], player)
			end
		end
	end
	
	local rebirthValues = {}
	
	for rebirthValue, _ in pairs(rankedGroups) do
		table.insert(rebirthValues, rebirthValue)
	end
	
	table.sort(rebirthValues, function(a, b)
		return a > b
	end)
	
	for _, player in ipairs(game.Players:GetPlayers()) do
		local leaderstats = player:FindFirstChild("leaderstats")
		local top = leaderstats and leaderstats:FindFirstChild("Top")
		if top then
			top.Value = "-"
		end
	end
	
	for place, rebirthValue in ipairs(rebirthValues) do 
		if place > 3 then
			break
		end
		
		for _, player in ipairs(rankedGroups[rebirthValue]) do
			local leaderstats = player:FindFirstChild("leaderstats")
			local top = leaderstats and leaderstats:FindFirstChild("Top")
			
			if top then
				top.Value = "#" .. place
			end
		end
	end
end

task.spawn(function()
	while true do
		task.wait(2)
		updateTopRanks()
	end
end)

print("TabServer loaded")
