# Coastal Cards — Agent Context

## Project Overview
Coastal Cards is a cozy tarot card reading game where you play as a novice witch building a tarot business in the coastal city of Coralhaven.

## Web PWA Migration (March 2026)
The game has been migrated from Godot to a **vanilla JS/DOM PWA** for web/mobile deployment.

### Architecture
- **index.html** — Single-page app shell with all screens/overlays defined in markup
- **style.css** — Full responsive CSS with Cinzel/Quicksand fonts, CSS 3D card flips, particle animations, landscape-first layout
- **game.js** — Complete game engine in a single IIFE (~43KB):
  - Data loading from `data/*.json` files
  - Full 78-card tarot deck (22 major arcana from data, 56 minor arcana generated)
  - Character creation (3 pages: identity, appearance, outfit)
  - Opening sequence with typewriter dialogue
  - Game HUD with date, moon phase, location, money, energy
  - Calendar system starting March 1, 29.5-day lunar cycle
  - 6 locations with permit system
  - Tarot reading with 3-card spread, CSS 3D flip, sparkle effects
  - Economy: $25 start, $700 rent, reading income based on reputation/moon/holiday
  - Croneslist broom marketplace with time-limited listings
  - Compact mirror with messages, croneslist, styling, save/load tabs
  - Energy system (100 max, readings cost 20, rest recovers 40)
  - Time-of-day progression (morning→afternoon→evening→night)
  - Achievement system from data/achievements.json
  - Save/load to localStorage
- **sw.js** — Service worker for offline caching
- **manifest.json** — PWA manifest for installability

### Data Files (in `data/`)
All 11 JSON files are loaded at startup and drive game content:
- `tarot_deck.json` — 22 major arcana cards (minor arcana generated in code)
- `economy.json` — Prices, rent, reading income, permits
- `holiday_effects.json` — 7 holidays with gameplay effects
- `lunar_effects.json` — 8 moon phases + special moons
- `achievements.json` — 15 achievements + statistics tracking
- `complete_broom_catalog.json` — Broom catalog across 4 tiers
- `croneslist_notifications.json` — Alert templates and seller names
- `dialogue_examples.json` — Client reactions, NPC dialogue with pronoun templates
- `broom_lore.json`, `broom_selling_emotions.json`, `premium_broom_economy.json`

### Key Design Decisions
- **No build step** — Pure vanilla JS, no frameworks, no bundler
- **Landscape-first** — Portrait shows rotation prompt
- **Pronoun system** — she/he/they/custom with template replacement
- **Offline-first** — Service worker caches all assets
- **Mobile PWA** — Installable, no app store needed

### Godot Files (preserved)
The original Godot project files remain in the repo for reference:
- `scripts/systems/*.gd` — Game logic reference
- `scripts/ui/*.gd` — UI logic reference
- `assets/sprites/*` — Sprite assets
- `project.godot`, `*.tscn` — Godot project files
