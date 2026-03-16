# Agent Context - Coastal Witch Tarot

## Project Overview
**Game**: Coastal Witch Tarot  
**Genre**: Cozy simulation / Visual novel  
**Created**: March 14, 2026  
**Repository**: github.com/justalexty/coastal-tarot  
**Development Stage**: Early prototype with core systems

## Game Concept
A broke witch trying to make $700 monthly rent by reading tarot cards in an expensive coastal city. The player starts with only $25 and a broken broom, building up their tarot reading business while managing energy, reputation, and finances.

## Key Features Implemented

### ✅ Daily Card System
- Every morning starts with drawing a personal tarot card
- Cards provide bonuses (never penalties) that affect the whole day
- Full 78-card deck implemented with meanings
- Beautiful flip animation and interpretation display
- Location: `scripts/systems/daily_card_system.gd`

### ✅ Calendar System  
- Game starts March 1st
- Tracks real weekdays, months, lunar cycles
- Rent due on 1st of each month ($700)
- Major holidays: Lunar New Year (biggest!), Equinoxes, Solstices
- Location: `scripts/systems/calendar_system.gd`

### ✅ Character System
- Inclusive character creation with pronouns (she/he/they/custom)
- Body type selection (feminine/neutral/masculine)
- Dynamic text replacement throughout game
- Location: `scripts/systems/pronoun_manager.gd`

### ✅ Economy System
- Starting money: $25
- Rent: $700/month
- Broom prices: $250-5000
- Tips and earnings from tarot readings
- Location: `data/economy.json`

### ✅ Croneslist Marketplace
- Time-based scarcity (listings last 10-40 minutes)
- Used brooms at reduced prices
- Premium brooms appear rarely
- Can sell your broom for rent money (painful choice)
- Notifications optional and OFF by default
- Location: `scripts/systems/croneslist_timer.gd`

## Current Demo State
- Main menu → Daily card draw → Studio apartment
- Basic movement (WASD) and interaction (E)
- Calendar widget shows date/moon/rent countdown
- Can run with `godot project.godot` and press F5

## Architecture Decisions

### Singletons (Autoload)
- GameState - Global game state
- Calendar - Date/time management  
- DailyCardSystem - Morning ritual
- TarotDeck - Card data and drawing
- PronounManager - Text replacement

### Design Philosophy
- **No punishment mechanics** - Cards give information, not penalties
- **Player agency** - Choices matter but aren't moral judgments
- **Contemporary magical realism** - Not derivative fantasy
- **Respectful monetization** - No addiction mechanics

## Next Development Steps
1. **City Map Navigation** - Multiple locations to read tarot
2. **Tarot Reading Gameplay** - The actual card reading mechanics
3. **Client Generation** - Different client types with unique needs
4. **Weather System** - Makes walking without broom difficult
5. **Save/Load System** - Persistence between sessions

## Important Context
- Alex prefers concise responses
- The game should feel cozy and supportive, never punishing
- Lunar New Year is the most important holiday
- All notifications must be opt-in
- Sleep should always restore energy to full
- Brooms removed: Northern Pine, Mountain Pine (redundant)

## Technical Notes
- Godot 4.6+ required
- Target platforms: Web (itch.io), Desktop
- Mobile support planned but not priority
- Art style: Not yet defined, using color blocks

## File Organization
```
/data/ - JSON files for game data
/scenes/ - Godot scene files (.tscn)
/scripts/ - GDScript files
  /systems/ - Core game systems
  /ui/ - UI controllers
  /scenes/ - Scene-specific scripts
/docs/ - Documentation
/tarot-research/ - Complete tarot reference
```

## Contact & Collaboration
- Owner: Alex (@justalexty)
- Agent: clawbuddy (Joseph's AI assistant)
- Update this document when making significant changes
- Other agents: Check this file first before making changes

---
Last Updated: March 15, 2026