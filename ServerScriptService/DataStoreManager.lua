-- DataStoreManager.lua
-- Enhanced data persistence with error handling and retry logic

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Load configuration
local GameConfig = require(script.Parent.GameConfig)

-- DataStore setup
local playerDataStore = DataStoreService:GetDataStore(GameConfig.DataStore.KeyPrefix .. "PlayerData")

-- Player data cache
local playerData = {}
local saveQueue = {}
local isSaving = {}

-- Create default player data
local function createDefaultPlayerData()
    return {
        coins = GameConfig.StartingCoins,
        xp = GameConfig.StartingXP,
        level = GameConfig.StartingLevel,
        unlockedSeeds = {"carrot", "tomato"},
        inventory = {
            seeds = {carrot = 5, tomato = 3},
            tools = {},
            decorations = {},
            harvestedCrops = {}
        },
        garden = {
            plots = {},
            decorations = {},
            size = GameConfig.StartingGardenSize
        },
        quests = {
            completed = {},
            active = {},
            progress = {}
        },
        dailyRewards = {
            lastClaimed = 0,
            streak = 0
        },
        achievements = {
            unlocked = {},
            progress = {}
        },
        friends = {},
        lastLogin = os.time(),
        totalPlayTime = 0,
        statistics = {
            totalPlantsPlanted = 0,
            totalPlantsHarvested = 0,
            totalCoinsEarned = 0,
            totalXP = 0
        }
    }
end

-- Load player data with retry logic
local function loadPlayerData(player)
    local success, data = pcall(function()
        return playerDataStore:GetAsync(player.UserId)
    end)
    
    if success and data then
        -- Validate and migrate data if needed
        data = validateAndMigrateData(data)
        playerData[player.UserId] = data
        print("Loaded data for " .. player.Name)
        return true
    else
        playerData[player.UserId] = createDefaultPlayerData()
        print("Created new data for " .. player.Name)
        return false
    end
end

-- Validate and migrate player data
function validateAndMigrateData(data)
    local defaultData = createDefaultPlayerData()
    
    -- Ensure all required fields exist
    for key, value in pairs(defaultData) do
        if data[key] == nil then
            data[key] = value
        end
    end
    
    -- Migrate old data structures if needed
    if not data.statistics then
        data.statistics = defaultData.statistics
    end
    
    if not data.totalPlayTime then
        data.totalPlayTime = 0
    end
    
    -- Ensure garden size is within limits
    if data.garden.size > GameConfig.MaxGardenSize then
        data.garden.size = GameConfig.MaxGardenSize
    end
    
    return data
end

-- Save player data with retry logic
local function savePlayerData(player)
    if not playerData[player.UserId] or isSaving[player.UserId] then
        return false
    end
    
    isSaving[player.UserId] = true
    
    local success, error = pcall(function()
        playerDataStore:SetAsync(player.UserId, playerData[player.UserId])
    end)
    
    isSaving[player.UserId] = false
    
    if success then
        print("Saved data for " .. player.Name)
        return true
    else
        warn("Failed to save data for " .. player.Name .. ": " .. tostring(error))
        
        -- Add to save queue for retry
        saveQueue[player.UserId] = {
            data = playerData[player.UserId],
            retries = 0
        }
        return false
    end
end

-- Retry failed saves
local function retryFailedSaves()
    for userId, saveData in pairs(saveQueue) do
        if saveData.retries < GameConfig.DataStore.MaxRetries then
            local success, error = pcall(function()
                playerDataStore:SetAsync(userId, saveData.data)
            end)
            
            if success then
                print("Retry save successful for user " .. userId)
                saveQueue[userId] = nil
            else
                saveData.retries = saveData.retries + 1
                warn("Retry save failed for user " .. userId .. " (attempt " .. saveData.retries .. "): " .. tostring(error))
            end
        else
            warn("Max retries reached for user " .. userId .. ", removing from queue")
            saveQueue[userId] = nil
        end
    end
end

-- Get player data
local function getPlayerData(player)
    if not playerData[player.UserId] then
        loadPlayerData(player)
    end
    return playerData[player.UserId]
end

-- Update player statistics
local function updateStatistics(player, statType, amount)
    local data = getPlayerData(player)
    if data.statistics[statType] then
        data.statistics[statType] = data.statistics[statType] + amount
    end
end

-- Player joining
Players.PlayerAdded:Connect(function(player)
    loadPlayerData(player)
    
    -- Update last login time
    local data = getPlayerData(player)
    data.lastLogin = os.time()
end)

-- Player leaving
Players.PlayerRemoving:Connect(function(player)
    savePlayerData(player)
    playerData[player.UserId] = nil
end)

-- Auto-save system
spawn(function()
    while true do
        wait(GameConfig.DataStore.SaveInterval)
        
        -- Save all online players
        for _, player in pairs(Players:GetPlayers()) do
            if playerData[player.UserId] then
                -- Update play time
                local data = getPlayerData(player)
                data.totalPlayTime = data.totalPlayTime + GameConfig.DataStore.SaveInterval
                
                savePlayerData(player)
            end
        end
        
        -- Retry failed saves
        retryFailedSaves()
    end
end)

-- Export functions
_G.DataStoreManager = {
    getPlayerData = getPlayerData,
    savePlayerData = savePlayerData,
    updateStatistics = updateStatistics,
    loadPlayerData = loadPlayerData
}

print("DataStoreManager loaded successfully!")