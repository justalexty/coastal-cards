extends Node

# Handler for Seliel's sprite format
# The sprites are 512x512 sheets with multiple frames

const SPRITE_SIZE = 64  # Individual sprite size
const SHEET_SIZE = 512  # Full sheet size
const FRAMES_PER_ROW = 8  # 512 / 64 = 8

# Seliel's naming conventions decoded
const OUTFIT_MAP = {
	0: "undi",  # Underwear (base)
	1: "fstr",  # Farmer style
	2: "pfpn",  # Professional 
	3: "boxr"   # Boxer shorts
}

const HAIR_MAP = {
	0: "bob1",  # Bob cut
	1: "dap1"   # Dapper/longer style
}

static func create_layered_character(character_data: Dictionary) -> Node2D:
	var character = Node2D.new()
	
	# Get the appropriate variant numbers
	var skin_variant = "v%02d" % clamp(character_data.skin_tone, 0, 10)
	var hair_variant = "v%02d" % clamp(character_data.hair_color, 0, 13)
	var outfit_name = OUTFIT_MAP.get(character_data.outfit % 4, "fstr")
	var hair_name = HAIR_MAP.get(character_data.hair_style % 2, "bob1")
	
	# Layer order (bottom to top)
	var layers = [
		# Base body
		{
			"path": "char_a_p1_0bas_humn_%s.png" % skin_variant,
			"name": "body"
		},
		# Outfit (if not underwear)
		{
			"path": "char_a_p1_1out_%s_v01.png" % outfit_name,
			"name": "outfit",
			"skip": outfit_name == "undi"
		},
		# Hair
		{
			"path": "char_a_p1_4har_%s_%s.png" % [hair_name, hair_variant],
			"name": "hair"
		}
	]
	
	# Add optional hat
	if character_data.get("accessory") == "witch_hat":
		layers.append({
			"path": "char_a_p1_5hat_pfht_v01.png",
			"name": "hat"
		})
	
	# Create sprites for each layer
	for layer_info in layers:
		if layer_info.get("skip", false):
			continue
			
		var sprite = Sprite2D.new()
		sprite.name = layer_info.name
		
		var texture_path = "res://assets/sprites/character/seliel/" + layer_info.path
		if ResourceLoader.exists(texture_path):
			sprite.texture = load(texture_path)
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			
			# Set up sprite sheet region (using first frame for now)
			sprite.region_enabled = true
			sprite.region_rect = Rect2(0, 0, SPRITE_SIZE, SPRITE_SIZE)
			
			# Center the sprite
			sprite.centered = true
			
			# Scale for visibility
			sprite.scale = Vector2(2, 2)
			
			character.add_child(sprite)
	
	return character

static func get_animation_frame(row: int, col: int) -> Rect2:
	# Calculate position of a specific frame in the sprite sheet
	return Rect2(
		col * SPRITE_SIZE,
		row * SPRITE_SIZE,
		SPRITE_SIZE,
		SPRITE_SIZE
	)

static func setup_animated_character(character_data: Dictionary) -> AnimatedSprite2D:
	# TODO: Set up full animations once we know the sprite sheet layout
	var animated_sprite = AnimatedSprite2D.new()
	
	# This would need to composite the layers into animation frames
	# For now, returning placeholder
	
	return animated_sprite