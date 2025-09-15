-- FriendsUI.lua
-- Handles friend management and garden visiting interface

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

-- Friends UI
local friendsFrame = nil
local currentFriendData = {}
local visitingGarden = nil

-- Create friends UI
function createFriendsUI()
    if friendsFrame then
        friendsFrame:Destroy()
    end
    
    friendsFrame = Instance.new("Frame")
    friendsFrame.Name = "FriendsFrame"
    friendsFrame.Size = UDim2.new(0, 800, 0, 600)
    friendsFrame.Position = UDim2.new(0.5, -400, 0.5, -300)
    friendsFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    friendsFrame.BorderSizePixel = 2
    friendsFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
    friendsFrame.Parent = playerGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    title.BorderSizePixel = 0
    title.Text = "Friends & Garden Visits"
    title.TextColor3 = Color3.white
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = friendsFrame
    
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
    closeButton.Parent = friendsFrame
    
    closeButton.MouseButton1Click:Connect(function()
        friendsFrame:Destroy()
    end)
    
    -- Tab frame
    local tabFrame = Instance.new("Frame")
    tabFrame.Name = "TabFrame"
    tabFrame.Size = UDim2.new(1, 0, 0, 40)
    tabFrame.Position = UDim2.new(0, 0, 0, 50)
    tabFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    tabFrame.BorderSizePixel = 0
    tabFrame.Parent = friendsFrame
    
    -- Friends tab
    local friendsTab = Instance.new("TextButton")
    friendsTab.Name = "FriendsTab"
    friendsTab.Size = UDim2.new(0.5, 0, 1, 0)
    friendsTab.Position = UDim2.new(0, 0, 0, 0)
    friendsTab.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    friendsTab.Text = "Friends"
    friendsTab.TextColor3 = Color3.white
    friendsTab.TextScaled = true
    friendsTab.Font = Enum.Font.SourceSansBold
    friendsTab.Parent = tabFrame
    
    -- Gardens tab
    local gardensTab = Instance.new("TextButton")
    gardensTab.Name = "GardensTab"
    gardensTab.Size = UDim2.new(0.5, 0, 1, 0)
    gardensTab.Position = UDim2.new(0.5, 0, 0, 0)
    gardensTab.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    gardensTab.Text = "Visit Gardens"
    gardensTab.TextColor3 = Color3.white
    gardensTab.TextScaled = true
    gardensTab.Font = Enum.Font.SourceSansBold
    gardensTab.Parent = tabFrame
    
    -- Content frame
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -100)
    contentFrame.Position = UDim2.new(0, 10, 0, 100)
    contentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    contentFrame.BorderSizePixel = 1
    contentFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    contentFrame.ScrollBarThickness = 10
    contentFrame.Parent = friendsFrame
    
    -- Add friend section
    local addFriendFrame = Instance.new("Frame")
    addFriendFrame.Name = "AddFriendFrame"
    addFriendFrame.Size = UDim2.new(1, -10, 0, 60)
    addFriendFrame.Position = UDim2.new(0, 5, 0, 5)
    addFriendFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    addFriendFrame.BorderSizePixel = 1
    addFriendFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
    addFriendFrame.Parent = contentFrame
    
    local addFriendTextBox = Instance.new("TextBox")
    addFriendTextBox.Name = "AddFriendTextBox"
    addFriendTextBox.Size = UDim2.new(0.7, 0, 0, 30)
    addFriendTextBox.Position = UDim2.new(0, 10, 0, 15)
    addFriendTextBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    addFriendTextBox.Text = "Enter friend's username"
    addFriendTextBox.TextColor3 = Color3.white
    addFriendTextBox.TextScaled = true
    addFriendTextBox.Font = Enum.Font.SourceSans
    addFriendTextBox.Parent = addFriendFrame
    
    local addFriendButton = Instance.new("TextButton")
    addFriendButton.Name = "AddFriendButton"
    addFriendButton.Size = UDim2.new(0.25, 0, 0, 30)
    addFriendButton.Position = UDim2.new(0.7, 10, 0, 15)
    addFriendButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    addFriendButton.Text = "Add Friend"
    addFriendButton.TextColor3 = Color3.white
    addFriendButton.TextScaled = true
    addFriendButton.Font = Enum.Font.SourceSansBold
    addFriendButton.Parent = addFriendFrame
    
    addFriendButton.MouseButton1Click:Connect(function()
        local friendName = addFriendTextBox.Text
        if friendName and friendName ~= "" and friendName ~= "Enter friend's username" then
            remotes.AddFriend:FireServer(friendName)
        end
    end)
    
    -- Tab click handlers
    friendsTab.MouseButton1Click:Connect(function()
        selectTab("friends")
    end)
    
    gardensTab.MouseButton1Click:Connect(function()
        selectTab("gardens")
    end)
    
    -- Store references
    friendsFrame:SetAttribute("FriendsTab", friendsTab)
    friendsFrame:SetAttribute("GardensTab", gardensTab)
    friendsFrame:SetAttribute("ContentFrame", contentFrame)
    
    -- Load friend data
    remotes.GetFriendList:FireServer()
