-- QuestManager.lua
-- Handles quest system, achievements, and progression tracking

-- Wait for GameManager to load
repeat wait() until _G.GameManager

local GameManager = _G.GameManager
local remotes = GameManager.remotes

-- Quest configuration
local QuestDatabase = {
    -- Planting quests
    plantCarrots = {
        id = "plantCarrots",
        name = "First Steps",
        description = "Plant 5 carrot seeds",
        type = "plant",
        target = "carrot",
        targetCount = 5,
        reward = {coins = 25, xp = 50},
        unlockLevel = 1
    },
    plantTomatoes = {
        id = "plantTomatoes", 
        name = "Tomato Time",
        description = "Plant 10 tomato seeds",
        type = "plant",
        target = "tomato",
        targetCount = 10,
        reward = {coins = 50, xp = 100},
        unlockLevel = 2
    },
    plantSunflowers = {
        id = "plantSunflowers",
        name = "Sunny Garden",
        description = "Plant 8 sunflower seeds",
        type = "plant", 
        target = "sunflower",
        targetCount = 8,
        reward = {coins = 80, xp = 150},
        unlockLevel = 3
    },
    
    -- Harvesting quests
    harvestCarrots = {
        id = "harvestCarrots",
        name = "Harvest Time",
        description = "Harvest 15 carrots",
        type = "harvest",
        target = "carrot",
        targetCount = 15,
        reward = {coins = 75, xp = 100},
        unlockLevel = 1
    },
    harvestTomatoes = {
        id = "harvestTomatoes",
        name = "Tomato Harvest",
        description = "Harvest 20 tomatoes",
        type = "harvest",
        target = "tomato", 
        targetCount = 20,
        reward = {coins = 100, xp = 150},
        unlockLevel = 2
    },
    
    -- Watering quests
    waterPlants = {
        id = "waterPlants",
        name = "Green Thumb",
        description = "Water 25 plants",
        type = "water",
        target = "any",
        targetCount = 25,
        reward = {coins = 50, xp = 75},
        unlockLevel = 2
    },
    
    -- Level quests
    reachLevel5 = {
        id = "reachLevel5",
        name = "Growing Strong",
        description = "Reach level 5",
        type = "level",
        target = 5,
        targetCount = 1,
        reward = {coins = 200, xp = 0},
        unlockLevel = 1
    },
    reachLevel10 = {
        id = "reachLevel10",
        name = "Garden Master",
        description = "Reach level 10",
        type = "level",
        target = 10,
        targetCount = 1,
        reward = {coins = 500, xp = 0},
        unlockLevel = 5
    },
    
    -- Collection quests
    collectDecorations = {
        id = "collectDecorations",
        name = "Decorator",
        description = "Collect 5 different decorations",
        type = "collect",
        target = "decorations",
        targetCount = 5,
        reward = {coins = 100, xp = 100},
        unlockLevel = 4
    }
}

-- Achievement configuration
local AchievementDatabase = {
    firstPlant = {
        id = "firstPlant",
        name = "Green Fingers",
        description = "Plant your first seed",
        type = "plant",
        target = "any",
        targetCount = 1,
        reward = {coins = 10, xp = 20},
        hidden = false
    },
    firstHarvest = {
        id = "firstHarvest",
        name = "First Harvest",
        description = "Harvest your first plant",
        type = "harvest",
        target = "any", 
        targetCount = 1,
        reward = {coins = 15, xp = 25},
        hidden = false
    },
    plantMaster = {
        id = "plantMaster",
        name = "Plant Master",
        description = "Plant 100 seeds total",
        type = "plant",
        target = "any",
        targetCount = 100,
        reward = {coins = 500, xp = 200},
        hidden = false
    },
    harvestMaster = {
        id = "harvestMaster", 
        name = "Harvest Master",
        description = "Harvest 200 plants total",
        type = "harvest",
        target = "any",
        targetCount = 200,
        reward = {coins = 1000, xp = 300},
        hidden = false
    },
    coinCollector = {
        id = "coinCollector",
        name = "Coin Collector",
        description = "Earn 10,000 coins total",
        type = "coins",
        target = 10000,
        targetCount = 1,
        reward = {coins = 0, xp = 500},
        hidden = false
    }
}

-- Get available quests for player
local function getAvailableQuests(player)
    local data = GameManager.getPlayerData(player)
    local availableQuests = {}
    
    for questId, questData in pairs(QuestDatabase) do
        if data.level >= questData.unlockLevel and not data.quests.completed[questId] then
            local quest = {
                id = questId,
                name = questData.name,
                description = questData.description,
                type = questData.type,
                target = questData.target,
                targetCount = questData.targetCount,
                reward = questData.reward,
                progress = data.quests.progress[questId] or 0,
                completed = false
            }
            
            if quest.progress >= quest.targetCount then
                quest.completed = true
            end
            
            table.insert(availableQuests, quest)
        end
    end
    
    return availableQuests
end

-- Get available achievements for player
local function getAvailableAchievements(player)
    local data = GameManager.getPlayerData(player)
    local availableAchievements = {}
    
    for achievementId, achievementData in pairs(AchievementDatabase) do
        if not data.achievements.unlocked[achievementId] then
            local achievement = {
                id = achievementId,
                name = achievementData.name,
                description = achievementData.description,
                type = achievementData.type,
                target = achievementData.target,
                targetCount = achievementData.targetCount,
                reward = achievementData.reward,
                progress = data.achievements.progress[achievementId] or 0,
                completed = false,
                hidden = achievementData.hidden
            }
            
            if achievement.progress >= achievement.targetCount then
                achievement.completed = true
            end
            
            table.insert(availableAchievements, achievement)
        end
    end
    
    return availableAchievements
