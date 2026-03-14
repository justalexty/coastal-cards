# Coastal Witch Tarot - Game Design Document

## Core Concept
A novice witch strikes out on {poss} own to become a great tarot reader. With {poss} old apprentice broom broken and only $25 after paying deposit and first month's rent ($700!), {subj} must build {poss} business from nothing. Starting with a folding table on street corners, every reading counts when you're choosing between food today and saving for next month's rent.

**The Financial Reality:**
- Starting money: $25
- Monthly rent: $700 
- Food: ~$8/day minimum
- Cheapest used broom on Croneslist: $200 (if you can find one!)
- Days until rent: 30

**Our Witch World:**
This is NOT derivative fantasy - it's contemporary magical realism with its own culture:
- Witches are just another profession in this world
- Brooms are practical transportation, made from traditional woods
- Magic is subtle - tarot reading, minor enchantments, everyday conveniences
- WitchNet is their professional network (like LinkedIn for witches)
- Croneslist is their marketplace (not everything needs to be a pun)

## Visual Style
- **Inspiration**: Studio Ghibli, particularly Kiki's Delivery Service and Spirited Away
- **Perspective**: Top-down 2D with depth (¾ view like classic JRPGs)
- **Art Style**: Soft, hand-painted backgrounds with clean character sprites
- **Color Palette**: Warm pastels, sunset oranges/pinks, ocean blues, cozy candlelight

## Core Mechanics

### 1. Magic Compact Mirror
The player's primary interface device:
- **Character Creation/Styling**: Full appearance customization
- **Witch Network**: Receive messages from other witches (quests, tips, lore)
- **Scrying**: Reveal hidden information about clients or locations
- **Quick Save**: In-universe save system

### 2. Location Scouting
Different areas have different client types and permit requirements:
- **Studio Apartment**: Your crappy home base - just a bed and kitchenette, but it's yours
- **Boardwalk**: Tourists, quick readings, high volume (permit-free!)
- **Market Square**: Locals, word-of-mouth potential (requires permit)
- **University District**: Students, complex questions (requires permit)
- **Harbor**: Sailors, merchants, travel-related queries
- **Park**: Families, relationship readings (permit-free!)

### 3. Tarot Reading System
Full 78-card deck with immersive learning:
- **Card Selection**: Client's energy influences which cards appear
- **Interpretation Phase**: Choose between multiple meanings based on context
- **Client Reaction**: Body language and dialogue provide feedback
- **Accuracy System**: Better interpretations = happier clients = more reputation

### 4. Business Management
- **Financial Pressure**: Rent is $700/month (starting with only $25!)
- **Table Setup**: Different cloths, candles, crystals affect client attraction
- **Permits**: Some locations require official permits (mini-quests to obtain)
- **Weather**: Rain/wind affects outdoor locations (no broom to escape!)
- **Time of Day**: Different clients at different times
- **Energy System**: Can only do so many readings before needing rest

### 6. Calendar System (Game starts March 1st)
- **Real Calendar**: Weekdays, months, seasons affect gameplay
- **Lunar Phases**: 29.5 day cycle affects readings and client moods
  - New Moon: New beginnings, intention setting
  - Full Moon: Peak power but exhausting
- **Major Holidays**:
  - **Lunar New Year** (Biggest!): 3 days, +20% accuracy, +50% tips
  - Equinoxes & Solstices: Seasonal bonuses
  - Traditional witch holidays: Samhain, Beltane, etc.
- **Rent Cycle**: Due on the 1st of each month
- **Special Events**: Blue moons, eclipses, meteor showers

### 5. Croneslist (Witch Community Marketplace)
Access through compact mirror's network features:

**Regular Brooms** ($180-280):
- **Time-Based Scarcity**: ~6 posts daily at random times
- **10-40 Minute Windows**: Each listing sells FAST
- **Aesthetic Issues**: Duct tape, bad paint jobs, missing bristles - but they fly!
- **Always Functional**: Ugly but reliable transportation

**Premium Brooms** (Once per week-ish):
- **Moonweave, Stormchaser, etc**: High-end models at 30-50% off retail
- **3-8 Minute Windows**: Sell INSTANTLY (vs 10-40 for regular)
- **$600-2000 Range**: Major savings but need serious cash ready
- **Maximum FOMO**: Missing these hurts 10x more
- **Special Alerts**: Compact glows/pulses (if you enable notifications)

