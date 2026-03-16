extends Node

# Simple Pixel Art Character Generator
# Creates basic witch sprites in code - no external assets needed!

static func generate_witch_sprite(character_data: Dictionary) -> Texture2D:
	var width = 32
	var height = 48
	var image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	
	# Clear to transparent
	image.fill(Color(0, 0, 0, 0))
	
	# Get colors
	var skin_color = _get_skin_color(character_data.get("skin_tone", 0))
	var hair_color = _get_hair_color(character_data.get("hair_color", 0))
	var outfit_color = _get_outfit_color(character_data.get("outfit", 0))
	
	# Draw the witch!
	
	# Body/Head (simple style)
	_draw_circle(image, Vector2i(width/2, 14), 6, skin_color) # head
	_draw_rect(image, Rect2i(14, 8, 4, 2), Color.BLACK) # eyes
	
	# Hair (different styles)
	match character_data.get("hair_style", 0):
		0: # Bob
			_draw_rect(image, Rect2i(10, 8, 12, 8), hair_color)
		1: # Long
			_draw_rect(image, Rect2i(10, 8, 12, 16), hair_color)
		2: # Ponytail  
			_draw_rect(image, Rect2i(10, 8, 12, 6), hair_color)
			_draw_rect(image, Rect2i(20, 10, 4, 12), hair_color)
	
	# Outfit (robe/dress)
	_draw_rect(image, Rect2i(12, 20, 8, 4), skin_color) # neck
	_draw_rect(image, Rect2i(8, 24, 16, 20), outfit_color) # robe
	_draw_rect(image, Rect2i(6, 26, 20, 2), outfit_color) # sleeves
	
	# Arms
	_draw_rect(image, Rect2i(4, 28, 4, 8), skin_color) # left arm
	_draw_rect(image, Rect2i(24, 28, 4, 8), skin_color) # right arm
	
	# Witch hat (optional accessory)
	if character_data.get("accessory", "") == "witch_hat":
		_draw_triangle(image, Vector2i(width/2, 4), 8, Color(0.2, 0.1, 0.3))
	
	return ImageTexture.create_from_image(image)

# Helper drawing functions
static func _draw_rect(img: Image, rect: Rect2i, color: Color):
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
				img.set_pixel(x, y, color)

static func _draw_circle(img: Image, center: Vector2i, radius: int, color: Color):
	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			var dist = (Vector2i(x, y) - center).length()
			if dist <= radius:
				if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
					img.set_pixel(x, y, color)

static func _draw_triangle(img: Image, top: Vector2i, width: int, color: Color):
	for row in range(width):
		var row_width = row + 1
		var start_x = top.x - row_width / 2
		for x in range(row_width):
			var px = start_x + x
			var py = top.y + row
			if px >= 0 and px < img.get_width() and py >= 0 and py < img.get_height():
				img.set_pixel(px, py, color)

static func _get_skin_color(index: int) -> Color:
	var colors = [
		Color("#FDE7D8"), Color("#F5DEB3"), Color("#D2B48C"),
		Color("#BC8F6F"), Color("#8B6039"), Color("#654321")
	]
	return colors[index % colors.size()]

static func _get_hair_color(index: int) -> Color:
	var colors = [
		Color("#2C1810"), Color("#6F4E37"), Color("#F5DEB3"),
		Color("#DC143C"), Color("#FF69B4"), Color("#9370DB")
	]
	return colors[index % colors.size()]

static func _get_outfit_color(index: int) -> Color:
	var colors = [
		Color("#4B0082"), Color("#228B22"), Color("#DC143C"),
		Color("#000080"), Color("#4169E1")
	]
	return colors[index % colors.size()]