end

-- Update quest progress
local function updateQuestProgress(player, actionType, target, amount)
    local data = GameManager.getPlayerData(player)
    local updated = false
    
    -- Update quest progress
    for questId, questData in pairs(QuestDatabase) do
        if not data.quests.completed[questId] and questData.type == actionType then
            if questData.target == target or questData.target == "any" then
                if not data.quests.progress[questId] then
                    data.quests.progress[questId] = 0
                end
                
                data.quests.progress[questId] = data.quests.progress[questId] + amount
                updated = true
            end
        end
    end
    
    -- Update achievement progress
    for achievementId, achievementData in pairs(AchievementDatabase) do
        if not data.achievements.unlocked[achievementId] and achievementData.type == actionType then
            if achievementData.target == target or achievementData.target == "any" then
                if not data.achievements.progress[achievementId] then
                    data.achievements.progress[achievementId] = 0
                end
                
                data.achievements.progress[achievementId] = data.achievements.progress[achievementId] + amount
                updated = true
            end
        end
    end
    
    if updated then
        GameManager.savePlayerData(player)
    end
end

-- Complete quest
local function completeQuest(player, questId)
    local data = GameManager.getPlayerData(player)
    local questData = QuestDatabase[questId]
    
    if not questData or data.quests.completed[questId] then
        return false, "Quest not found or already completed"
    end
    
    local progress = data.quests.progress[questId] or 0
    if progress < questData.targetCount then
        return false, "Quest not completed yet"
    end
    
    -- Mark as completed
    data.quests.completed[questId] = true
    
    -- Give rewards
    if questData.reward.coins then
        data.coins = data.coins + questData.reward.coins
    end
    if questData.reward.xp then
        data.xp = data.xp + questData.reward.xp
    end
    
    GameManager.savePlayerData(player)
    return true, "Quest completed!"
end

-- Complete achievement
local function completeAchievement(player, achievementId)
    local data = GameManager.getPlayerData(player)
    local achievementData = AchievementDatabase[achievementId]
    
    if not achievementData or data.achievements.unlocked[achievementId] then
        return false, "Achievement not found or already unlocked"
    end
    
    local progress = data.achievements.progress[achievementId] or 0
    if progress < achievementData.targetCount then
        return false, "Achievement not completed yet"
    end
    
    -- Mark as unlocked
    data.achievements.unlocked[achievementId] = true
    
    -- Give rewards
    if achievementData.reward.coins then
        data.coins = data.coins + achievementData.reward.coins
    end
    if achievementData.reward.xp then
        data.xp = data.xp + achievementData.reward.xp
    end
    
    GameManager.savePlayerData(player)
    return true, "Achievement unlocked!"
end

-- Handle RemoteEvents
remotes.GetQuestData.OnServerEvent:Connect(function(player)
    local questData = {
        quests = getAvailableQuests(player),
        achievements = getAvailableAchievements(player)
    }
    remotes.GetQuestData:FireClient(player, questData)
end)

remotes.CompleteQuest.OnServerEvent:Connect(function(player, questId)
    local success, message = completeQuest(player, questId)
    remotes.CompleteQuest:FireClient(player, success, message)
end)

-- Hook into game actions to update progress
local originalPlantSeed = remotes.PlantSeed.OnServerEvent
remotes.PlantSeed.OnServerEvent:Connect(function(player, x, y, seedType)
    -- Call original handler
    originalPlantSeed:Fire(player, x, y, seedType)
    
    -- Update quest progress
    updateQuestProgress(player, "plant", seedType, 1)
end)

local originalHarvestPlant = remotes.HarvestPlant.OnServerEvent
remotes.HarvestPlant.OnServerEvent:Connect(function(player, x, y)
    -- Call original handler
    originalHarvestPlant:Fire(player, x, y)
    
    -- Get plant type for progress tracking
    local data = GameManager.getPlayerData(player)
    local plotKey = x .. "," .. y
    local plot = data.garden.plots[plotKey]
    
    if plot and plot.plantType then
        updateQuestProgress(player, "harvest", plot.plantType, 1)
    end
end)

local originalWaterPlant = remotes.WaterPlant.OnServerEvent
remotes.WaterPlant.OnServerEvent:Connect(function(player, x, y)
    -- Call original handler
    originalWaterPlant:Fire(player, x, y)
    
    -- Update quest progress
    updateQuestProgress(player, "water", "any", 1)
end)

-- Level up tracking
local function checkLevelUp(player)
    local data = GameManager.getPlayerData(player)
    local newLevel = math.floor(data.xp / 100) + 1 -- 100 XP per level
    
    if newLevel > data.level then
        data.level = newLevel
        GameManager.savePlayerData(player)
        
        -- Update level-based quest progress
        updateQuestProgress(player, "level", newLevel, 1)
        
        -- Notify client of level up
        remotes.GetInventory:FireClient(player, {
            seeds = data.inventory.seeds,
            tools = data.inventory.tools or {},
            decorations = data.inventory.decorations,
            harvestedCrops = data.inventory.harvestedCrops,
            coins = data.coins,
            xp = data.xp,
            level = data.level
        })
    end
end

-- Check for level ups when XP changes
local Players = game:GetService("Players")
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        spawn(function()
            while player.Parent do
                checkLevelUp(player)
                wait(5) -- Check every 5 seconds
            end
        end)
    end)
end)

print("QuestManager loaded successfully!")