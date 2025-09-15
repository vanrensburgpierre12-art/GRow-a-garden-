# Grow a Garden 2.0 - Testing Checklist

## ✅ Core Gameplay Tests

### Planting System
- [ ] Click empty plot shows seed selection
- [ ] Can plant different seed types
- [ ] Plants show correct growth stages (seed → sprout → mature)
- [ ] Plants grow automatically over time
- [ ] Growth stages have different colors (green → bright green → orange)

### Harvesting System
- [ ] Can only harvest mature plants (orange)
- [ ] Harvesting gives correct coins and XP
- [ ] Harvested crops are added to inventory
- [ ] Plot becomes empty after harvesting

### Watering System
- [ ] Can water growing plants
- [ ] Watered plants show blue border
- [ ] Watering gives XP
- [ ] Watering provides growth speed bonus

### Shop System
- [ ] Shop opens when clicking Shop button
- [ ] Can browse different categories (seeds, tools, decorations, upgrades)
- [ ] Items show correct prices and descriptions
- [ ] Can purchase items with coins
- [ ] Purchased items appear in inventory
- [ ] Level requirements work correctly

### Inventory System
- [ ] Inventory opens when clicking Inventory button
- [ ] Shows seeds, tools, decorations, and harvested crops
- [ ] Categories work correctly
- [ ] Displays correct quantities

## ✅ Progression Tests

### XP and Leveling
- [ ] Gain XP for planting, harvesting, watering
- [ ] Level up when reaching XP thresholds
- [ ] New level unlocks new content
- [ ] Level display updates correctly

### Quest System
- [ ] Quests open when clicking Quests button
- [ ] Shows available quests and achievements
- [ ] Quest progress updates when completing actions
- [ ] Can complete quests for rewards
- [ ] Achievements unlock correctly

### Daily Rewards
- [ ] Daily rewards open when clicking Daily button
- [ ] Shows current streak and next reward
- [ ] Can claim daily rewards
- [ ] Streak system works correctly
- [ ] Rewards are added to inventory

## ✅ Social Features Tests

### Friend System
- [ ] Friends UI opens when clicking Friends button
- [ ] Can add friends by username
- [ ] Can remove friends
- [ ] Shows online/offline status
- [ ] Can visit friend gardens

### Garden Visiting
- [ ] Can visit online friends' gardens
- [ ] Shows friend's garden layout
- [ ] Can water friend's plants
- [ ] Watering gives rewards to both players
- [ ] Cooldown system works (once per day)

## ✅ Data Persistence Tests

### Saving and Loading
- [ ] Data saves when leaving game
- [ ] Data loads when rejoining
- [ ] Garden layout persists
- [ ] Inventory persists
- [ ] Progress persists
- [ ] Friend list persists

### DataStore Integration
- [ ] No DataStore errors in console
- [ ] Data saves automatically every 5 minutes
- [ ] Retry logic works for failed saves
- [ ] Data migration works for updates

## ✅ UI/UX Tests

### Interface
- [ ] All buttons work correctly
- [ ] UI scales properly on different screen sizes
- [ ] Modals close properly
- [ ] Navigation between screens works
- [ ] Error messages display correctly

### Visual Feedback
- [ ] Plant stages are visually distinct
- [ ] Watered plants show blue border
- [ ] Mature plants are clearly identifiable
- [ ] UI updates in real-time
- [ ] Animations work smoothly

## ✅ Multiplayer Tests

### Multiple Players
- [ ] Multiple players can play simultaneously
- [ ] Each player has independent data
- [ ] Players can visit each other's gardens
- [ ] Social features work between players
- [ ] No data conflicts

### Performance
- [ ] Game runs smoothly with multiple players
- [ ] No memory leaks
- [ ] Growth timers don't conflict
- [ ] DataStore calls are efficient

## ✅ Edge Cases and Error Handling

### Invalid Actions
- [ ] Cannot plant on occupied plots
- [ ] Cannot harvest immature plants
- [ ] Cannot water already watered plants
- [ ] Cannot buy items without enough coins
- [ ] Cannot add invalid usernames as friends

### Error Recovery
- [ ] Game handles DataStore failures gracefully
- [ ] UI doesn't break on errors
- [ ] Players can continue playing after errors
- [ ] Error messages are helpful

## ✅ Configuration Tests

### Game Settings
- [ ] All configurable values work
- [ ] Plant growth times are correct
- [ ] XP rewards are correct
- [ ] Shop prices are correct
- [ ] Daily rewards are correct

### Customization
- [ ] Can modify plant types in config
- [ ] Can modify quests in config
- [ ] Can modify rewards in config
- [ ] Changes take effect without restart

## 🎯 Final Verification

### Complete Gameplay Loop
1. [ ] Start with default resources
2. [ ] Plant seeds and watch them grow
3. [ ] Harvest mature plants for coins
4. [ ] Use coins to buy more seeds and tools
5. [ ] Complete quests for extra rewards
6. [ ] Claim daily rewards
7. [ ] Add friends and visit their gardens
8. [ ] Expand garden size
9. [ ] Decorate garden with items
10. [ ] Level up and unlock new content

### Performance Check
- [ ] Game runs at 60 FPS
- [ ] No script errors in console
- [ ] Memory usage is stable
- [ ] DataStore calls are efficient
- [ ] UI is responsive

## 🚀 Ready for Release

If all tests pass, the game is ready for:
- [ ] Publishing to Roblox
- [ ] Public testing
- [ ] Feature announcements
- [ ] Community feedback

---

**Note**: This checklist ensures the game is fully functional and ready for players. Test thoroughly before releasing!