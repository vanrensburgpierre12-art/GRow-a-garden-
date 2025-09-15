# Grow a Garden 2.0 - Complete Roblox Farming Game

A fully-featured Roblox farming simulation game with comprehensive player retention systems, social features, and engaging progression mechanics.

## 🎮 Game Features

### Core Gameplay
- **🌱 Planting & Growth System**: Plant seeds that grow through timed stages (seed → sprout → mature)
- **💰 Harvesting & Economy**: Harvest mature plants for coins with varying values per crop type
- **🛒 Shop & Inventory**: Purchase seeds, tools, decorations, and land expansions
- **⭐ XP & Leveling**: Gain experience and level up to unlock new content and features
- **💾 Data Persistence**: All progress automatically saved using Roblox DataStores

### Player Retention Hooks
- **🎁 Daily Rewards**: Login daily for free seeds, coins, and streak bonuses (7-day cycle)
- **📋 Quests & Achievements**: Complete tasks for XP, coins, and unique rewards
- **🌟 Rare Plants**: Special seeds with higher value and unique appearances
- **👥 Social Features**: Visit friends' gardens and water their plants for mutual rewards
- **🎨 Garden Customization**: Decorate with fences, fountains, paths, and statues
- **📈 Progression Loop**: Expand from 3x3 to 10x10 garden with decorations

### Advanced Features
- **⏰ Real-time Growth**: Plants grow automatically with visual stage progression
- **💧 Watering System**: Water plants for 10% growth speed bonus
- **🌿 Fertilizer**: One-time 20% growth speed boost
- **🏆 Achievement System**: Unlock permanent rewards and track statistics
- **👫 Friend System**: Add friends, visit their gardens, and help each other
- **📊 Statistics Tracking**: Monitor total plants, harvests, coins earned, and more

## 🚀 Quick Start Guide

### Method 1: Direct File Import (Recommended)
1. **Download all files** from this repository
2. **Open Roblox Studio** and create a new place
3. **Copy the files** to the correct locations:
   - ServerScriptService files → `ServerScriptService/`
   - StarterPlayer files → `StarterPlayer/StarterPlayerScripts/`
4. **Configure DataStores** (see DataStore Configuration below)
5. **Test in Studio** and publish to Roblox

### Method 2: Manual Setup
Follow the detailed setup instructions below.

## 📁 Complete File Structure

```
Your Roblox Place/
├── ServerScriptService/
│   ├── GameConfig.lua           # Game configuration and settings
│   ├── DataStoreManager.lua     # Data persistence and saving
│   ├── GameManager.lua          # Main game logic and coordination
│   ├── PlantGrowthManager.lua   # Plant growth timers and stages
│   ├── ShopManager.lua          # Shop system and purchasing
│   ├── QuestManager.lua         # Quests and achievements
│   ├── DailyRewardManager.lua   # Daily login rewards
│   └── MultiplayerManager.lua   # Friend system and social features
└── StarterPlayer/
    └── StarterPlayerScripts/
        ├── ClientManager.lua    # Main client UI and garden interaction
        ├── ShopUI.lua           # Shop interface
        ├── InventoryUI.lua      # Inventory management
        ├── QuestUI.lua          # Quests and achievements UI
        ├── DailyRewardUI.lua    # Daily rewards interface
        ├── FriendsUI.lua        # Friend management and garden visits
        └── UIConnector.lua      # UI button connections
```

## ⚙️ Setup Instructions

### Step 1: Roblox Studio Setup
1. **Create a new Roblox Studio place**
2. **Set up the folder structure** as shown above
3. **Copy all script files** to their respective locations
4. **Ensure proper naming** - file names must match exactly

### Step 2: DataStore Configuration
1. In Roblox Studio, go to **Game Settings** → **Security**
2. Enable **"Allow HTTP Requests"**
3. Enable **"Allow Studio Access to API Services"**
4. The game will automatically create DataStores with prefix `"GardenGame_v1_"`

### Step 3: Game Settings
1. **Set up proper permissions** for DataStores
2. **Configure team settings** if needed
3. **Set up proper lighting** for the garden area
4. **Add spawn location** for players

### Step 4: Testing
1. **Test in Studio** with multiple players
2. **Verify DataStore saving** by logging out and back in
3. **Check all UI elements** work correctly
4. **Test multiplayer features** with friends

## 🎯 How to Play

