-- GameConfig.lua
-- Central configuration file for all game settings

local GameConfig = {
    -- Player starting values
    StartingCoins = 100,
    StartingXP = 0,
    StartingLevel = 1,
    StartingGardenSize = 3,
    MaxGardenSize = 10,
    
    -- XP and leveling
    XPPerLevel = 100,
    XPForPlanting = 5,
    XPForHarvesting = 10,
    XPForWatering = 2,
    XPForPurchasing = 2,
    XPForDailyReward = 25,
    
    -- Growth mechanics
    WateringBonus = 0.1, -- 10% growth speed bonus
    FertilizerBonus = 0.2, -- 20% growth speed bonus
    
    -- Social features
    FriendWateringCoins = 5,
    FriendWateringXP = 5,
    OwnerWateringXP = 3,
    WateringCooldown = 86400, -- 24 hours in seconds
    
    -- Daily rewards
    DailyRewardStreakMultiplier = 0.2, -- 20% bonus per streak day
    MaxDailyStreak = 7,
    
    -- Plant configurations
    Plants = {
        carrot = {
            name = "Carrot",
            growthTime = 300, -- 5 minutes
            value = 10,
            category = "vegetables",
            unlockLevel = 1,
            shopPrice = 5
        },
        tomato = {
            name = "Tomato",
            growthTime = 600, -- 10 minutes
            value = 20,
            category = "vegetables",
            unlockLevel = 1,
            shopPrice = 10
        },
        sunflower = {
            name = "Sunflower",
            growthTime = 900, -- 15 minutes
            value = 30,
            category = "flowers",
            unlockLevel = 3,
            shopPrice = 20
        },
        pumpkin = {
            name = "Pumpkin",
            growthTime = 1200, -- 20 minutes
            value = 50,
            category = "vegetables",
            unlockLevel = 5,
            shopPrice = 35
        },
        goldenRose = {
            name = "Golden Rose",
            growthTime = 1800, -- 30 minutes
            value = 100,
            category = "rare",
            unlockLevel = 10,
            shopPrice = 100
        },
        rainbowFlower = {
            name = "Rainbow Flower",
            growthTime = 2400, -- 40 minutes
            value = 200,
            category = "rare",
            unlockLevel = 15,
            shopPrice = 200
        }
    },
    
    -- Shop items
    ShopItems = {
        seeds = {
            carrot = {price = 5, unlockLevel = 1},
            tomato = {price = 10, unlockLevel = 1},
            sunflower = {price = 20, unlockLevel = 3},
            pumpkin = {price = 35, unlockLevel = 5},
            goldenRose = {price = 100, unlockLevel = 10},
            rainbowFlower = {price = 200, unlockLevel = 15}
        },
        tools = {
            wateringCan = {price = 50, unlockLevel = 2},
            fertilizer = {price = 25, unlockLevel = 4},
            shovel = {price = 100, unlockLevel = 6}
        },
        decorations = {
            fence = {price = 15, unlockLevel = 2},
            fountain = {price = 75, unlockLevel = 8},
            path = {price = 10, unlockLevel = 3},
            statue = {price = 150, unlockLevel = 12}
        },
        upgrades = {
            landExpansion = {price = 100, unlockLevel = 3, maxPurchases = 7}
        }
    },
    
    -- Daily rewards by day
    DailyRewards = {
        [1] = {coins = 50, seeds = {carrot = 2}},
        [2] = {coins = 75, seeds = {tomato = 1}},
        [3] = {coins = 100, seeds = {carrot = 3, tomato = 2}},
        [4] = {coins = 150, seeds = {sunflower = 1}},
        [5] = {coins = 200, seeds = {carrot = 5, tomato = 3}},
        [6] = {coins = 300, seeds = {pumpkin = 1}},
        [7] = {coins = 500, seeds = {goldenRose = 1}}
    },
    
    -- Quest configurations
    Quests = {
        plantCarrots = {
            name = "First Steps",
            description = "Plant 5 carrot seeds",
            type = "plant",
            target = "carrot",
            targetCount = 5,
            reward = {coins = 25, xp = 50},
            unlockLevel = 1
        },
        plantTomatoes = {
            name = "Tomato Time",
            description = "Plant 10 tomato seeds",
            type = "plant",
            target = "tomato",
            targetCount = 10,
            reward = {coins = 50, xp = 100},
            unlockLevel = 2
        },
        harvestCarrots = {
            name = "Harvest Time",
            description = "Harvest 15 carrots",
            type = "harvest",
            target = "carrot",
            targetCount = 15,
            reward = {coins = 75, xp = 100},
            unlockLevel = 1
        },
        waterPlants = {
            name = "Green Thumb",
            description = "Water 25 plants",
            type = "water",
            target = "any",
            targetCount = 25,
            reward = {coins = 50, xp = 75},
            unlockLevel = 2
        },
        reachLevel5 = {
            name = "Growing Strong",
            description = "Reach level 5",
            type = "level",
            target = 5,
            targetCount = 1,
            reward = {coins = 200, xp = 0},
            unlockLevel = 1
        }
    },
    
    -- Achievement configurations
    Achievements = {
        firstPlant = {
            name = "Green Fingers",
            description = "Plant your first seed",
            type = "plant",
            target = "any",
            targetCount = 1,
            reward = {coins = 10, xp = 20}
        },
        firstHarvest = {
            name = "First Harvest",
            description = "Harvest your first plant",
            type = "harvest",
            target = "any",
            targetCount = 1,
            reward = {coins = 15, xp = 25}
        },
        plantMaster = {
            name = "Plant Master",
            description = "Plant 100 seeds total",
            type = "plant",
            target = "any",
            targetCount = 100,
            reward = {coins = 500, xp = 200}
        }
    },
    
    -- UI settings
    UI = {
        GardenPlotSize = 0.3, -- 30% of garden frame
        GardenPlotSpacing = 0.05, -- 5% spacing
        DefaultShopTab = "seeds",
        DefaultInventoryTab = "seeds",
        DefaultQuestTab = "quests"
    },
    
    -- DataStore settings
    DataStore = {
        KeyPrefix = "GardenGame_v1_",
        SaveInterval = 300, -- 5 minutes
        MaxRetries = 3
    }
}

return GameConfig