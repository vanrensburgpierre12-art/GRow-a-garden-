-- ClientManager.lua
-- Main client script that manages UI and game interaction

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for RemoteEvents
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local remotes = {}

for _, remoteEvent in pairs(remoteEvents:GetChildren()) do
    remotes[remoteEvent.Name] = remoteEvent
end

-- Game state
local gameState = {
    gardenData = {},
    inventory = {},
    shopData = {},
    questData = {},
    dailyRewardData = {},
    friendData = {}
}

-- UI setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GardenGameUI"
screenGui.Parent = playerGui

-- Create main UI frames
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.Position = UDim2.new(0, 0, 0, 0)
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = screenGui

-- Top HUD
local hudFrame = Instance.new("Frame")
hudFrame.Name = "HUD"
hudFrame.Size = UDim2.new(1, 0, 0, 80)
hudFrame.Position = UDim2.new(0, 0, 0, 0)
hudFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
hudFrame.BorderSizePixel = 0
hudFrame.Parent = mainFrame

-- Coins display
local coinsLabel = Instance.new("TextLabel")
coinsLabel.Name = "CoinsLabel"
coinsLabel.Size = UDim2.new(0, 150, 0, 30)
coinsLabel.Position = UDim2.new(0, 10, 0, 10)
coinsLabel.BackgroundTransparency = 1
coinsLabel.Text = "Coins: 0"
coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
coinsLabel.TextScaled = true
coinsLabel.Font = Enum.Font.SourceSansBold
coinsLabel.Parent = hudFrame

-- XP display
local xpLabel = Instance.new("TextLabel")
xpLabel.Name = "XPLabel"
xpLabel.Size = UDim2.new(0, 150, 0, 30)
xpLabel.Position = UDim2.new(0, 10, 0, 40)
xpLabel.BackgroundTransparency = 1
xpLabel.Text = "XP: 0 (Level 1)"
xpLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
xpLabel.TextScaled = true
xpLabel.Font = Enum.Font.SourceSansBold
xpLabel.Parent = hudFrame

-- Menu buttons
local menuFrame = Instance.new("Frame")
menuFrame.Name = "MenuFrame"
menuFrame.Size = UDim2.new(0, 200, 0, 200)
menuFrame.Position = UDim2.new(1, -210, 0, 10)
menuFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
menuFrame.BorderSizePixel = 0
menuFrame.Parent = hudFrame

-- Shop button
local shopButton = Instance.new("TextButton")
shopButton.Name = "ShopButton"
shopButton.Size = UDim2.new(1, -10, 0, 30)
shopButton.Position = UDim2.new(0, 5, 0, 5)
shopButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
shopButton.Text = "Shop"
shopButton.TextColor3 = Color3.white
shopButton.TextScaled = true
shopButton.Font = Enum.Font.SourceSansBold
shopButton.Parent = menuFrame

-- Inventory button
local inventoryButton = Instance.new("TextButton")
inventoryButton.Name = "InventoryButton"
inventoryButton.Size = UDim2.new(1, -10, 0, 30)
inventoryButton.Position = UDim2.new(0, 5, 0, 40)
inventoryButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
inventoryButton.Text = "Inventory"
inventoryButton.TextColor3 = Color3.white
inventoryButton.TextScaled = true
inventoryButton.Font = Enum.Font.SourceSansBold
inventoryButton.Parent = menuFrame

-- Quests button
local questsButton = Instance.new("TextButton")
questsButton.Name = "QuestsButton"
questsButton.Size = UDim2.new(1, -10, 0, 30)
questsButton.Position = UDim2.new(0, 5, 0, 75)
questsButton.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
questsButton.Text = "Quests"
questsButton.TextColor3 = Color3.white
questsButton.TextScaled = true
questsButton.Font = Enum.Font.SourceSansBold
questsButton.Parent = menuFrame