end

-- Select tab
function selectTab(tab)
    local friendsTab = friendsFrame:GetAttribute("FriendsTab")
    local gardensTab = friendsFrame:GetAttribute("GardensTab")
    local contentFrame = friendsFrame:GetAttribute("ContentFrame")
    
    -- Update tab colors
    if tab == "friends" then
        friendsTab.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        gardensTab.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        showFriends()
    else
        friendsTab.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        gardensTab.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        showGardens()
    end
end

-- Show friends list
function showFriends()
    local contentFrame = friendsFrame:GetAttribute("ContentFrame")
    
    -- Clear existing friends (keep add friend frame)
    for _, child in pairs(contentFrame:GetChildren()) do
        if child.Name:find("Friend_") then
            child:Destroy()
        end
    end
    
    local friends = currentFriendData.friends or {}
    local yOffset = 70 -- Start after add friend frame
    
    for i, friend in pairs(friends) do
        local friendFrame = Instance.new("Frame")
        friendFrame.Name = "Friend_" .. i
        friendFrame.Size = UDim2.new(1, -10, 0, 50)
        friendFrame.Position = UDim2.new(0, 5, 0, yOffset)
        friendFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        friendFrame.BorderSizePixel = 1
        friendFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
        friendFrame.Parent = contentFrame
        
        -- Friend name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 10, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = friend.name
        nameLabel.TextColor3 = Color3.white
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Parent = friendFrame
        
        -- Remove button
        local removeButton = Instance.new("TextButton")
        removeButton.Name = "RemoveButton"
        removeButton.Size = UDim2.new(0, 80, 0, 30)
        removeButton.Position = UDim2.new(0.6, 10, 0, 10)
        removeButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        removeButton.Text = "Remove"
        removeButton.TextColor3 = Color3.white
        removeButton.TextScaled = true
        removeButton.Font = Enum.Font.SourceSansBold
        removeButton.Parent = friendFrame
        
        removeButton.MouseButton1Click:Connect(function()
            remotes.RemoveFriend:FireServer(friend.name)
        end)
        
        yOffset = yOffset + 55
    end
    
    -- Update canvas size
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Show visitable gardens
function showGardens()
    local contentFrame = friendsFrame:GetAttribute("ContentFrame")
    
    -- Clear existing gardens
    for _, child in pairs(contentFrame:GetChildren()) do
        if child.Name:find("Garden_") then
            child:Destroy()
        end
    end
    
    local gardens = currentFriendData.visitableGardens or {}
    local yOffset = 5
    
    for i, garden in pairs(gardens) do
        local gardenFrame = Instance.new("Frame")
        gardenFrame.Name = "Garden_" .. i
        gardenFrame.Size = UDim2.new(1, -10, 0, 60)
        gardenFrame.Position = UDim2.new(0, 5, 0, yOffset)
        gardenFrame.BackgroundColor3 = garden.online and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(60, 60, 60)
        gardenFrame.BorderSizePixel = 1
        gardenFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
        gardenFrame.Parent = contentFrame
        
        -- Garden name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "NameLabel"
        nameLabel.Size = UDim2.new(0.5, 0, 0, 25)
        nameLabel.Position = UDim2.new(0, 10, 0, 5)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = garden.name
        nameLabel.TextColor3 = Color3.white
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.Parent = gardenFrame
        
        -- Status
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Name = "StatusLabel"
        statusLabel.Size = UDim2.new(0.3, 0, 0, 20)
        statusLabel.Position = UDim2.new(0, 10, 0, 30)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = garden.online and "Online" or "Offline"
        statusLabel.TextColor3 = garden.online and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 200, 200)
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.TextScaled = true
        statusLabel.Font = Enum.Font.SourceSans
        statusLabel.Parent = gardenFrame
        
        -- Visit button
        local visitButton = Instance.new("TextButton")
        visitButton.Name = "VisitButton"
        visitButton.Size = UDim2.new(0, 100, 0, 30)
        visitButton.Position = UDim2.new(0.5, 10, 0, 15)
        visitButton.BackgroundColor3 = garden.online and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(100, 100, 100)
        visitButton.Text = "Visit"
        visitButton.TextColor3 = Color3.white
        visitButton.TextScaled = true
        visitButton.Font = Enum.Font.SourceSansBold
        visitButton.Active = garden.online
        visitButton.Parent = gardenFrame
        
        if garden.online then
            visitButton.MouseButton1Click:Connect(function()
                visitGarden(garden.name)
            end)
        end
        
        yOffset = yOffset + 65
    end
    
    -- Update canvas size
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Visit a friend's garden
function visitGarden(friendName)
    remotes.VisitGarden:FireServer(friendName)
