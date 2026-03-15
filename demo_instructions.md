# Coastal Witch Tarot - Demo Instructions

## How to Run the Demo

1. **Open Godot 4.6+**
2. **Import the project** by selecting the `project.godot` file
3. **Press F5** or click the Play button to run

## Demo Features

### Currently Working:
- ✅ Main menu
- ✅ Daily card draw system with effects
- ✅ Calendar system with lunar cycles
- ✅ Studio apartment with basic movement
- ✅ Character movement (WASD/Arrow keys)
- ✅ Simple interactions (E key)
- ✅ Calendar widget (C key to toggle)

### What You'll See:
1. **Main Menu** - Click "New Game" 
2. **Daily Card Scene** - Draw your card for the day
3. **Studio Apartment** - Walk around your tiny home
4. **Calendar Widget** - Shows date, moon phase, days until rent

### Controls:
- **WASD/Arrow Keys** - Move around
- **E** - Interact with objects
- **C** - Toggle calendar visibility

## Known Limitations (Demo)

This is an early demo showing core systems:
- Character creation not implemented yet
- Can't leave apartment (city not built)
- No actual tarot reading gameplay yet
- Croneslist marketplace not accessible
- No save/load functionality

## Files Structure

```
coastal-tarot/
├── scenes/
│   ├── main_menu/ - Title screen
│   ├── ui/ - Daily card, calendar
│   └── locations/ - Apartment
├── scripts/
│   ├── systems/ - Core game systems
│   ├── ui/ - UI controllers
│   └── scenes/ - Scene scripts
└── assets/
    └── ui/ - Theme files
```

## Next Steps

To expand the demo:
1. Add character creation flow
2. Build city map with locations
3. Implement tarot reading mechanics
4. Add Croneslist marketplace UI
5. Create more apartments/locations