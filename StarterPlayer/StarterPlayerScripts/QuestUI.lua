-- QuestUI.lua
-- Handles quest and achievement interface

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local remotes = {}

for _, remoteEvent in pairs(remoteEvents:GetChildren()) do
    remotes[remoteEvent.Name] = remoteEvent
end

-- Quest UI
local questFrame = nil
local currentQuestData = {}

-- Create quest UI
function createQuestUI()
    if questFrame then
        questFrame:Destroy()
    end
    
    questFrame = Instance.new("Frame")
    questFrame.Name = "QuestFrame"
    questFrame.Size = UDim2.new(0, 800, 0, 600)
    questFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
    questFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    questFrame.BorderSizePixel = 2
    questFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    questFrame.Parent = playerGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    title.BorderSizePixel = 0
    title.Text = "Quests & Achievements"
    title.TextColor3 = Color3.white
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = questFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -45, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.white
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = questFrame
    
    closeButton.MouseButton1Click:Connect(function()
        questFrame:Destroy()
    end)
    
    -- Tab frame
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = "TabFrame"
    tabFrame.Size = UDim2.new(1, 0, 0, 40)
    tabFrame.Position = UDim2.new(0, 0, 0, 50)
    tabFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tabFrame.BorderSizePixel = 0
    tabFrame.Parent = questFrame
    
    -- Quests tab
    local questsTab = Instance.new("TextButton")
    questsTab.Name = "QuestsTab"
    questsTab.Size = UDim2.new(0.5, 0, 1, 0)
    questsTab.Position = UDim2.new(0, 0, 0, 0)
    questsTab.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    questsTab.Text = "Quests"
    questsTab.TextColor3 = Color3.white
    questsTab.TextScaled = true
    questsTab.Font = Enum.Font.SourceSansBold
    questsTab.Parent = tabFrame
    
    -- Achievements tab
    local achievementsTab = Instance.new("TextButton")
    achievementsTab.Name = "AchievementsTab"
    achievementsTab.Size = UDim2.new(0.5, 0, 1, 0)
    achievementsTab.Position = UDim2.new(0.5, 0, 0, 0)
    achievementsTab.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    achievementsTab.Text = "Achievements"
    achievementsTab.TextColor3 = Color3.white
    achievementsTab.TextScaled = true
    achievementsTab.Font = Enum.Font.SourceSansBold
    achievementsTab.Parent = tabFrame
    
    -- Content frame
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -100)
    contentFrame.Position = UDim2.new(0, 10, 0, 100)
    contentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    contentFrame.BorderSizePixel = 1
    contentFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    contentFrame.ScrollBarThickness = 10
    contentFrame.Parent = questFrame
    
    -- Tab click handlers
    questsTab.MouseButton1Click:Connect(function()
        selectTab("quests")
    end)
    
    achievementsTab.MouseButton1Click:Connect(function()
        selectTab("achievements")
    end)
    
    -- Store references
    questFrame:SetAttribute("QuestsTab", questsTab)
    questFrame:SetAttribute("AchievementsTab", achievementsTab)
    questFrame:SetAttribute("ContentFrame", contentFrame)
    
    -- Load quest data
    remotes.GetQuestData:FireServer()
end

-- Select tab
function selectTab(tab)
    local questsTab = questFrame:GetAttribute("QuestsTab")
    local achievementsTab = questFrame:GetAttribute("AchievementsTab")
    local contentFrame = questFrame:GetAttribute("ContentFrame")
    
    -- Update tab colors
    if tab == "quests" then
        questsTab.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        achievementsTab.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        showQuests()
    else
        questsTab.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        achievementsTab.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        showAchievements()
    end
end

