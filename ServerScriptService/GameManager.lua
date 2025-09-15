-- GameManager.lua
-- Main server script that manages the overall game state and coordinates all systems

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Load configuration and data manager
local GameConfig = require(script.Parent.GameConfig)
local DataStoreManager = require(script.Parent.DataStoreManager)

-- Create RemoteEvents for client-server communication
local remoteEvents = Instance.new("Folder")
remoteEvents.Name = "RemoteEvents"
remoteEvents.Parent = ReplicatedStorage

local function createRemoteEvent(name)
    local remoteEvent = Instance.new("RemoteEvent")
    remoteEvent.Name = name
    remoteEvent.Parent = remoteEvents
    return remoteEvent
end

-- Create all necessary RemoteEvents
local remotes = {
    PlantSeed = createRemoteEvent("PlantSeed"),
    HarvestPlant = createRemoteEvent("HarvestPlant"),
    WaterPlant = createRemoteEvent("WaterPlant"),
    BuyItem = createRemoteEvent("BuyItem"),
    GetShopData = createRemoteEvent("GetShopData"),
    GetInventory = createRemoteEvent("GetInventory"),
    GetQuestData = createRemoteEvent("GetQuestData"),
    CompleteQuest = createRemoteEvent("CompleteQuest"),
    ClaimDailyReward = createRemoteEvent("ClaimDailyReward"),
    VisitGarden = createRemoteEvent("VisitGarden"),
    WaterFriendPlant = createRemoteEvent("WaterFriendPlant"),
    GetGardenData = createRemoteEvent("GetGardenData"),
    SaveGardenLayout = createRemoteEvent("SaveGardenLayout"),
    AddFriend = createRemoteEvent("AddFriend"),
    RemoveFriend = createRemoteEvent("RemoveFriend"),
    GetFriendList = createRemoteEvent("GetFriendList")
}

-- Get player data (using DataStoreManager)
local function getPlayerData(player)
    return DataStoreManager.getPlayerData(player)
end

-- Save player data (using DataStoreManager)
local function savePlayerData(player)
    return DataStoreManager.savePlayerData(player)
end

-- Growth time configuration
function getGrowthTime(plantType)
    local plantData = GameConfig.Plants[plantType]
    return plantData and plantData.growthTime or 300
end

-- Plant value configuration
function getPlantValue(plantType)
    local plantData = GameConfig.Plants[plantType]
    return plantData and plantData.value or 10
end

-- Player joining
Players.PlayerAdded:Connect(function(player)
    -- Data is loaded automatically by DataStoreManager
    
    -- Wait for character to spawn
    player.CharacterAdded:Connect(function(character)
        wait(2) -- Give time for client to load
        
        -- Send initial data to client
        local data = getPlayerData(player)
        remotes.GetGardenData:FireClient(player, data.garden)
        
        -- Start growth timers for existing plants
        for pos, plotData in pairs(data.garden.plots) do
            if plotData.plantType and plotData.plantType ~= "" then
                -- Calculate growth progress and update if needed
                local growthTime = getGrowthTime(plotData.plantType)
                local timeSincePlanted = os.time() - plotData.plantedTime
                local growthProgress = timeSincePlanted / growthTime
                
                if growthProgress >= 1 then
                    -- Plant is ready to harvest
                    plotData.growthStage = "mature"
                elseif growthProgress >= 0.5 then
                    plotData.growthStage = "sprout"
                else
                    plotData.growthStage = "seed"
                end
            end
        end
    end)
end)

-- Handle RemoteEvents
remotes.PlantSeed.OnServerEvent:Connect(function(player, x, y, seedType)
    local data = getPlayerData(player)
    
    -- Check if player has the seed
    if not data.inventory.seeds[seedType] or data.inventory.seeds[seedType] <= 0 then
        return
    end
    
    -- Check if plot is empty
    local plotKey = x .. "," .. y
    if data.garden.plots[plotKey] and data.garden.plots[plotKey].plantType ~= "" then
        return
    end
    
    -- Plant the seed
    data.inventory.seeds[seedType] = data.inventory.seeds[seedType] - 1
    data.garden.plots[plotKey] = {
        plantType = seedType,
        growthStage = "seed",
        plantedTime = os.time(),
        watered = false
    }
    
    -- Give XP for planting
    data.xp = data.xp + GameConfig.XPForPlanting
    DataStoreManager.updateStatistics(player, "totalPlantsPlanted", 1)
    
    savePlayerData(player)
    remotes.GetGardenData:FireClient(player, data.garden)
    
    -- Update quest progress
    if _G.QuestManager then
        _G.QuestManager.updateQuestProgress(player, "plant", seedType, 1)
    end
end)

remotes.HarvestPlant.OnServerEvent:Connect(function(player, x, y)
    local data = getPlayerData(player)
    local plotKey = x .. "," .. y
    local plot = data.garden.plots[plotKey]
    
    if not plot or plot.growthStage ~= "mature" then
        return
    end
    
    -- Give coins and XP
    local value = getPlantValue(plot.plantType)
    data.coins = data.coins + value
    data.xp = data.xp + GameConfig.XPForHarvesting
    DataStoreManager.updateStatistics(player, "totalCoinsEarned", value)
    DataStoreManager.updateStatistics(player, "totalPlantsHarvested", 1)
    
    -- Add to harvested crops
    if not data.inventory.harvestedCrops[plot.plantType] then
        data.inventory.harvestedCrops[plot.plantType] = 0
    end
    data.inventory.harvestedCrops[plot.plantType] = data.inventory.harvestedCrops[plot.plantType] + 1
    
    -- Clear the plot
    data.garden.plots[plotKey] = {
        plantType = "",
        growthStage = "",
        plantedTime = 0,
        watered = false
    }
    
    savePlayerData(player)
    remotes.GetGardenData:FireClient(player, data.garden)
    
    -- Update quest progress
    if _G.QuestManager then
        _G.QuestManager.updateQuestProgress(player, "harvest", plot.plantType, 1)
    end
end)

remotes.WaterPlant.OnServerEvent:Connect(function(player, x, y)
    local data = getPlayerData(player)
    local plotKey = x .. "," .. y
    local plot = data.garden.plots[plotKey]
    
    if not plot or plot.plantType == "" or plot.watered then
        return
    end
    
    -- Mark as watered (gives growth speed bonus)
    plot.watered = true
    data.xp = data.xp + GameConfig.XPForWatering
    
    savePlayerData(player)
    remotes.GetGardenData:FireClient(player, data.garden)
    
    -- Update quest progress
    if _G.QuestManager then
        _G.QuestManager.updateQuestProgress(player, "water", "any", 1)
    end
end)

-- Export functions for other modules
_G.GameManager = {
    getPlayerData = getPlayerData,
    savePlayerData = savePlayerData,
    getGrowthTime = getGrowthTime,
    getPlantValue = getPlantValue,
    GameConfig = GameConfig,
    remotes = remotes
}

print("GameManager loaded successfully!")