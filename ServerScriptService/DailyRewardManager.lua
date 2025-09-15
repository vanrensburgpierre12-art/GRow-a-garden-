-- DailyRewardManager.lua
-- Handles daily login rewards and streak bonuses

-- Wait for GameManager to load
repeat wait() until _G.GameManager

local GameManager = _G.GameManager
local remotes = GameManager.remotes

-- Daily reward configuration
local DailyRewards = {
    [1] = {coins = 50, seeds = {carrot = 2}, message = "Welcome back! Here's 50 coins and 2 carrot seeds."},
    [2] = {coins = 75, seeds = {tomato = 1}, message = "Day 2! 75 coins and a tomato seed."},
    [3] = {coins = 100, seeds = {carrot = 3, tomato = 2}, message = "Day 3! 100 coins and some seeds."},
    [4] = {coins = 150, seeds = {sunflower = 1}, message = "Day 4! 150 coins and a sunflower seed."},
    [5] = {coins = 200, seeds = {carrot = 5, tomato = 3}, message = "Day 5! 200 coins and more seeds."},
    [6] = {coins = 300, seeds = {pumpkin = 1}, message = "Day 6! 300 coins and a pumpkin seed!"},
    [7] = {coins = 500, seeds = {goldenRose = 1}, message = "Week complete! 500 coins and a rare golden rose seed!"}
}

-- Check if player can claim daily reward
local function canClaimDailyReward(player)
    local data = GameManager.getPlayerData(player)
    local currentTime = os.time()
    local lastClaimed = data.dailyRewards.lastClaimed
    local streak = data.dailyRewards.streak
    
    -- Check if it's been at least 24 hours since last claim
    local timeSinceLastClaim = currentTime - lastClaimed
    local hoursSinceLastClaim = timeSinceLastClaim / 3600
    
    if hoursSinceLastClaim >= 24 then
        -- Check if streak should continue or reset
        if hoursSinceLastClaim < 48 then
            -- Within 48 hours, continue streak
            return true, streak + 1
        else
            -- More than 48 hours, reset streak
            return true, 1
        end
    else
        -- Less than 24 hours, can't claim yet
        local hoursRemaining = 24 - hoursSinceLastClaim
        return false, hoursRemaining
    end
end

-- Get daily reward data for player
local function getDailyRewardData(player)
    local data = GameManager.getPlayerData(player)
    local canClaim, timeInfo = canClaimDailyReward(player)
    
    local rewardData = {
        canClaim = canClaim,
        currentStreak = data.dailyRewards.streak,
        maxStreak = 7,
        nextReward = nil,
        timeUntilNext = nil
    }
    
    if canClaim then
        local nextStreak = timeInfo
        if nextStreak <= 7 then
            rewardData.nextReward = DailyRewards[nextStreak]
        else
            -- Streak complete, give bonus reward
            rewardData.nextReward = {
                coins = 1000,
                seeds = {rainbowFlower = 1},
                message = "Amazing streak! 1000 coins and a rainbow flower seed!"
            }
        end
    else
        rewardData.timeUntilNext = timeInfo
    end
    
    return rewardData
end

-- Claim daily reward
local function claimDailyReward(player)
    local data = GameManager.getPlayerData(player)
    local canClaim, newStreak = canClaimDailyReward(player)
    
    if not canClaim then
        return false, "Cannot claim reward yet"
    end
    
    -- Update streak
    data.dailyRewards.streak = newStreak
    data.dailyRewards.lastClaimed = os.time()
    
    -- Get reward
    local reward = DailyRewards[newStreak]
    if not reward then
        -- Streak beyond 7, give bonus reward
        reward = {
            coins = 1000,
            seeds = {rainbowFlower = 1},
            message = "Amazing streak! 1000 coins and a rainbow flower seed!"
        }
    end
    
    -- Apply streak multiplier
    local multiplier = 1 + (GameManager.GameConfig.DailyRewardStreakMultiplier * (newStreak - 1))
    reward.coins = math.floor(reward.coins * multiplier)
    
    -- Give rewards
    data.coins = data.coins + reward.coins
    
    -- Give seeds
    for seedType, amount in pairs(reward.seeds) do
        if not data.inventory.seeds[seedType] then
            data.inventory.seeds[seedType] = 0
        end
        data.inventory.seeds[seedType] = data.inventory.seeds[seedType] + amount
    end
    
    -- Give XP for claiming
    data.xp = data.xp + 25
    
    GameManager.savePlayerData(player)
    
    return true, reward.message, reward
end

-- Handle RemoteEvents
remotes.ClaimDailyReward.OnServerEvent:Connect(function(player)
    local success, message, reward = claimDailyReward(player)
    remotes.ClaimDailyReward:FireClient(player, success, message, reward)
    
    if success then
        -- Send updated inventory
        local data = GameManager.getPlayerData(player)
        local inventory = {
            seeds = data.inventory.seeds,
            tools = data.inventory.tools or {},
            decorations = data.inventory.decorations,
            harvestedCrops = data.inventory.harvestedCrops,
            coins = data.coins,
            xp = data.xp,
            level = data.level
        }
        remotes.GetInventory:FireClient(player, inventory)
    end
end)

-- Send daily reward data when player joins
local Players = game:GetService("Players")
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        wait(2) -- Wait for client to load
        
        local rewardData = getDailyRewardData(player)
        remotes.ClaimDailyReward:FireClient(player, true, "", rewardData)
    end)
end)

print("DailyRewardManager loaded successfully!")