-- Daily reward button
local dailyButton = Instance.new("TextButton")
dailyButton.Name = "DailyButton"
dailyButton.Size = UDim2.new(1, -10, 0, 30)
dailyButton.Position = UDim2.new(0, 5, 0, 110)
dailyButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
dailyButton.Text = "Daily Reward"
dailyButton.TextColor3 = Color3.black
dailyButton.TextScaled = true
dailyButton.Font = Enum.Font.SourceSansBold
dailyButton.Parent = menuFrame

-- Friends button
local friendsButton = Instance.new("TextButton")
friendsButton.Name = "FriendsButton"
friendsButton.Size = UDim2.new(1, -10, 0, 30)
friendsButton.Position = UDim2.new(0, 5, 0, 145)
friendsButton.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
friendsButton.Text = "Friends"
friendsButton.TextColor3 = Color3.white
friendsButton.TextScaled = true
friendsButton.Font = Enum.Font.SourceSansBold
friendsButton.Parent = menuFrame

-- Garden area
local gardenFrame = Instance.new("Frame")
gardenFrame.Name = "GardenFrame"
gardenFrame.Size = UDim2.new(1, -220, 1, -100)
gardenFrame.Position = UDim2.new(0, 10, 0, 90)
gardenFrame.BackgroundColor3 = Color3.fromRGB(139, 69, 19) -- Brown soil color
gardenFrame.BorderSizePixel = 0
gardenFrame.Parent = mainFrame

-- Garden grid (3x3 to start)
local gardenSize = 3
local plotSize = 0.3 -- 30% of garden frame
local plotSpacing = 0.05 -- 5% spacing

local function createGardenGrid()
    -- Clear existing plots
    for _, child in pairs(gardenFrame:GetChildren()) do
        if child.Name:find("Plot") then
            child:Destroy()
        end
    end
    
    for x = 1, gardenSize do
        for y = 1, gardenSize do
            local plot = Instance.new("TextButton")
            plot.Name = "Plot_" .. x .. "_" .. y
            plot.Size = UDim2.new(plotSize, 0, plotSize, 0)
            plot.Position = UDim2.new(
                (x - 1) * (plotSize + plotSpacing) + plotSpacing,
                0,
                (y - 1) * (plotSize + plotSpacing) + plotSpacing,
                0
            )
            plot.BackgroundColor3 = Color3.fromRGB(101, 67, 33) -- Darker brown
            plot.BorderSizePixel = 1
            plot.BorderColor3 = Color3.fromRGB(0, 0, 0)
            plot.Text = ""
            plot.Parent = gardenFrame
            
            -- Plot click handler
            plot.MouseButton1Click:Connect(function()
                onPlotClick(x, y)
            end)
        end
    end
end

-- Plot click handler
function onPlotClick(x, y)
    local plotKey = x .. "," .. y
    local plotData = gameState.gardenData.plots and gameState.gardenData.plots[plotKey]
    
    if not plotData or plotData.plantType == "" then
        -- Empty plot - show seed selection
        showSeedSelection(x, y)
    elseif plotData.growthStage == "mature" then
        -- Mature plant - harvest it
        remotes.HarvestPlant:FireServer(x, y)
    else
        -- Growing plant - water it
        remotes.WaterPlant:FireServer(x, y)
    end
end

-- Seed selection UI
local seedSelectionFrame = nil

