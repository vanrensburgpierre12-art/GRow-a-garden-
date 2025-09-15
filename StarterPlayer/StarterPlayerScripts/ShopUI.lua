-- ShopUI.lua
-- Handles shop interface and purchasing

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

-- Shop UI
local shopFrame = nil
local currentShopData = {}

-- Create shop UI
function createShopUI()
    if shopFrame then
        shopFrame:Destroy()
    end
    
    shopFrame = Instance.new("Frame")
    shopFrame.Name = "ShopFrame"
    shopFrame.Size = UDim2.new(0, 800, 0, 600)
    shopFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
    shopFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    shopFrame.BorderSizePixel = 2
    shopFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    shopFrame.Parent = playerGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    title.BorderSizePixel = 0
    title.Text = "Garden Shop"
    title.TextColor3 = Color3.white
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = shopFrame
    
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
    closeButton.Parent = shopFrame
    
    closeButton.MouseButton1Click:Connect(function()
        shopFrame:Destroy()
    end)
    
    -- Category tabs
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = "TabFrame"
    tabFrame.Size = UDim2.new(1, 0, 0, 40)
    tabFrame.Position = UDim2.new(0, 0, 0, 50)
    tabFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tabFrame.BorderSizePixel = 0
    tabFrame.Parent = shopFrame
    
    local categories = {"seeds", "tools", "decorations", "upgrades"}
    local categoryButtons = {}
    
    for i, category in pairs(categories) do
        local tabButton = Instance.new("TextButton")
        tabButton.Name = category .. "Tab"
        tabButton.Size = UDim2.new(1 / #categories, 0, 1, 0)
        tabButton.Position = UDim2.new((i - 1) / #categories, 0, 0, 0)
        tabButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        tabButton.Text = category:gsub("^%l", string.upper)
        tabButton.TextColor3 = Color3.white
        tabButton.TextScaled = true
        tabButton.Font = Enum.Font.SourceSans
        tabButton.Parent = tabFrame
        
        tabButton.MouseButton1Click:Connect(function()
            selectCategory(category)
        end)
        
        categoryButtons[category] = tabButton
    end
    
    -- Items frame
    local itemsFrame = Instance.new("ScrollingFrame")
    itemsFrame.Name = "ItemsFrame"
    itemsFrame.Size = UDim2.new(1, -20, 1, -100)
    itemsFrame.Position = UDim2.new(0, 10, 0, 100)
    itemsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    itemsFrame.BorderSizePixel = 1
    itemsFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    itemsFrame.ScrollBarThickness = 10
    itemsFrame.Parent = shopFrame
    
    -- Store references
    shopFrame:SetAttribute("CategoryButtons", categoryButtons)
    shopFrame:SetAttribute("ItemsFrame", itemsFrame)
    
    -- Load shop data
    remotes.GetShopData:FireServer()
end

-- Select category
function selectCategory(category)
    local categoryButtons = shopFrame:GetAttribute("CategoryButtons")
    local itemsFrame = shopFrame:GetAttribute("ItemsFrame")
    
    -- Update tab colors
    for cat, button in pairs(categoryButtons) do
        if cat == category then
            button.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        else
            button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end
    
    -- Clear items
    for _, child in pairs(itemsFrame:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
    
    -- Show items for category
    local items = currentShopData[category] or {}
    local yOffset = 0
    
    for _, item in pairs(items) do
        local itemFrame = Instance.new("Frame")
        itemFrame.Name = item.id .. "Item"
        itemFrame.Size = UDim2.new(1, -10, 0, 80)
        itemFrame.Position = UDim2.new(0, 5, 0, yOffset)
        itemFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        itemFrame.BorderSizePixel = 1
        itemFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
        itemFrame.Parent = itemsFrame
        
        -- Item name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(0.6, 0, 0, 25)
        nameLabel.Position = UDim2.new(0, 10, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = item.name
        nameLabel.TextColor3 = Color3.white
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Parent = itemFrame
        
        -- Item description
        local descLabel = Instance.new("TextLabel")
        descLabel.Name = "DescLabel"
        descLabel.Size = UDim2.new(0.6, 0, 0, 20)
        descLabel.Position = UDim2.new(0, 10, 0, 30)
        descLabel.BackgroundTransparency = 1
        descLabel.Text = item.description
        descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextScaled = true
        descLabel.Font = Enum.Font.SourceSans
        descLabel.Parent = itemFrame
        
        -- Price
        local priceLabel = Instance.new("TextLabel")
        priceLabel.Name = "PriceLabel"
        priceLabel.Size = UDim2.new(0, 100, 0, 25)
        priceLabel.Position = UDim2.new(0.6, 10, 0, 5)
        priceLabel.BackgroundTransparency = 1
        priceLabel.Text = item.price .. " coins"
        priceLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
        priceLabel.TextScaled = true
        priceLabel.Font = Enum.Font.SourceSansBold
        priceLabel.Parent = itemFrame
        
        -- Buy button
        local buyButton = Instance.new("TextButton")
        buyButton.Name = "BuyButton"
        buyButton.Size = UDim2.new(0, 80, 0, 30)
        buyButton.Position = UDim2.new(0.6, 10, 0, 35)
        buyButton.BackgroundColor3 = item.canAfford and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 100, 100)
        buyButton.Text = item.owned and "Owned" or "Buy"
        buyButton.TextColor3 = Color3.white
        buyButton.TextScaled = true
        buyButton.Font = Enum.Font.SourceSansBold
        buyButton.Parent = itemFrame
        
        if not item.owned and item.canAfford then
            buyButton.MouseButton1Click:Connect(function()
                remotes.BuyItem:FireServer(category, item.id)
            end)
        end
        
        yOffset = yOffset + 85
    end
    
    -- Update canvas size
    itemsFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Handle RemoteEvents
remotes.GetShopData.OnClientEvent:Connect(function(shopData)
    currentShopData = shopData
    if shopFrame then
        selectCategory("seeds") -- Default to seeds tab
    end
end)

remotes.BuyItem.OnClientEvent:Connect(function(success, message)
    if success then
        print("Purchase successful: " .. message)
        -- Refresh shop data
        remotes.GetShopData:FireServer()
    else
        print("Purchase failed: " .. message)
    end
end)

-- Export function for other scripts
_G.ShopUI = {
    createShopUI = createShopUI
}

print("ShopUI loaded successfully!")