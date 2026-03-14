# Coastal Witch Tarot Game

A cozy Ghibli-inspired game about a young witch building her tarot reading business in a coastal city.

## Project Setup

### Prerequisites
- Godot 4.2+ (download from godotengine.org)
- Aseprite or similar for pixel art (optional)
- Git for version control

### Getting Started
1. Open Godot and import this project
2. The main scene will be in `scenes/main_menu/main_menu.tscn`
3. Run the project to see the opening sequence

## Art Direction

### Character Sprites - Better Than LPC for This Project

For the Ghibli aesthetic, I recommend **NOT** using LPC sprites. Here's why and what to use instead:

#### Option 1: Seliel's Sprites (Recommended)
- **Link**: https://seliel-the-shaper.itch.io/character-base
- **Why**: More anime/Ghibli proportions, cleaner style
- **License**: Free with attribution
- **Customization**: Easy to modify in Aseprite

#### Option 2: Time Fantasy Style
- **Link**: https://finalbossblues.com/time-fantasy/
- **Why**: Beautiful hand-drawn style, perfect for cozy games
- **License**: Paid but worth it for professional look
- **Note**: Has matching tilesets for environments

#### Option 3: Custom Sprite Base
Create your own base in this style:
- **Size**: 32x48 pixels (taller proportions than LPC)
- **Style**: Large head, expressive eyes, flowing clothes
- **Key Frames**: Idle (breathing), Walk (8 frames), Sit, Shuffle cards
- **Layers**: Base body, Hair (front/back), Outfit, Accessories

### Color Palette
```css
/* Ghibli-Inspired Coastal Palette */
--sky-blue: #87CEEB;
--ocean-deep: #1E6BA0;
--sunset-orange: #FF6B4A;
--sand-beige: #F4E4C1;
--witch-purple: #8B7DAA;
--candle-glow: #FFE4B5;
--shadow-blue: #2C3E50;
--card-gold: #FFD700;
```

## Core Systems Implementation Order

### Phase 1: Foundation (Week 1)
- [x] Compact mirror UI system
- [x] Character creation with pronouns
- [ ] Basic movement and collision
- [x] Save/Load system
- [x] Croneslist marketplace

### Phase 2: Tarot System (Week 2)
- [ ] Card data structure
- [ ] Reading interface
- [ ] Card animation system
- [ ] Interpretation mechanics

### Phase 3: World Building (Week 3)
- [ ] Location system
- [ ] NPC generation
- [ ] Time of day cycle
- [ ] Weather effects

### Phase 4: Business Loop (Week 4)
- [ ] Client attraction system
- [ ] Reputation tracking
- [ ] Permit/unlock system
- [ ] Economic balance

## Asset Creation Guidelines

### Tarot Cards
- Size: 64x96 pixels
- Style: Hand-painted with gold borders
- Back design: Mystical pattern with moon phases
- Animation: Subtle glow when selected

### Environment Tiles
- Size: 32x32 base tiles
- Style: Soft edges, painterly
- Variations: Day/night versions
- Special tiles: Animated water, swaying trees

### UI Elements
- Compact mirror: Ornate vintage design
- Buttons: Rounded, soft shadows
- Fonts: Mix of handwritten (dialogue) and clean serif (UI)

## Unique Implementation Details

### Character Creation
- **Pronouns**: She/Her, He/Him, They/Them, or Custom
- **Body Types**: Feminine, Androgynous, Masculine (affects sprite base)
- **Full Customization**: Skin tone, hair, eyes, outfit, accessories
- **Name**: Player chooses their witch name

### Magic Compact Features
1. **Holographic Messages**: Shader effect for ethereal appearance
2. **Scrying Ripples**: Water-like distortion shader
3. **Character Preview**: Real-time sprite compositing with chosen body type
4. **Quick Save**: Diegetic save system (makes sense in-world)
5. **Styling Mode**: Change appearance anytime (hair grows, fashion changes!)

### Tarot Reading Mechanics
1. **Energy System**: Client's mood affects available cards
2. **Interpretation Choices**: Multiple meanings per card
3. **Context Matters**: Same card means different things
4. **Visual Feedback**: Cards glow/shake based on relevance

### Street Vendor Progression
1. **Folding Table Tiers**: Basic → Ornate → Mystical
2. **Weather Protection**: Unlockable canopies and charms  
3. **Client Attraction**: Incense, crystals, signs
4. **Location Permits**: Mini-quests with city officials

## Next Steps

1. **Set up Godot project file** (project.godot)
2. **Create character controller** with 8-directional movement
3. **Implement compact mirror UI** with working buttons
4. **Design first location** (Train Station → City Entrance)
5. **Create NPC client generator** with problem templates

## Resources

### Tarot Reference
- Rider-Waite meanings: https://www.biddytarot.com/tarot-card-meanings/
- Card spreads: https://labyrinthos.co/blogs/tarot-card-spreads

### Godot Tutorials
- Dialogue system: https://www.youtube.com/watch?v=06VgLTqNvU4
- Save system: https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html

### Inspiration
- Kiki's Delivery Service (entrepreneurial spirit)
- Spirited Away (magical everyday life)
- Little Witch Academia (witch community)

---

## Development Notes

The game should feel like:
- Building a small business from nothing
- Learning through doing (tarot education)
- Finding your place in a big city
- Magic as everyday tool, not spectacle