### Getting Started
1. **Spawn into the game** - you'll start with 100 coins and basic seeds
2. **Click on empty soil plots** to plant seeds
3. **Wait for plants to grow** through seed → sprout → mature stages
4. **Harvest mature plants** for coins and XP
5. **Use the Shop** to buy more seeds, tools, and decorations

### Core Mechanics
- **Planting**: Click empty plots, select seed type, plant grows automatically
- **Watering**: Click growing plants to water them for 10% growth speed bonus
- **Harvesting**: Click mature plants (orange) to harvest for coins
- **Shopping**: Use coins to buy seeds, tools, decorations, and land expansions
- **Leveling**: Gain XP from all actions to level up and unlock new content

### Advanced Features
- **Daily Rewards**: Login daily for free rewards and streak bonuses
- **Quests**: Complete tasks for extra coins and XP
- **Friends**: Add friends and visit their gardens
- **Decorations**: Customize your garden with fences, fountains, and more
- **Land Expansion**: Grow your garden from 3x3 to 10x10 plots

## 🛠️ Customization Guide

### Adding New Plants
Edit `GameConfig.lua` to add new plant types:
```lua
newPlant = {
    name = "Plant Name",
    growthTime = 600, -- seconds
    value = 50, -- coins when harvested
    category = "vegetables",
    unlockLevel = 5,
    shopPrice = 25
}
```

### Adding New Quests
Add quest definitions to the `Quests` table in `GameConfig.lua`:
```lua
newQuest = {
    name = "Quest Name",
    description = "Quest description",
    type = "plant", -- or "harvest", "water", "level"
    target = "plantType",
    targetCount = 10,
    reward = {coins = 100, xp = 50},
    unlockLevel = 3
}
```

### Modifying Rewards
All reward values can be adjusted in `GameConfig.lua`:
- XP amounts for different actions
- Coin values for plants and quests
- Daily reward amounts
- Shop item prices
- Growth time multipliers

## 🔧 Troubleshooting

### Common Issues

#### Data Not Saving
- **Check DataStore permissions** in Game Settings → Security
- **Verify API access** is enabled
- **Check console** for DataStore error messages
- **Test with a fresh place** to isolate issues

#### UI Not Showing
- **Verify all scripts** are in correct locations
- **Check for script errors** in the console
- **Ensure RemoteEvents** are created properly
- **Test with multiple players** to verify client-server communication

#### Plants Not Growing
- **Check PlantGrowthManager** is running
- **Verify growth timers** are working
- **Check for script errors** in console
- **Test with different plant types**

#### Shop Not Working
- **Verify ShopManager** and GameManager are loaded
- **Check player data** is loading correctly
- **Verify RemoteEvents** are connected
- **Test with different items**

#### Multiplayer Features Not Working
- **Check friend system** is properly set up
- **Verify player data** includes friend lists
- **Test with multiple players** online
- **Check RemoteEvents** for social features

### Debug Mode
Enable debug prints by setting `DEBUG = true` in GameManager.lua

### Performance Issues
- **Check for memory leaks** in growth timers
- **Optimize DataStore calls** frequency
- **Monitor script performance** in Studio
- **Test with multiple players** for load testing

## 📊 Game Statistics

The game tracks comprehensive statistics:
- Total plants planted
- Total plants harvested
- Total coins earned
- Total XP gained
- Play time tracking
- Achievement progress

## 🔮 Future Enhancements

Potential features to add:
- **Weather System**: Weather affects plant growth
- **Seasonal Events**: Limited-time plants and decorations
- **Garden Competitions**: Leaderboards and contests
- **More Decoration Types**: Themed garden sets
- **Advanced Tools**: Automation and efficiency tools
- **Pet System**: Garden assistants and helpers
- **Trading System**: Player-to-player item trading
- **Guild System**: Group gardening and cooperation

## 📞 Support

### Getting Help
1. **Check the troubleshooting section** above
2. **Verify all scripts** are properly placed
3. **Test in a fresh Roblox Studio place**
4. **Check Roblox Developer Console** for errors
5. **Review the code comments** for implementation details

### Reporting Issues
When reporting issues, include:
- **Roblox Studio version**
- **Error messages** from console
- **Steps to reproduce** the problem
- **Screenshots** if applicable
- **Player count** when issue occurs

## 📝 License

This is a complete, production-ready Roblox game. All scripts are properly commented and organized for easy modification and expansion. Feel free to use, modify, and distribute according to your needs.

---

**🎮 Ready to start farming? Follow the setup instructions and enjoy your new Roblox farming game!**