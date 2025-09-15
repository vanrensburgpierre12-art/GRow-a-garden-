-- MultiplayerManager.lua
-- Handles friend garden visits and social features

-- Wait for GameManager to load
repeat wait() until _G.GameManager

local GameManager = _G.GameManager
local remotes = GameManager.remotes
local Players = game:GetService("Players")

-- Friend watering tracking
local friendWateringData = {} -- {playerId}_{friendId} = {lastWatered = timestamp, plantsWatered = count}

-- Get friend list for player
local function getFriendList(player)
    local data = GameManager.getPlayerData(player)
    return data.friends or {}
end

-- Add friend
local function addFriend(player, friendName)
    local data = GameManager.getPlayerData(player)
    
    if not data.friends then
        data.friends = {}
    end
    
    -- Check if friend is already added
    for _, friend in pairs(data.friends) do
        if friend.name == friendName then
            return false, "Friend already added"
        end
    end
    
    -- Find friend player
    local friendPlayer = Players:FindFirstChild(friendName)
    if not friendPlayer then
        return false, "Player not found"
    end
    
    -- Add friend
    table.insert(data.friends, {
        name = friendName,
        userId = friendPlayer.UserId,
        addedDate = os.time()
    })
    
    GameManager.savePlayerData(player)
    return true, "Friend added successfully"
end

-- Remove friend
local function removeFriend(player, friendName)
    local data = GameManager.getPlayerData(player)
    
    if not data.friends then
        return false, "No friends to remove"
    end
    
    for i, friend in pairs(data.friends) do
        if friend.name == friendName then
            table.remove(data.friends, i)
            GameManager.savePlayerData(player)
            return true, "Friend removed"
        end
    end
    
    return false, "Friend not found"
end

-- Get garden data for visiting
local function getGardenForVisit(player, visitorId)
    local data = GameManager.getPlayerData(player)
    
    -- Check if visitor is a friend
    local isFriend = false
    for _, friend in pairs(data.friends) do
        if friend.userId == visitorId then
            isFriend = true
            break
        end
    end
    
    if not isFriend then
        return nil, "Not a friend"
    end
    
    -- Return garden data (excluding sensitive information)
    local gardenData = {
        plots = data.garden.plots,
        decorations = data.garden.decorations,
        size = data.garden.size,
        ownerName = player.Name
    }
    
    return gardenData, "Success"
end

-- Water friend's plant
local function waterFriendPlant(waterer, gardenOwner, x, y)
    local watererData = GameManager.getPlayerData(waterer)
    local ownerData = GameManager.getPlayerData(gardenOwner)
    
    -- Check if waterer is a friend
    local isFriend = false
    for _, friend in pairs(ownerData.friends) do
        if friend.userId == waterer.UserId then
            isFriend = true
            break
        end
    end
    
    if not isFriend then
        return false, "Not a friend"
    end
    
    -- Check cooldown (once per day per friend)
    local waterKey = waterer.UserId .. "_" .. gardenOwner.UserId
    local lastWatered = friendWateringData[waterKey] and friendWateringData[waterKey].lastWatered or 0
    local timeSinceLastWater = os.time() - lastWatered
    
    if timeSinceLastWater < 86400 then -- 24 hours
        local hoursRemaining = (86400 - timeSinceLastWater) / 3600
        return false, "Can only water once per day. " .. math.floor(hoursRemaining) .. " hours remaining."
    end
    
    -- Check if plant exists and can be watered
    local plotKey = x .. "," .. y
    local plot = ownerData.garden.plots[plotKey]
    
    if not plot or plot.plantType == "" or plot.watered then
        return false, "No plant to water or already watered"
    end
    
    -- Water the plant
    plot.watered = true
    
    -- Give rewards to both players
    watererData.coins = watererData.coins + GameManager.GameConfig.FriendWateringCoins
    watererData.xp = watererData.xp + 5
    
    ownerData.xp = ownerData.xp + 3
    
    -- Update watering data
    friendWateringData[waterKey] = {
        lastWatered = os.time(),
        plantsWatered = (friendWateringData[waterKey] and friendWateringData[waterKey].plantsWatered or 0) + 1
    }
    
    GameManager.savePlayerData(waterer)
    GameManager.savePlayerData(gardenOwner)
    
    return true, "Plant watered! Both players received rewards."
end

-- Get visitable gardens
local function getVisitableGardens(player)
    local data = GameManager.getPlayerData(player)
    local visitableGardens = {}
    
    for _, friend in pairs(data.friends or {}) do
        local friendPlayer = Players:FindFirstChild(friend.name)
        if friendPlayer then
            table.insert(visitableGardens, {
                name = friend.name,
                userId = friend.userId,
                online = true
            })
        else
            table.insert(visitableGardens, {
                name = friend.name,
                userId = friend.userId,
                online = false
            })
        end
    end
    
    return visitableGardens
end

-- Handle RemoteEvents
remotes.VisitGarden.OnServerEvent:Connect(function(player, friendName)
    local friendPlayer = Players:FindFirstChild(friendName)
    if not friendPlayer then
        remotes.VisitGarden:FireClient(player, nil, "Friend not online")
        return
    end
    
    local gardenData, message = getGardenForVisit(friendPlayer, player.UserId)
    remotes.VisitGarden:FireClient(player, gardenData, message)
end)

remotes.WaterFriendPlant.OnServerEvent:Connect(function(player, friendName, x, y)
    local friendPlayer = Players:FindFirstChild(friendName)
    if not friendPlayer then
        remotes.WaterFriendPlant:FireClient(player, false, "Friend not online")
        return
    end
    
    local success, message = waterFriendPlant(player, friendPlayer, x, y)
    remotes.WaterFriendPlant:FireClient(player, success, message)
    
    if success then
        -- Send updated inventory to waterer
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

-- Friend management (you can expand this with a proper friend system)
remotes.AddFriend.OnServerEvent:Connect(function(player, friendName)
    local success, message = addFriend(player, friendName)
    remotes.AddFriend:FireClient(player, success, message)
end)

remotes.RemoveFriend.OnServerEvent:Connect(function(player, friendName)
    local success, message = removeFriend(player, friendName)
    remotes.RemoveFriend:FireClient(player, success, message)
end)

remotes.GetFriendList.OnServerEvent:Connect(function(player)
    local friends = getFriendList(player)
    local visitableGardens = getVisitableGardens(player)
    
    local friendData = {
        friends = friends,
        visitableGardens = visitableGardens
    }
    
    remotes.GetFriendList:FireClient(player, friendData)
end)

print("MultiplayerManager loaded successfully!")