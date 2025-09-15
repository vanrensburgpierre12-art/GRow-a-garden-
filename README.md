# Grow a Garden 2.0 - Roblox Farming Game

A complete Roblox farming simulation game with unique player retention hooks and engaging progression systems.

## Features

### Core Gameplay
- **Planting & Growth**: Plant seeds that grow through multiple timed stages (seed → sprout → mature)
- **Harvesting & Currency**: Harvest mature plants for coins with different values per crop
- **Shop & Inventory**: Purchase seeds, tools, decorations, and land upgrades
- **XP & Leveling**: Gain experience and level up to unlock new content
- **Data Persistence**: All progress saved using Roblox DataStores

### Player Retention Hooks
- **Daily Rewards**: Login daily for free seeds, coins, and streak bonuses
- **Quests & Achievements**: Complete tasks for XP, coins, and unique rewards
- **Rare/Seasonal Plants**: Special seeds with higher value and unique appearances
- **Multiplayer Interaction**: Visit friends' gardens and water their plants for bonuses
- **Garden Customization**: Decorate with fences, fountains, paths, and statues
- **Progression Loop**: Expand from tiny garden to large, decorated paradise

## Setup Instructions

### 1. Roblox Studio Setup
1. Create a new Roblox Studio place
2. Create the following folder structure in ServerScriptService:
   - GameConfig.lua
   - DataStoreManager.lua
   - GameManager.lua
   - PlantGrowthManager.lua
   - ShopManager.lua
   - QuestManager.lua
   - DailyRewardManager.lua
   - MultiplayerManager.lua

3. Create the following folder structure in StarterPlayer > StarterPlayerScripts:
   - ClientManager.lua
   - ShopUI.lua
   - InventoryUI.lua
   - QuestUI.lua
   - DailyRewardUI.lua
   - UIConnector.lua

### 2. DataStore Configuration
1. In Roblox Studio, go to Game Settings > Security
2. Enable "Allow HTTP Requests" and "Allow Studio Access to API Services"
3. The game will automatically create DataStores with the prefix "GardenGame_v1_"

### 3. UI Setup
The game includes a complete UI system with:
- Top HUD showing coins, XP, and level
- Menu buttons for Shop, Inventory, Quests, Daily Rewards, and Friends
- Interactive garden grid for planting and harvesting
- Modal windows for all game features

### 4. Testing
1. Publish the game to Roblox
2. Test with multiple players to verify multiplayer features
3. Check DataStore saving by logging out and back in
4. Verify all UI elements work correctly

## Game Systems

### Planting System
- Click empty soil plots to select and plant seeds
- Plants grow automatically through timed stages
- Water plants for 10% growth speed bonus
- Use fertilizer for 20% growth speed bonus

### Shop System
- Seeds: Basic vegetables to rare mystical plants
- Tools: Watering cans, fertilizer, shovels
- Decorations: Fences, fountains, paths, statues
- Upgrades: Expand garden size (3x3 to 10x10)

### Quest System
- Planting quests: Plant specific numbers of seeds
- Harvesting quests: Harvest specific crops
- Level quests: Reach certain levels
- Achievement system with permanent unlocks

### Daily Rewards
- 7-day streak system with increasing rewards
- Streak multiplier bonuses
- Special rewards for completing full week streaks

### Social Features
- Add friends to visit their gardens
- Water friend's plants once per day for mutual rewards
- Show off your decorated garden to friends

## Customization

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

## Technical Details

### Data Structure
Player data includes:
- Basic stats (coins, XP, level)
- Inventory (seeds, tools, decorations, harvested crops)
- Garden layout and decorations
- Quest and achievement progress
- Daily reward streak information
- Friend list and social data

### Performance
- Efficient DataStore usage with retry logic
- Client-side UI with server validation
- Optimized growth timers
- Automatic data saving every 5 minutes

### Security
- All game logic runs on server
- Client only handles UI and sends requests
- DataStore operations include error handling
- Input validation on all user actions

## Troubleshooting

### Common Issues
1. **Data not saving**: Check DataStore permissions in Game Settings
2. **UI not showing**: Ensure all scripts are in correct locations
3. **Plants not growing**: Check PlantGrowthManager is running
4. **Shop not working**: Verify ShopManager and GameManager are loaded

### Debug Mode
Enable debug prints by setting `DEBUG = true` in GameManager.lua

## Future Enhancements

Potential features to add:
- Weather system affecting plant growth
- Seasonal events with limited-time plants
- Garden competitions and leaderboards
- More decoration types and themes
- Advanced farming tools and automation
- Pet system for garden assistance

## Support

For issues or questions:
1. Check the troubleshooting section
2. Verify all scripts are properly placed
3. Test in a fresh Roblox Studio place
4. Check Roblox Developer Console for errors

---

**Note**: This is a complete, production-ready Roblox game. All scripts are properly commented and organized for easy modification and expansion.