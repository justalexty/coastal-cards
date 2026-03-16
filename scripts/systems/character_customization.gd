extends Node

# Character Customization System for Coastal Cards
# Works with modular sprite systems (Seliel's or custom)

signal customization_changed

var current_character = {
	"name": "",
	"pronouns": {"subject": "they", "object": "them", "possessive": "their"},
	"body_type": "androgynous", # feminine, androgynous, masculine
	"skin_tone": 0,
	"hair_style": 0,
	"hair_color": 0,
	"eye_color": 0,
	"outfit": 0,
	"accessory": null
}

# Define available options
var skin_tones = [
	Color("#FDE7D8"), # Light
	Color("#F5DEB3"), # Wheat
	Color("#D2B48C"), # Tan
	Color("#BC8F6F"), # Bronze
	Color("#8B6039"), # Brown
	Color("#654321"), # Dark Brown
	Color("#3D2314"), # Deep Brown
	Color("#FFE0BD")  # Pale
]

var hair_colors = [
	Color("#2C1810"), # Black
	Color("#3B2219"), # Dark Brown
	Color("#6F4E37"), # Medium Brown
	Color("#A0826D"), # Light Brown
	Color("#C19A6B"), # Caramel
	Color("#F5DEB3"), # Blonde
	Color("#FFF8DC"), # Platinum
	Color("#DC143C"), # Red
	Color("#FF69B4"), # Pink
	Color("#9370DB"), # Purple
	Color("#4169E1"), # Blue
	Color("#228B22"), # Green
	Color("#808080"), # Gray
	Color("#FFFFFF")  # White
]

var eye_colors = [
	Color("#654321"), # Brown
	Color("#228B22"), # Green
	Color("#4169E1"), # Blue
	Color("#708090"), # Gray
	Color("#D4AF37"), # Hazel
	Color("#9370DB")  # Violet
]

# Sprite layer paths (adjust based on actual asset structure)
const SPRITE_BASE_PATH = "res://assets/sprites/character/"
const LAYER_ORDER = [
	"body_base",
	"eyes",
	"outfit_bottom",
	"outfit_top",
	"hair_back",
	"hair_front",
	"accessory"
]

func create_character_sprite(character_data: Dictionary) -> Node2D:
	# For now, use placeholder sprites until we have real assets
	var PlaceholderGen = preload("res://scripts/systems/placeholder_sprite_generator.gd")
	return PlaceholderGen.create_placeholder_character(character_data)
	
	# Original layered sprite code (for when we have assets):
	#var character_node = Node2D.new()
	#character_node.name = "Character"
	#
	## Create sprites for each layer
	#for layer_name in LAYER_ORDER:
	#	var sprite = Sprite2D.new()
	#	sprite.name = layer_name
	#	sprite.centered = true
	#	
	#	# Load appropriate texture based on character data
	#	_load_layer_texture(sprite, layer_name, character_data)
	#	
	#	# Apply tinting for skin/hair/eyes
	#	_apply_layer_tinting(sprite, layer_name, character_data)
	#	
	#	character_node.add_child(sprite)
	#
	#return character_node

func _load_layer_texture(sprite: Sprite2D, layer_name: String, data: Dictionary):
	var texture_path = ""
	
	match layer_name:
		"body_base":
			texture_path = SPRITE_BASE_PATH + "body/" + data.body_type + "_base.png"
		
		"eyes":
			texture_path = SPRITE_BASE_PATH + "eyes/eyes_" + str(data.eye_color) + ".png"
		
		"outfit_bottom":
			texture_path = SPRITE_BASE_PATH + "outfits/bottom_" + str(data.outfit) + ".png"
		
		"outfit_top":
			texture_path = SPRITE_BASE_PATH + "outfits/top_" + str(data.outfit) + ".png"
		
		"hair_back":
			texture_path = SPRITE_BASE_PATH + "hair/style_" + str(data.hair_style) + "_back.png"
		
		"hair_front":
			texture_path = SPRITE_BASE_PATH + "hair/style_" + str(data.hair_style) + "_front.png"
		
		"accessory":
			if data.accessory != null:
				texture_path = SPRITE_BASE_PATH + "accessories/" + str(data.accessory) + ".png"
	
	if texture_path != "" and ResourceLoader.exists(texture_path):
		sprite.texture = load(texture_path)

func _apply_layer_tinting(sprite: Sprite2D, layer_name: String, data: Dictionary):
	match layer_name:
		"body_base":
			sprite.modulate = skin_tones[data.skin_tone]
		
		"hair_back", "hair_front":
			sprite.modulate = hair_colors[data.hair_color]
		
		"eyes":
			# Eyes might use shader for color change instead of modulate
			# This depends on how the sprites are set up
			pass

# For animation, we'd need to handle sprite sheets
func setup_animated_character(character_data: Dictionary) -> AnimatedSprite2D:
	var animated_sprite = AnimatedSprite2D.new()
	var sprite_frames = SpriteFrames.new()
	
	# Define animations
	var animations = ["idle", "walk_down", "walk_up", "walk_left", "walk_right"]
	
	for anim in animations:
		sprite_frames.add_animation(anim)
		sprite_frames.set_animation_speed(anim, 8.0)
		
		# This would need to composite the layers for each frame
		# For now, this is a placeholder structure
		pass
	
	animated_sprite.sprite_frames = sprite_frames
	return animated_sprite

# Character creation UI helpers
func get_next_option(category: String, current: int, direction: int) -> int:
	var max_options = 0
	
	match category:
		"body_type":
			max_options = 3
		"skin_tone":
			max_options = skin_tones.size()
		"hair_style":
			max_options = 10 # Adjust based on available styles
		"hair_color":
			max_options = hair_colors.size()
		"eye_color":
			max_options = eye_colors.size()
		"outfit":
			max_options = 5 # Adjust based on available outfits
	
	var new_value = current + direction
	if new_value < 0:
		new_value = max_options - 1
	elif new_value >= max_options:
		new_value = 0
	
	return new_value

func save_character_data():
	var save_data = {
		"character": current_character,
		"version": 1
	}
	
	var save_file = FileAccess.open("user://character_data.save", FileAccess.WRITE)
	if save_file:
		save_file.store_var(save_data)
		save_file.close()

func load_character_data():
	if FileAccess.file_exists("user://character_data.save"):
		var save_file = FileAccess.open("user://character_data.save", FileAccess.READ)
		if save_file:
			var save_data = save_file.get_var()
			save_file.close()
			
			if save_data and save_data.has("character"):
				current_character = save_data.character
				return true
	
	return false