-- ShopManager.lua
-- Handles shop functionality, item purchasing, and inventory management

-- Wait for GameManager to load
repeat wait() until _G.GameManager

local GameManager = _G.GameManager
local remotes = GameManager.remotes

-- Shop item configuration
local ShopItems = {
    -- Seeds
    seeds = {
        carrot = {
            name = "Carrot Seeds",
            price = 5,
            description = "Basic vegetable, grows quickly",
            category = "vegetables",
            unlockLevel = 1
        },
        tomato = {
            name = "Tomato Seeds", 
            price = 10,
            description = "Juicy red tomatoes",
            category = "vegetables",
            unlockLevel = 1
        },
        sunflower = {
            name = "Sunflower Seeds",
            price = 20,
            description = "Beautiful yellow flowers",
            category = "flowers",
            unlockLevel = 3
        },
        pumpkin = {
            name = "Pumpkin Seeds",
            price = 35,
            description = "Large orange pumpkins",
            category = "vegetables", 
            unlockLevel = 5
        },
        goldenRose = {
            name = "Golden Rose Seeds",
            price = 100,
            description = "Rare golden roses",
            category = "rare",
            unlockLevel = 10
        },
        rainbowFlower = {
            name = "Rainbow Flower Seeds",
            price = 200,
            description = "Mystical rainbow flowers",
            category = "rare",
            unlockLevel = 15
        }
    },
    
    -- Tools
    tools = {
        wateringCan = {
            name = "Watering Can",
            price = 50,
            description = "Water plants for growth bonus",
            category = "tools",
            unlockLevel = 2
        },
        fertilizer = {
            name = "Fertilizer",
            price = 25,
            description = "One-time growth speed boost",
            category = "tools",
            unlockLevel = 4
        },
        shovel = {
            name = "Shovel",
            price = 100,
            description = "Remove plants instantly",
            category = "tools",
            unlockLevel = 6
        }
    },
    
    -- Decorations
    decorations = {
        fence = {
            name = "Garden Fence",
            price = 15,
            description = "Decorative garden border",
            category = "decoration",
            unlockLevel = 2
        },
        fountain = {
            name = "Water Fountain",
            price = 75,
            description = "Beautiful centerpiece",
            category = "decoration",
            unlockLevel = 8
        },
        path = {
            name = "Stone Path",
            price = 10,
            description = "Decorative walkway",
            category = "decoration",
            unlockLevel = 3
        },
        statue = {
            name = "Garden Statue",
            price = 150,
            description = "Elegant garden statue",
            category = "decoration",
            unlockLevel = 12
        }
    },
    
    -- Land upgrades
    upgrades = {
        landExpansion = {
            name = "Land Expansion",
            price = 100,
            description = "Expand your garden by 1x1",
            category = "upgrade",
            unlockLevel = 3,
            maxPurchases = 7 -- Can buy 7 times (3x3 to 10x10)
        }
    }
}

-- Get shop data for player
local function getShopData(player)
    local data = GameManager.getPlayerData(player)
    local shopData = {
        seeds = {},
        tools = {},
        decorations = {},
        upgrades = {}
    }
    
    -- Filter items based on player level and availability
    for category, items in pairs(ShopItems) do
        for itemId, itemData in pairs(items) do
            if data.level >= itemData.unlockLevel then
                local item = {
                    id = itemId,
                    name = itemData.name,
                    price = itemData.price,
                    description = itemData.description,
                    category = itemData.category,
                    owned = false,
                    canAfford = data.coins >= itemData.price
                }
                
                -- Check if player owns the item
                if category == "seeds" then
                    item.owned = data.inventory.seeds[itemId] and data.inventory.seeds[itemId] > 0
                elseif category == "tools" then
                    item.owned = data.inventory.tools and data.inventory.tools[itemId]
                elseif category == "decorations" then
                    item.owned = data.inventory.decorations[itemId] and data.inventory.decorations[itemId] > 0
                elseif category == "upgrades" then
                    item.owned = data.garden.size >= (3 + (itemData.maxPurchases or 0))
                end
                
                table.insert(shopData[category], item)
            end
        end
    end
    
    return shopData
end

-- Purchase item
local function purchaseItem(player, itemType, itemId)
    local data = GameManager.getPlayerData(player)
    local itemData = ShopItems[itemType] and ShopItems[itemType][itemId]
    
    if not itemData then
        return false, "Item not found"
    end
    
    -- Check level requirement
    if data.level < itemData.unlockLevel then
        return false, "Level requirement not met"
    end
    
    -- Check if player can afford it
    if data.coins < itemData.price then
        return false, "Not enough coins"
    end
    
    -- Check upgrade limits
    if itemType == "upgrades" and itemData.maxPurchases then
        local currentSize = data.garden.size
        local maxSize = 3 + itemData.maxPurchases
        if currentSize >= maxSize then
            return false, "Maximum upgrades reached"
        end
    end
    
    -- Deduct coins
    data.coins = data.coins - itemData.price
    
    -- Give item to player
    if itemType == "seeds" then
        if not data.inventory.seeds[itemId] then
            data.inventory.seeds[itemId] = 0
        end
        data.inventory.seeds[itemId] = data.inventory.seeds[itemId] + 1
    elseif itemType == "tools" then
        if not data.inventory.tools then
            data.inventory.tools = {}
        end
        data.inventory.tools[itemId] = true
    elseif itemType == "decorations" then
        if not data.inventory.decorations[itemId] then
            data.inventory.decorations[itemId] = 0
        end
        data.inventory.decorations[itemId] = data.inventory.decorations[itemId] + 1
    elseif itemType == "upgrades" and itemId == "landExpansion" then
        data.garden.size = data.garden.size + 1
    end
    
    -- Give XP for purchase
    data.xp = data.xp + 2
    
    GameManager.savePlayerData(player)
    return true, "Purchase successful"
end

-- Handle RemoteEvents
remotes.GetShopData.OnServerEvent:Connect(function(player)
    local shopData = getShopData(player)
    remotes.GetShopData:FireClient(player, shopData)
end)

remotes.BuyItem.OnServerEvent:Connect(function(player, itemType, itemId)
    local success, message = purchaseItem(player, itemType, itemId)
    remotes.BuyItem:FireClient(player, success, message)
    
    if success then
        -- Send updated shop data
        local shopData = getShopData(player)
        remotes.GetShopData:FireClient(player, shopData)
    end
end)

remotes.GetInventory.OnServerEvent:Connect(function(player)
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
end)

print("ShopManager loaded successfully!")