**Notification Settings** (Off by default):
- **Opt-in System**: Choose what you want alerts for
- **Regular Brooms**: Set max price threshold ($220 recommended)
- **Premium Brooms**: Always notify (these are rare!)
- **Custom Searches**: Looking for "Moonweave" specifically? Add it
- **No Spam**: Only buzzes for what YOU want

The Decision Dilemma:
- Buy ugly broom now for $200?
- Or save for premium that might never come when you're online?
- Every day walking = more suffering, but premium could change everything...

**Selling Your Broom** (The Hardest Choice):
- List your broom when desperate for rent money
- Set your price and duration (lower price = sells faster)
- Watch YOUR listing appear among others
- Can cancel before it sells (if you change your mind)
- Selling a premium broom is PAINFUL but sometimes necessary
- "You sold a Moonweave. For RENT. This will haunt you forever."

## Opening Sequence
1. **Train Scene**: Witch on coastal train (cheaper than broken broom)
2. **Arrival**: Steps onto platform with worn suitcase, ocean visible
3. **Compact Moment**: Finds quiet corner, opens standard-issue magic compact
4. **Character Creation**: 
   - Choose name and pronouns
   - Select body type (affects sprite base)
   - Customize appearance (skin, hair, outfit)
5. **First Message**: WitchNet permit warning
6. **City Enter**: Walks into bustling Coralhaven

## Character Progression
- **Reputation Levels**: Unknown → Novice → Known → Respected → Renowned
- **Tarot Mastery**: Track understanding of each card through successful readings
- **Witch Skills**: Unlock scrying clarity, client attraction auras, weather protection
- **Equipment**: Better tables, chairs, decorations, tarot decks

## Art Direction

### Character Sprites
For the Ghibli aesthetic, **custom sprite base** would be better than LPC:
- **Style**: Clean lines, larger heads, expressive faces
- **Size**: 32x48 base (taller than LPC's square proportions)
- **Animations**: Idle breathing, walking, sitting, card shuffling

### Alternative to LPC
1. **Modified Seliel's Sprites**: Free, customizable, more anime-styled
2. **Custom Base Creation**: Design our own base in Aseprite
3. **Mix Approach**: Use LPC for NPCs, custom for main character

### Environment Art
- **Tilesets**: Hand-painted in Aseprite at 32x32
- **Backgrounds**: Larger painted scenes with parallax
- **UI Elements**: Clean, magical, with subtle animations

## Technical Structure

### Godot 4 Project Organization
```
res://
├── scenes/
│   ├── main_menu/
│   ├── game_world/
│   ├── tarot_reading/
│   ├── compact_mirror/
│   └── ui_elements/
├── scripts/
│   ├── player/
│   ├── npcs/
│   ├── tarot/
│   └── systems/
├── assets/
│   ├── sprites/
│   ├── tilesets/
│   ├── ui/
│   ├── cards/
│   └── audio/
├── data/
│   ├── tarot_meanings.json
│   ├── client_archetypes.json
│   └── location_data.json
└── addons/
    └── dialogue_system/
```

## Game Tone
Despite the financial pressure, the game maintains a cozy, hopeful atmosphere:
- **Charming struggles**: Eating cheap ramen is presented with humor
- **Small victories**: First $20 day feels like a triumph
- **Community support**: Other witches share tips and encouragement
- **Optimistic outlook**: {Subj}'s determined to make it work
- **Cozy moments**: Watching the city lights from {poss} tiny window

## MVP Scope (First Release)
1. **5 Locations** to set up shop
2. **15 Client Types** with unique stories
3. **Full 78-Card Deck** with meanings
4. **3 Reading Spreads**: Single card, 3-card, Celtic Cross
5. **Compact Mirror** with all features
6. **Croneslist** for finding affordable used brooms
7. **20-30 minutes** of engaging gameplay per session

## Unique Features
- **Living Tarot**: Cards subtly animate when drawn
- **Client Memory**: Returning clients reference previous readings
- **Witch Network**: Other witches send tips about good locations/times
- **Ambient Life**: City feels alive with NPCs, weather, day/night cycle