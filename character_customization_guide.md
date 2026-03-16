# Character Customization System - How It Works

## Overview
I've built a flexible character customization system that can work with ANY sprite system - whether it's Seliel's sprites, custom sprites, or something else!

## What's Included:

### 1. Core System (`character_customization.gd`)
- Manages character data (name, pronouns, appearance)
- Creates character sprites from modular parts
- Saves/loads character data
- Currently using **placeholder sprites** (colored rectangles) for testing

### 2. Compact Mirror UI (`compact_mirror_character.gd`)
- Beautiful circular mirror interface
- Click arrows to cycle through options:
  - Body type (Feminine/Androgynous/Masculine)
  - Skin tone (8 options)
  - Hair style (10 styles)
  - Hair color (14 colors)
  - Outfit (5 options)
- Name input and pronoun selection
- Live preview in the mirror reflection

### 3. Placeholder System
Until we get real sprites, the system generates simple colored shapes:
- Different body widths for body types
- Skin tone colors
- Hair colors
- Outfit colors

## How to Use:

### In Code:
```gdscript
# Get the character system
var char_system = get_node("/root/CharacterCustomization")

# Create a character sprite
var my_character = char_system.create_character_sprite(char_system.current_character)
add_child(my_character)

# Access character data
var player_name = char_system.current_character.name
var pronouns = char_system.current_character.pronouns
print(pronouns.subject + " is a witch")  # "she is a witch" / "they are a witch" etc
```

### To Add Real Sprites:

1. **Get your sprite assets** (Seliel's, custom, etc)
2. **Organize them**:
   ```
   assets/sprites/character/
   ├── body/
   │   ├── feminine_base.png
   │   ├── androgynous_base.png
   │   └── masculine_base.png
   ├── hair/
   │   ├── style_0_front.png
   │   ├── style_0_back.png
   │   └── ...
   ├── outfits/
   │   ├── top_0.png
   │   ├── bottom_0.png
   │   └── ...
   └── accessories/
   ```

3. **Uncomment the real sprite code** in `create_character_sprite()`
4. **Adjust paths** to match your asset structure

## Customization Options:

### Current Options:
- **Body Types**: 3 (affects sprite base)
- **Skin Tones**: 8 (from light to deep)
- **Hair Styles**: 10 (bob, ponytail, braids, etc)
- **Hair Colors**: 14 (natural + fantasy colors)
- **Eye Colors**: 6
- **Outfits**: 5 (apprentice to mystical sage)

### Easy to Extend:
- Add new hairstyles: Just increase the count and add names
- Add accessories: Enable the accessory system
- Add animations: Use the `setup_animated_character()` function

## Integration with Train Scene:

The character creation in the train arrival scene can now use this full system:

```gdscript
# In train arrival scene, when compact opens:
var full_customization = preload("res://scenes/compact_mirror/character_customization_full.tscn")
var mirror_ui = full_customization.instantiate()
add_child(mirror_ui)
```

## Why This System is Flexible:

1. **Sprite-agnostic**: Works with any art style
2. **Layer-based**: Standard paper-doll approach
3. **Color tinting**: Built-in skin/hair color system
4. **Save system**: Remembers player choices
5. **Pronoun support**: Fully integrated with PronounManager

## Next Steps:

1. **Test with placeholders** to get the feel right
2. **Choose your sprite pack** (Seliel's or custom)
3. **Replace placeholder generator** with real sprites
4. **Add walking animations** when ready

The system is ready - just needs the art assets! 🎨✨