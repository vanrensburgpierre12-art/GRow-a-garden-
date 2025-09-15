-- DailyRewardUI.lua
-- Handles daily reward interface

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local remotes = {}

for _, remoteEvent in pairs(remoteEvents:GetChildren()) do
    remotes[remoteEvent.Name] = remoteEvent
end

-- Daily reward UI
local dailyRewardFrame = nil
local currentRewardData = {}

-- Create daily reward UI
function createDailyRewardUI()
    if dailyRewardFrame then
        dailyRewardFrame:Destroy()
    end
    
    dailyRewardFrame = Instance.new("Frame")
    dailyRewardFrame.Name = "DailyRewardFrame"
    dailyRewardFrame.Size = UDim2.new(0, 500, 0, 400)
    dailyRewardFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    dailyRewardFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    dailyRewardFrame.BorderSizePixel = 3
    dailyRewardFrame.BorderColor3 = Color3.fromRGB(255, 215, 0)
    dailyRewardFrame.Parent = playerGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 60)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    title.BorderSizePixel = 0
    title.Text = "Daily Reward"
    title.TextColor3 = Color3.black
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = dailyRewardFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -45, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.white
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = dailyRewardFrame
    
    closeButton.MouseButton1Click:Connect(function()
        dailyRewardFrame:Destroy()
    end)
    
    -- Streak display
    local streakFrame = Instance.new("Frame")
    streakFrame.Name = "StreakFrame"
    streakFrame.Size = UDim2.new(1, -20, 0, 60)
    streakFrame.Position = UDim2.new(0, 10, 0, 70)
    streakFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    streakFrame.BorderSizePixel = 1
    streakFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    streakFrame.Parent = dailyRewardFrame
    
    local streakLabel = Instance.new("TextLabel")
    streakLabel.Name = "StreakLabel"
    streakLabel.Size = UDim2.new(1, 0, 1, 0)
    streakLabel.Position = UDim2.new(0, 0, 0, 0)
    streakLabel.BackgroundTransparency = 1
    streakLabel.Text = "Current Streak: 0/7"
    streakLabel.TextColor3 = Color3.white
    streakLabel.TextScaled = true
    streakLabel.Font = Enum.Font.SourceSansBold
    streakLabel.Parent = streakFrame
    
    -- Reward display
    local rewardFrame = Instance.new("Frame")
    rewardFrame.Name = "RewardFrame"
    rewardFrame.Size = UDim2.new(1, -20, 0, 120)
    rewardFrame.Position = UDim2.new(0, 10, 0, 140)
    rewardFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    rewardFrame.BorderSizePixel = 1
    rewardFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    rewardFrame.Parent = dailyRewardFrame
    
    local rewardTitle = Instance.new("TextLabel")
    rewardTitle.Name = "RewardTitle"
    rewardTitle.Size = UDim2.new(1, 0, 0, 30)
    rewardTitle.Position = UDim2.new(0, 0, 0, 0)
    rewardTitle.BackgroundTransparency = 1
    rewardTitle.Text = "Today's Reward"
    rewardTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
    rewardTitle.TextScaled = true
    rewardTitle.Font = Enum.Font.SourceSansBold
    rewardTitle.Parent = rewardFrame
    
    local rewardDescription = Instance.new("TextLabel")
    rewardDescription.Name = "RewardDescription"
    rewardDescription.Size = UDim2.new(1, -10, 0, 40)
    rewardDescription.Position = UDim2.new(0, 5, 0, 30)
    rewardDescription.BackgroundTransparency = 1
    rewardDescription.Text = "Loading reward..."
    rewardDescription.TextColor3 = Color3.white
    rewardDescription.TextWrapped = true
    rewardDescription.TextScaled = true
    rewardDescription.Font = Enum.Font.SourceSans
    rewardDescription.Parent = rewardFrame
    
    local rewardCoins = Instance.new("TextLabel")
    rewardCoins.Name = "RewardCoins"
    rewardCoins.Size = UDim2.new(0.5, 0, 0, 25)
    rewardCoins.Position = UDim2.new(0, 5, 0, 70)
    rewardCoins.BackgroundTransparency = 1
    rewardCoins.Text = "Coins: 0"
    rewardCoins.TextColor3 = Color3.fromRGB(255, 215, 0)
    rewardCoins.TextScaled = true
    rewardCoins.Font = Enum.Font.SourceSansBold
    rewardCoins.Parent = rewardFrame
    
    local rewardSeeds = Instance.new("TextLabel")
    rewardSeeds.Name = "RewardSeeds"
    rewardSeeds.Size = UDim2.new(0.5, 0, 0, 25)
    rewardSeeds.Position = UDim2.new(0.5, 5, 0, 70)
    rewardSeeds.BackgroundTransparency = 1
    rewardSeeds.Text = "Seeds: None"
    rewardSeeds.TextColor3 = Color3.fromRGB(0, 255, 0)
    rewardSeeds.TextScaled = true
    rewardSeeds.Font = Enum.Font.SourceSansBold
    rewardSeeds.Parent = rewardFrame
    
    -- Claim button
    local claimButton = Instance.new("TextButton")
    claimButton.Name = "ClaimButton"
    claimButton.Size = UDim2.new(0, 200, 0, 50)
    claimButton.Position = UDim2.new(0.5, -100, 0, 270)
    claimButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    claimButton.Text = "Claim Reward"
    claimButton.TextColor3 = Color3.white
    claimButton.TextScaled = true
    claimButton.Font = Enum.Font.SourceSansBold
    claimButton.Parent = dailyRewardFrame
    
    claimButton.MouseButton1Click:Connect(function()
        remotes.ClaimDailyReward:FireServer()
    end)
    
    -- Time remaining display
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "TimeLabel"
    timeLabel.Size = UDim2.new(1, -20, 0, 30)
    timeLabel.Position = UDim2.new(0, 10, 0, 330)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = ""
    timeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    timeLabel.TextScaled = true
    timeLabel.Font = Enum.Font.SourceSans
    timeLabel.Parent = dailyRewardFrame
    
    -- Store references
    dailyRewardFrame:SetAttribute("StreakLabel", streakLabel)
    dailyRewardFrame:SetAttribute("RewardDescription", rewardDescription)
    dailyRewardFrame:SetAttribute("RewardCoins", rewardCoins)
    dailyRewardFrame:SetAttribute("RewardSeeds", rewardSeeds)
    dailyRewardFrame:SetAttribute("ClaimButton", claimButton)
    dailyRewardFrame:SetAttribute("TimeLabel", timeLabel)
    
    -- Load reward data
    remotes.ClaimDailyReward:FireServer()
