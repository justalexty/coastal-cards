# Calendar UI Integration Examples

## In-Game Display Locations

### 1. Main HUD (Always Visible)
```
┌─────────────────────────────────────────────────────────┐
│ [Compact] [Inventory]              Mar 1 🌒 🎊  $25 ⚡85 │
└─────────────────────────────────────────────────────────┘
```

### 2. Expanded Calendar (Toggle with 'C' key)
```
┌─────────────────────┐
│  Friday, March 1st  │
│ 🎊 LUNAR NEW YEAR! │
├────────────────────┤
│ 🌒 Waxing Crescent │
│ Rent in 30 days    │
├────────────────────┤
│  « March 2024 »    │
│ Su Mo Tu We Th Fr  │
│              [1] 2 │
│  3  4  5  6  7  8  │
│  9 10 11 12 13 14  │
│ 15 16 17 18 19 20* │ ← * = Spring Equinox
│ 21 22 23 24 25 26  │
│ 27 28 29 30 31*    │ ← * = Int'l Witch Day
└─────────────────────┘
```

### 3. Morning Wake-Up Screen
```
╔═══════════════════════════════════════╗
║          Good Morning!                ║
║                                       ║
║      Friday, March 1st                ║
║    🎊 LUNAR NEW YEAR! 🎊              ║
║                                       ║
║  🌒 Waxing Crescent                   ║
║  Perfect for new beginnings           ║
║                                       ║
║  💰 Cash: $25                         ║
║  🏠 Rent due in 30 days               ║
║                                       ║
║      [Start Your Day]                 ║
╚═══════════════════════════════════════╝
```

### 4. Compact Mirror Messages
```
┌─ Compact Mirror ─────────┐
│ 📅 WitchNet              │
│ "Happy Lunar New Year!   │
│  May fortune smile upon  │
│  your readings! 🧧"      │
├──────────────────────────┤
│ 🌙 Astrology Alert       │
│ "Waxing Crescent tonight.│
│  Set your intentions!"   │
├──────────────────────────┤
│ 💸 Landlord              │
│ "Rent $700 due Apr 1st" │
└──────────────────────────┘
```

### 5. During Tarot Readings
```
Client: "Is tonight special somehow?"
Your energy sparkles with Lunar New Year magic...
[+20% accuracy bonus active]
```

## Dynamic UI Changes

### Seasonal Themes
- **Spring**: Soft pastels, flower accents 🌸
- **Summer**: Bright colors, beach vibes ☀️
- **Autumn**: Warm oranges, falling leaves 🍂
- **Winter**: Cool blues, snow particles ❄️

### Moon Phase Effects
- **New Moon**: UI has deeper shadows
- **Full Moon**: Slight silver glow on edges
- **Eclipse**: Red tint during blood moon

### Holiday Decorations
- **Lunar New Year**: Red lanterns on UI corners
- **Samhain**: Subtle spider webs
- **Solstices**: Sun/moon decorations

## Notification Timings

### Daily Check (9 AM)
- Show date/moon phase
- Holiday announcements
- Weather forecast
- Energy restored message

### Evening (6 PM)
- "Shops closing soon"
- Moon phase reminder
- "X days until rent"

### Special Events
- Full moon rising (8 PM)
- Holiday start (midnight)
- Rent warnings (noon)