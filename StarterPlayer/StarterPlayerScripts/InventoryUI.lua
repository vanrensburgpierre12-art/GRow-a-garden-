-- InventoryUI.lua
-- Handles inventory interface and management

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

-- Inventory UI
local inventoryFrame = nil
local currentInventory = {}

-- Create inventory UI
function createInventoryUI()
    if inventoryFrame then
        inventoryFrame:Destroy()
    end
    
    inventoryFrame = Instance.new("Frame")
    inventoryFrame.Name = "InventoryFrame"
    inventoryFrame.Size = UDim2.new(0, 700, 0, 500)
    inventoryFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
    inventoryFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    inventoryFrame.BorderSizePixel = 2
    inventoryFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    inventoryFrame.Parent = playerGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    title.BorderSizePixel = 0
    title.Text = "Inventory"
    title.TextColor3 = Color3.white
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = inventoryFrame
    
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
    closeButton.Parent = inventoryFrame
    
    closeButton.MouseButton1Click:Connect(function()
        inventoryFrame:Destroy()
    end)
    
    -- Category tabs
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = "TabFrame"
    tabFrame.Size = UDim2.new(1, 0, 0, 40)
    tabFrame.Position = UDim2.new(0, 0, 0, 50)
    tabFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tabFrame.BorderSizePixel = 0
    tabFrame.Parent = inventoryFrame
    
    local categories = {"seeds", "tools", "decorations", "harvested"}
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
    itemsFrame.Parent = inventoryFrame
    
    -- Store references
    inventoryFrame:SetAttribute("CategoryButtons", categoryButtons)
    inventoryFrame:SetAttribute("ItemsFrame", itemsFrame)
    
    -- Load inventory data
    remotes.GetInventory:FireServer()
end

-- Select category
function selectCategory(category)
    local categoryButtons = inventoryFrame:GetAttribute("CategoryButtons")
    local itemsFrame = inventoryFrame:GetAttribute("ItemsFrame")
    
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
    local items = currentInventory[category] or {}
    local yOffset = 0
    
    if category == "seeds" then
        for seedType, amount in pairs(items) do
            if amount > 0 then
                createItemFrame(itemsFrame, seedType, amount, "Seeds", yOffset)
                yOffset = yOffset + 60
            end
        end
    elseif category == "tools" then
        for toolType, owned in pairs(items) do
            if owned then
                createItemFrame(itemsFrame, toolType, 1, "Tools", yOffset)
                yOffset = yOffset + 60
            end
        end
    elseif category == "decorations" then
        for decoType, amount in pairs(items) do
            if amount > 0 then
                createItemFrame(itemsFrame, decoType, amount, "Decorations", yOffset)
                yOffset = yOffset + 60
            end
        end
    elseif category == "harvested" then
        for cropType, amount in pairs(items) do
            if amount > 0 then
                createItemFrame(itemsFrame, cropType, amount, "Harvested Crops", yOffset)
                yOffset = yOffset + 60
            end
        end
    end
    
    -- Update canvas size
    itemsFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Create item frame
function createItemFrame(parent, itemName, amount, category, yOffset)
    local itemFrame = Instance.new("Frame")
    itemFrame.Name = itemName .. "Item"
    itemFrame.Size = UDim2.new(1, -10, 0, 50)
    itemFrame.Position = UDim2.new(0, 5, 0, yOffset)
    itemFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    itemFrame.BorderSizePixel = 1
    itemFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    itemFrame.Parent = parent
    
    -- Item name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
    nameLabel.Position = UDim2.new(0, 10, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = itemName:gsub("^%l", string.upper)
    nameLabel.TextColor3 = Color3.white
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.Parent = itemFrame
    
    -- Amount
    local amountLabel = Instance.new("TextLabel")
    amountLabel.Name = "AmountLabel"
    amountLabel.Size = UDim2.new(0.3, 0, 1, 0)
    amountLabel.Position = UDim2.new(0.6, 0, 0, 0)
    amountLabel.BackgroundTransparency = 1
    amountLabel.Text = "x" .. amount
    amountLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    amountLabel.TextScaled = true
    amountLabel.Font = Enum.Font.SourceSansBold
    amountLabel.Parent = itemFrame
    
    -- Category indicator
    local categoryLabel = Instance.new("TextLabel")
    categoryLabel.Name = "CategoryLabel"
    categoryLabel.Size = UDim2.new(0.1, 0, 0, 20)
    categoryLabel.Position = UDim2.new(0, 5, 0, 5)
    categoryLabel.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    categoryLabel.Text = category:sub(1, 1)
    categoryLabel.TextColor3 = Color3.white
    categoryLabel.TextScaled = true
    categoryLabel.Font = Enum.Font.SourceSansBold
    categoryLabel.Parent = itemFrame
end

-- Handle RemoteEvents
remotes.GetInventory.OnClientEvent:Connect(function(inventory)
    currentInventory = inventory
    if inventoryFrame then
        selectCategory("seeds") -- Default to seeds tab
    end
end)

-- Export function for other scripts
_G.InventoryUI = {
    createInventoryUI = createInventoryUI
}

print("InventoryUI loaded successfully!")