end

-- Create garden visit UI
function createGardenVisitUI(gardenData, ownerName)
    if visitingGarden then
        visitingGarden:Destroy()
    end
    
    visitingGarden = Instance.new("Frame")
    visitingGarden.Name = "GardenVisitFrame"
    visitingGarden.Size = UDim2.new(0, 600, 0, 500)
    visitingGarden.Position = UDim2.new(0.5, -300, 0.5, -250)
    visitingGarden.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    visitingGarden.BorderSizePixel = 2
    visitingGarden.BorderColor3 = Color3.fromRGB(255, 255, 255)
    visitingGarden.Parent = playerGui
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    title.BorderSizePixel = 0
    title.Text = ownerName .. "'s Garden"
    title.TextColor3 = Color3.white
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.Parent = visitingGarden
    
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
    closeButton.Parent = visitingGarden
    
    closeButton.MouseButton1Click:Connect(function()
        visitingGarden:Destroy()
    end)
    
    -- Garden area
    local gardenFrame = Instance.new("Frame")
    gardenFrame.Name = "GardenFrame"
    gardenFrame.Size = UDim2.new(1, -20, 1, -100)
    gardenFrame.Position = UDim2.new(0, 10, 0, 60)
    gardenFrame.BackgroundColor3 = Color3.fromRGB(139, 69, 19) -- Brown soil color
    gardenFrame.BorderSizePixel = 0
    gardenFrame.Parent = visitingGarden
    
    -- Create garden grid
    local gardenSize = gardenData.size or 3
    local plotSize = 0.3
    local plotSpacing = 0.05
    
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
            plot.BackgroundColor3 = Color3.fromRGB(101, 67, 33)
            plot.BorderSizePixel = 1
            plot.BorderColor3 = Color3.fromRGB(0, 0, 0)
            plot.Text = ""
            plot.Parent = gardenFrame
            
            -- Check if there's a plant here
            local plotKey = x .. "," .. y
            local plotData = gardenData.plots[plotKey]
            
            if plotData and plotData.plantType and plotData.plantType ~= "" then
                -- Show plant
                local stageColor = Color3.fromRGB(0, 100, 0)
                if plotData.growthStage == "mature" then
                    stageColor = Color3.fromRGB(255, 165, 0)
                elseif plotData.growthStage == "sprout" then
                    stageColor = Color3.fromRGB(0, 150, 0)
                end
                
                plot.BackgroundColor3 = stageColor
                plot.Text = plotData.plantType:gsub("^%l", string.upper)
                
                if plotData.watered then
                    plot.BorderColor3 = Color3.fromRGB(0, 0, 255)
                end
                
                -- Water button for mature plants
                if plotData.growthStage == "mature" and not plotData.watered then
                    plot.MouseButton1Click:Connect(function()
                        remotes.WaterFriendPlant:FireServer(ownerName, x, y)
                    end)
                end
            end
        end
    end
end

-- Handle RemoteEvents
remotes.GetFriendList.OnClientEvent:Connect(function(friendData)
    currentFriendData = friendData
    if friendsFrame then
        selectTab("friends")
    end
end)

remotes.AddFriend.OnClientEvent:Connect(function(success, message)
    if success then
        print("Friend added: " .. message)
        remotes.GetFriendList:FireServer()
    else
        print("Failed to add friend: " .. message)
    end
end)

remotes.RemoveFriend.OnClientEvent:Connect(function(success, message)
    if success then
        print("Friend removed: " .. message)
        remotes.GetFriendList:FireServer()
    else
        print("Failed to remove friend: " .. message)
    end
end)

remotes.VisitGarden.OnClientEvent:Connect(function(gardenData, message)
    if gardenData then
        createGardenVisitUI(gardenData, gardenData.ownerName)
    else
        print("Failed to visit garden: " .. message)
    end
end)

remotes.WaterFriendPlant.OnClientEvent:Connect(function(success, message)
    if success then
        print("Plant watered: " .. message)
    else
        print("Failed to water plant: " .. message)
    end
end)

-- Export function for other scripts
_G.FriendsUI = {
    createFriendsUI = createFriendsUI
}

print("FriendsUI loaded successfully!")