-- Show quests
function showQuests()
    local contentFrame = questFrame:GetAttribute("ContentFrame")
    
    -- Clear content
    for _, child in pairs(contentFrame:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
    
    local quests = currentQuestData.quests or {}
    local yOffset = 0
    
    for _, quest in pairs(quests) do
        local questFrame = Instance.new("Frame")
        questFrame.Name = quest.id .. "Quest"
        questFrame.Size = UDim2.new(1, -10, 0, 100)
        questFrame.Position = UDim2.new(0, 5, 0, yOffset)
        questFrame.BackgroundColor3 = quest.completed and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(60, 60, 60)
        questFrame.BorderSizePixel = 1
        questFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
        questFrame.Parent = contentFrame
        
        -- Quest name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(0.7, 0, 0, 25)
        nameLabel.Position = UDim2.new(0, 10, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = quest.name
        nameLabel.TextColor3 = Color3.white
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Parent = questFrame
        
        -- Quest description
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "DescLabel"
        descLabel.Size = UDim2.new(0.7, 0, 0, 20)
        descLabel.Position = UDim2.new(0, 10, 0, 30)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = quest.description
        descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextScaled = true
        descLabel.Font = Enum.Font.SourceSans
        descLabel.Parent = questFrame
        
        -- Progress
        local progressLabel = Instance.new("TextLabel")
        progressLabel.Name = "ProgressLabel"
        progressLabel.Size = UDim2.new(0.7, 0, 0, 20)
        progressLabel.Position = UDim2.new(0, 10, 0, 50)
        progressLabel.BackgroundTransparency = 1
        progressLabel.Text = quest.progress .. "/" .. quest.targetCount
        progressLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        progressLabel.TextXAlignment = Enum.TextXAlignment.Left
        progressLabel.TextScaled = true
        progressLabel.Font = Enum.Font.SourceSans
        progressLabel.Parent = questFrame
        
        -- Complete button
        if quest.completed then
            local completeButton = Instance.new("TextButton")
            completeButton.Name = "CompleteButton"
            completeButton.Size = UDim2.new(0, 100, 0, 30)
            completeButton.Position = UDim2.new(0.7, 10, 0, 35)
            completeButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            completeButton.Text = "Complete"
            completeButton.TextColor3 = Color3.white
            completeButton.TextScaled = true
            completeButton.Font = Enum.Font.SourceSansBold
            completeButton.Parent = questFrame
            
            completeButton.MouseButton1Click:Connect(function()
                remotes.CompleteQuest:FireServer(quest.id)
            end)
        end
        
        -- Rewards
        local rewardText = ""
        if quest.reward.coins then
            rewardText = rewardText .. quest.reward.coins .. " coins"
        end
        if quest.reward.xp then
            if rewardText ~= "" then rewardText = rewardText .. ", " end
            rewardText = rewardText .. quest.reward.xp .. " XP"
        end
        
        local rewardLabel = Instance.new("TextLabel")
        rewardLabel.Name = "RewardLabel"
        rewardLabel.Size = UDim2.new(0.3, 0, 0, 20)
        rewardLabel.Position = UDim2.new(0.7, 10, 0, 70)
        rewardLabel.BackgroundTransparency = 1
        rewardLabel.Text = "Reward: " .. rewardText
        rewardLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        rewardLabel.TextScaled = true
        rewardLabel.Font = Enum.Font.SourceSans
        rewardLabel.Parent = questFrame
        
        yOffset = yOffset + 105
    end
    
    -- Update canvas size
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Show achievements
function showAchievements()
    local contentFrame = questFrame:GetAttribute("ContentFrame")
    
    -- Clear content
    for _, child in pairs(contentFrame:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
    
    local achievements = currentQuestData.achievements or {}
    local yOffset = 0
    
    for _, achievement in pairs(achievements) do
        local achievementFrame = Instance.new("Frame")
        achievementFrame.Name = achievement.id .. "Achievement"
        achievementFrame.Size = UDim2.new(1, -10, 0, 80)
        achievementFrame.Position = UDim2.new(0, 5, 0, yOffset)
        achievementFrame.BackgroundColor3 = achievement.completed and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(60, 60, 60)
        achievementFrame.BorderSizePixel = 1
        achievementFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
        achievementFrame.Parent = contentFrame
        
        -- Achievement name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(0.7, 0, 0, 25)
        nameLabel.Position = UDim2.new(0, 10, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = achievement.name
        nameLabel.TextColor3 = Color3.white
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Parent = achievementFrame
        
        -- Achievement description
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "DescLabel"
        descLabel.Size = UDim2.new(0.7, 0, 0, 20)
        descLabel.Position = UDim2.new(0, 10, 0, 30)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = achievement.description
        descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextScaled = true
        descLabel.Font = Enum.Font.SourceSans
        descLabel.Parent = achievementFrame
        
        -- Progress
        local progressLabel = Instance.new("TextLabel")
        progressLabel.Name = "ProgressLabel"
        progressLabel.Size = UDim2.new(0.7, 0, 0, 20)
        progressLabel.Position = UDim2.new(0, 10, 0, 50)
        progressLabel.BackgroundTransparency = 1
        progressLabel.Text = achievement.progress .. "/" .. achievement.targetCount
        progressLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        progressLabel.TextXAlignment = Enum.TextXAlignment.Left
        progressLabel.TextScaled = true
        progressLabel.Font = Enum.Font.SourceSans
        progressLabel.Parent = achievementFrame
        
        -- Complete button
        if achievement.completed then
            local completeButton = Instance.new("TextButton")
            completeButton.Name = "CompleteButton"
            completeButton.Size = UDim2.new(0, 100, 0, 30)
            completeButton.Position = UDim2.new(0.7, 10, 0, 25)
            completeButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
            completeButton.Text = "Claim"
            completeButton.TextColor3 = Color3.black
            completeButton.TextScaled = true
            completeButton.Font = Enum.Font.SourceSansBold
            completeButton.Parent = achievementFrame
            
            completeButton.MouseButton1Click:Connect(function()
                remotes.CompleteQuest:FireServer(achievement.id)
            end)
        end
        
        yOffset = yOffset + 85
    end
    
    -- Update canvas size
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Handle RemoteEvents
remotes.GetQuestData.OnClientEvent:Connect(function(questData)
    currentQuestData = questData
    if questFrame then
        selectTab("quests") -- Default to quests tab
    end
end)

remotes.CompleteQuest.OnClientEvent:Connect(function(success, message)
    if success then
        print("Quest/Achievement completed: " .. message)
        -- Refresh quest data
        remotes.GetQuestData:FireServer()
    else
        print("Quest/Achievement completion failed: " .. message)
    end
end)

-- Export function for other scripts
_G.QuestUI = {
    createQuestUI = createQuestUI
}

print("QuestUI loaded successfully!")