-- UIConnector.lua
-- Connects all UI components and handles button clicks

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for UI modules to load
repeat wait() until _G.ShopUI and _G.InventoryUI and _G.QuestUI and _G.DailyRewardUI

local ShopUI = _G.ShopUI
local InventoryUI = _G.InventoryUI
local QuestUI = _G.QuestUI
local DailyRewardUI = _G.DailyRewardUI

-- Wait for main UI to load
local screenGui = playerGui:WaitForChild("GardenGameUI")
local mainFrame = screenGui:WaitForChild("MainFrame")
local hudFrame = mainFrame:WaitForChild("HUD")
local menuFrame = hudFrame:WaitForChild("MenuFrame")

-- Get menu buttons
local shopButton = menuFrame:WaitForChild("ShopButton")
local inventoryButton = menuFrame:WaitForChild("InventoryButton")
local questsButton = menuFrame:WaitForChild("QuestsButton")
local dailyButton = menuFrame:WaitForChild("DailyButton")
local friendsButton = menuFrame:WaitForChild("FriendsButton")

-- Button click handlers
shopButton.MouseButton1Click:Connect(function()
    ShopUI.createShopUI()
end)

inventoryButton.MouseButton1Click:Connect(function()
    InventoryUI.createInventoryUI()
end)

questsButton.MouseButton1Click:Connect(function()
    QuestUI.createQuestUI()
end)

dailyButton.MouseButton1Click:Connect(function()
    DailyRewardUI.createDailyRewardUI()
end)

friendsButton.MouseButton1Click:Connect(function()
    -- TODO: Implement friends UI
    print("Friends feature coming soon!")
end)

-- Auto-show daily reward on first login
spawn(function()
    wait(3) -- Wait for everything to load
    DailyRewardUI.createDailyRewardUI()
end)

print("UIConnector loaded successfully!")