end

-- Update reward display
function updateRewardDisplay()
    if not dailyRewardFrame then return end
    
    local streakLabel = dailyRewardFrame:GetAttribute("StreakLabel")
    local rewardDescription = dailyRewardFrame:GetAttribute("RewardDescription")
    local rewardCoins = dailyRewardFrame:GetAttribute("RewardCoins")
    local rewardSeeds = dailyRewardFrame:GetAttribute("RewardSeeds")
    local claimButton = dailyRewardFrame:GetAttribute("ClaimButton")
    local timeLabel = dailyRewardFrame:GetAttribute("TimeLabel")
    
    -- Update streak
    streakLabel.Text = "Current Streak: " .. (currentRewardData.currentStreak or 0) .. "/" .. (currentRewardData.maxStreak or 7)
    
    if currentRewardData.canClaim then
        -- Can claim reward
        local reward = currentRewardData.nextReward
        if reward then
            rewardDescription.Text = reward.message or "Claim your daily reward!"
            
            -- Show coins
            if reward.coins and reward.coins > 0 then
                rewardCoins.Text = "Coins: " .. reward.coins
            else
                rewardCoins.Text = "Coins: 0"
            end
            
            -- Show seeds
            local seedText = "Seeds: "
            if reward.seeds then
                local seedList = {}
                for seedType, amount in pairs(reward.seeds) do
                    table.insert(seedList, amount .. " " .. seedType)
                end
                if #seedList > 0 then
                    seedText = seedText .. table.concat(seedList, ", ")
                else
                    seedText = seedText .. "None"
                end
            else
                seedText = seedText .. "None"
            end
            rewardSeeds.Text = seedText
            
            claimButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            claimButton.Text = "Claim Reward"
            claimButton.Active = true
        end
        
        timeLabel.Text = ""
    else
        -- Cannot claim yet
        rewardDescription.Text = "Come back tomorrow for your next reward!"
        rewardCoins.Text = "Coins: 0"
        rewardSeeds.Text = "Seeds: None"
        
        claimButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        claimButton.Text = "Not Available"
        claimButton.Active = false
        
        -- Show time remaining
        local hoursRemaining = currentRewardData.timeUntilNext or 0
        local hours = math.floor(hoursRemaining)
        local minutes = math.floor((hoursRemaining - hours) * 60)
        timeLabel.Text = "Next reward in: " .. hours .. "h " .. minutes .. "m"
    end
end

-- Handle RemoteEvents
remotes.ClaimDailyReward.OnClientEvent:Connect(function(success, message, rewardData)
    if success and rewardData then
        currentRewardData = rewardData
        updateRewardDisplay()
        
        if message and message ~= "" then
            print("Daily reward: " .. message)
        end
    end
end)

-- Export function for other scripts
_G.DailyRewardUI = {
    createDailyRewardUI = createDailyRewardUI
}

print("DailyRewardUI loaded successfully!")