function showSeedSelection(x, y)
    if seedSelectionFrame then
        seedSelectionFrame:Destroy()
    end
    
    seedSelectionFrame = Instance.new("Frame")
    seedSelectionFrame.Name = "SeedSelection"
    seedSelectionFrame.Size = UDim2.new(0, 300, 0, 200)
    seedSelectionFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    seedSelectionFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    seedSelectionFrame.BorderSizePixel = 2
    seedSelectionFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    seedSelectionFrame.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Select Seed (Plot " .. x .. "," .. y .. ")"
    title.TextColor3 = Color3.white
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = seedSelectionFrame
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.white
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.Parent = seedSelectionFrame
    
    closeButton.MouseButton1Click:Connect(function()
        seedSelectionFrame:Destroy()
    end)
    
    -- Show available seeds
    local yOffset = 40
    for seedType, amount in pairs(gameState.inventory.seeds or {}) do
        if amount > 0 then
            local seedButton = Instance.new("TextButton")
            seedButton.Name = seedType .. "Button"
            seedButton.Size = UDim2.new(1, -20, 0, 25)
            seedButton.Position = UDim2.new(0, 10, 0, yOffset)
            seedButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            seedButton.Text = seedType:gsub("^%l", string.upper) .. " (" .. amount .. ")"
            seedButton.TextColor3 = Color3.white
            seedButton.TextScaled = true
            seedButton.Font = Enum.Font.SourceSans
            seedButton.Parent = seedSelectionFrame
            
            seedButton.MouseButton1Click:Connect(function()
                remotes.PlantSeed:FireServer(x, y, seedType)
                seedSelectionFrame:Destroy()
            end)
            
            yOffset = yOffset + 30
        end
    end
end

-- Update garden display
function updateGardenDisplay()
    if not gameState.gardenData.plots then return end
    
    for plotKey, plotData in pairs(gameState.gardenData.plots) do
        local x, y = plotKey:match("(%d+),(%d+)")
        local plot = gardenFrame:FindFirstChild("Plot_" .. x .. "_" .. y)
        
        if plot then
            if plotData.plantType and plotData.plantType ~= "" then
                -- Show plant
                local stageColor = Color3.fromRGB(0, 100, 0) -- Green for growing
                if plotData.growthStage == "mature" then
                    stageColor = Color3.fromRGB(255, 165, 0) -- Orange for mature
                elseif plotData.growthStage == "sprout" then
                    stageColor = Color3.fromRGB(0, 150, 0) -- Bright green for sprout
                end
                
                plot.BackgroundColor3 = stageColor
                plot.Text = plotData.plantType:gsub("^%l", string.upper)
                
                if plotData.watered then
                    plot.BorderColor3 = Color3.fromRGB(0, 0, 255) -- Blue border for watered
                else
                    plot.BorderColor3 = Color3.fromRGB(0, 0, 0) -- Black border
                end
            else
                -- Empty plot
                plot.BackgroundColor3 = Color3.fromRGB(101, 67, 33)
                plot.Text = ""
                plot.BorderColor3 = Color3.fromRGB(0, 0, 0)
            end
        end
    end
end

-- Update HUD
function updateHUD()
    coinsLabel.Text = "Coins: " .. (gameState.inventory.coins or 0)
    xpLabel.Text = "XP: " .. (gameState.inventory.xp or 0) .. " (Level " .. (gameState.inventory.level or 1) .. ")"
end

-- Handle RemoteEvents
remotes.GetGardenData.OnClientEvent:Connect(function(gardenData)
    gameState.gardenData = gardenData
    gardenSize = gardenData.size or 3
    createGardenGrid()
    updateGardenDisplay()
end)

remotes.GetInventory.OnClientEvent:Connect(function(inventory)
    gameState.inventory = inventory
    updateHUD()
end)

-- Handle shop data
remotes.GetShopData.OnClientEvent:Connect(function(shopData)
    gameState.shopData = shopData
end)

-- Handle quest data
remotes.GetQuestData.OnClientEvent:Connect(function(questData)
    gameState.questData = questData
end)

-- Handle daily reward data
remotes.ClaimDailyReward.OnClientEvent:Connect(function(success, message, rewardData)
    if success and rewardData then
        gameState.dailyRewardData = rewardData
    end
end)

-- Handle friend data
remotes.GetFriendList.OnClientEvent:Connect(function(friendData)
    gameState.friendData = friendData
end)

-- Initialize
createGardenGrid()

-- Request initial data
remotes.GetGardenData:FireServer()
remotes.GetInventory:FireServer()

print("ClientManager loaded successfully!")