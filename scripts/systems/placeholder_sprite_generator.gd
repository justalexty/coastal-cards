extends Node

# Placeholder Sprite Generator for Testing Character Customization
# Creates simple colored shapes until we have real sprite assets

static func create_placeholder_character(character_data: Dictionary) -> Node2D:
	var character = Node2D.new()
	
	# Body (simple colored rectangle)
	var body = ColorRect.new()
	body.size = Vector2(32, 48)
	body.position = Vector2(-16, -48)
	body.color = _get_skin_color(character_data.get("skin_tone", 0))
	character.add_child(body)
	
	# Hair (colored shape on top)
	var hair = ColorRect.new()
	hair.size = Vector2(36, 20)
	hair.position = Vector2(-18, -48)
	hair.color = _get_hair_color(character_data.get("hair_color", 0))
	character.add_child(hair)
	
	# Outfit (different colored rectangle)
	var outfit = ColorRect.new()
	outfit.size = Vector2(32, 30)
	outfit.position = Vector2(-16, -30)
	outfit.color = _get_outfit_color(character_data.get("outfit", 0))
	character.add_child(outfit)
	
	# Eyes (two small dots)
	var eye_left = ColorRect.new()
	eye_left.size = Vector2(4, 4)
	eye_left.position = Vector2(-8, -38)
	eye_left.color = Color.BLACK
	character.add_child(eye_left)
	
	var eye_right = ColorRect.new()
	eye_right.size = Vector2(4, 4)
	eye_right.position = Vector2(4, -38)
	eye_right.color = Color.BLACK
	character.add_child(eye_right)
	
	# Add some visual interest with body type variations
	match character_data.get("body_type", "androgynous"):
		"feminine":
			body.size.x = 28
			body.position.x = -14
		"masculine":
			body.size.x = 36
			body.position.x = -18
	
	return character

static func _get_skin_color(tone_index: int) -> Color:
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
	return skin_tones[tone_index % skin_tones.size()]

static func _get_hair_color(color_index: int) -> Color:
	var hair_colors = [
		Color("#2C1810"), # Black
		Color("#3B2219"), # Dark Brown
		Color("#6F4E37"), # Medium Brown
		Color("#A0826D"), # Light Brown
		Color("#F5DEB3"), # Blonde
		Color("#DC143C"), # Red
		Color("#FF69B4"), # Pink
		Color("#9370DB"), # Purple
		Color("#4169E1"), # Blue
		Color("#228B22"), # Green
		Color("#808080"), # Gray
		Color("#FFFFFF")  # White
	]
	return hair_colors[color_index % hair_colors.size()]

static func _get_outfit_color(outfit_index: int) -> Color:
	var outfit_colors = [
		Color("#4B0082"), # Apprentice purple
		Color("#228B22"), # Casual green
		Color("#DC143C"), # Fortune teller red
		Color("#000080"), # Professional navy
		Color("#4169E1")  # Mystical blue
	]
	return outfit_colors[outfit_index % outfit_colors.size()]

# Create animated placeholder (for future use)
static func create_animated_placeholder(character_data: Dictionary) -> AnimatedSprite2D:
	var animated_sprite = AnimatedSprite2D.new()
	var sprite_frames = SpriteFrames.new()
	
	# For now, just return the animated sprite
	# Real implementation would create animation frames
	return animated_sprite