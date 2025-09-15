-- PlantGrowthManager.lua
-- Handles plant growth timers and stage progression

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Wait for GameManager to load
repeat wait() until _G.GameManager

local GameManager = _G.GameManager
local remotes = GameManager.remotes

-- Growth stage configuration
local GrowthStages = {
    "seed",
    "sprout", 
    "mature"
}

-- Growth stage visual models (you'll need to create these in Roblox Studio)
local StageModels = {
    seed = "rbxasset://models/seed_stage",
    sprout = "rbxasset://models/sprout_stage", 
    mature = "rbxasset://models/mature_stage"
}

-- Plant growth tracking
local plantGrowthData = {}

-- Start growth timer for a plant
local function startGrowthTimer(player, x, y, plantType)
    local plotKey = x .. "," .. y
    local playerKey = player.UserId .. "_" .. plotKey
    
    local growthTime = GameManager.getGrowthTime(plantType)
    local data = GameManager.getPlayerData(player)
    local plot = data.garden.plots[plotKey]
    
    if not plot then return end
    
    -- Calculate time remaining
    local timeSincePlanted = os.time() - plot.plantedTime
    local timeRemaining = growthTime - timeSincePlanted
    
    -- Apply watering bonus
    if plot.watered then
        timeRemaining = timeRemaining * (1 - GameManager.GameConfig.WateringBonus)
    end
    
    if timeRemaining <= 0 then
        -- Plant is already mature
        plot.growthStage = "mature"
        GameManager.savePlayerData(player)
        remotes.GetGardenData:FireClient(player, data.garden)
        return
    end
    
    -- Store growth data
    plantGrowthData[playerKey] = {
        player = player,
        x = x,
        y = y,
        plantType = plantType,
        startTime = os.time(),
        growthTime = growthTime,
        watered = plot.watered,
        currentStage = 0
    }
    
    -- Start the growth process
    spawn(function()
        local stages = #GrowthStages
        local stageTime = growthTime / stages
        
        for stage = 1, stages do
            wait(stageTime)
            
            if not plantGrowthData[playerKey] then
                break -- Plant was harvested or removed
            end
            
            local currentData = GameManager.getPlayerData(player)
            local currentPlot = currentData.garden.plots[plotKey]
            
            if not currentPlot or currentPlot.plantType ~= plantType then
                break -- Plot was changed
            end
            
            -- Update growth stage
            currentPlot.growthStage = GrowthStages[stage]
            currentData.garden.plots[plotKey] = currentPlot
            
            -- Update visual representation
            remotes.GetGardenData:FireClient(player, currentData.garden)
            
            -- Save progress
            GameManager.savePlayerData(player)
            
            -- If mature, stop growing
            if stage == stages then
                plantGrowthData[playerKey] = nil
                break
            end
        end
    end)
end

-- Stop growth timer for a plant
local function stopGrowthTimer(player, x, y)
    local plotKey = x .. "," .. y
    local playerKey = player.UserId .. "_" .. plotKey
    plantGrowthData[playerKey] = nil
end

-- Update all active growth timers
local function updateGrowthTimers()
    for playerKey, growthData in pairs(plantGrowthData) do
        local player = growthData.player
        local data = GameManager.getPlayerData(player)
        local plotKey = growthData.x .. "," .. growthData.y
        local plot = data.garden.plots[plotKey]
        
        -- Check if plant still exists and hasn't been harvested
        if not plot or plot.plantType ~= growthData.plantType or plot.growthStage == "mature" then
            plantGrowthData[playerKey] = nil
        end
    end
end

-- Handle plant harvesting
remotes.HarvestPlant.OnServerEvent:Connect(function(player, x, y)
    stopGrowthTimer(player, x, y)
end)

-- Handle plant removal
remotes.PlantSeed.OnServerEvent:Connect(function(player, x, y, seedType)
    stopGrowthTimer(player, x, y)
    
    -- Start new growth timer
    wait(0.1) -- Small delay to ensure plot is updated
    startGrowthTimer(player, x, y, seedType)
end)

-- Handle watering
remotes.WaterPlant.OnServerEvent:Connect(function(player, x, y)
    local plotKey = x .. "," .. y
    local playerKey = player.UserId .. "_" .. plotKey
    
    if plantGrowthData[playerKey] then
        -- Apply watering bonus to active growth
        plantGrowthData[playerKey].watered = true
        plantGrowthData[playerKey].growthTime = plantGrowthData[playerKey].growthTime * (1 - GameManager.GameConfig.WateringBonus)
    end
end)

-- Update growth timers every second
RunService.Heartbeat:Connect(function()
    updateGrowthTimers()
end)

-- Initialize growth timers for existing plants when player joins
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(3) -- Wait for data to load
        
        local data = GameManager.getPlayerData(player)
        for pos, plotData in pairs(data.garden.plots) do
            if plotData.plantType and plotData.plantType ~= "" and plotData.growthStage ~= "mature" then
                local x, y = pos:match("(%d+),(%d+)")
                startGrowthTimer(player, tonumber(x), tonumber(y), plotData.plantType)
            end
        end
    end)
end)

-- Clean up when player leaves
Players.PlayerRemoving:Connect(function(player)
    for playerKey, growthData in pairs(plantGrowthData) do
        if growthData.player == player then
            plantGrowthData[playerKey] = nil
        end
    end
end)

print("PlantGrowthManager loaded successfully!")