extends Node2D

# Composite sprite system for the witch character
# Layers sprites based on body type and customization options

class_name WitchSprite

@onready var base_sprite = $Base
@onready var outfit_sprite = $Outfit  
@onready var hair_back_sprite = $HairBack
@onready var hair_front_sprite = $HairFront
@onready var accessory_sprite = $Accessory
@onready var shadow_sprite = $Shadow

var current_body_type: String = "androgynous"
var current_skin_tone: String = "medium"
var current_hair_style: String = "long_straight"
var current_hair_color: String = "black"
var current_outfit: String = "traditional"
var current_accessory: String = "none"

# Sprite sheet paths organized by body type
var sprite_paths = {
	"feminine": "res://assets/sprites/witch/feminine/",
	"androgynous": "res://assets/sprites/witch/androgynous/",
	"masculine": "res://assets/sprites/witch/masculine/"
}

func _ready():
	update_appearance()

func update_appearance():
	var base_path = sprite_paths[current_body_type]
	
	# Load base body with skin tone
	if base_sprite:
		var body_texture = load(base_path + "body_" + current_skin_tone + ".png")
		base_sprite.texture = body_texture
	
	# Load outfit
	if outfit_sprite:
		var outfit_texture = load(base_path + "outfit_" + current_outfit + ".png")
		outfit_sprite.texture = outfit_texture
	
	# Load hair (split into front and back for better layering)
	if hair_back_sprite and hair_front_sprite:
		var hair_path = base_path + "hair_" + current_hair_style + "_"
		var hair_back = load(hair_path + "back.png")
		var hair_front = load(hair_path + "front.png")
		
		hair_back_sprite.texture = hair_back
		hair_front_sprite.texture = hair_front
		
		# Apply hair color as modulation
		var color = get_hair_color()
		hair_back_sprite.modulate = color
		hair_front_sprite.modulate = color
	
	# Load accessory if any
	if accessory_sprite:
		if current_accessory != "none":
			var acc_texture = load(base_path + "acc_" + current_accessory + ".png")
			accessory_sprite.texture = acc_texture
			accessory_sprite.visible = true
		else:
			accessory_sprite.visible = false

func get_hair_color() -> Color:
	match current_hair_color:
		"black": return Color(0.1, 0.1, 0.1)
		"brown": return Color(0.4, 0.2, 0.1)
		"blonde": return Color(0.9, 0.8, 0.4)
		"red": return Color(0.7, 0.2, 0.1)
		"purple": return Color(0.6, 0.2, 0.8)
		"blue": return Color(0.2, 0.4, 0.8)
		"green": return Color(0.2, 0.7, 0.3)
		"white": return Color(0.9, 0.9, 0.9)
		"pink": return Color(0.9, 0.5, 0.7)
		_: return Color.WHITE

func set_from_character_data(data: Dictionary):
	current_body_type = data.get("body_type", "androgynous")
	current_skin_tone = data.get("skin_tone", "medium")
	current_hair_style = data.get("hair_style", "long_straight")
	current_hair_color = data.get("hair_color", "black")
	current_outfit = data.get("outfit", "traditional")
	current_accessory = data.get("accessory", "none")
	
	update_appearance()

# For animation, we'll swap between frame indexes
func set_animation_frame(frame: int):
	# Each sprite sheet has 4 columns (down, up, left, right)
	# and multiple rows for animation frames
	var frames_per_row = 4
	var row = frame / frames_per_row
	var col = frame % frames_per_row
	
	# Set the region rect for each sprite
	for sprite in [base_sprite, outfit_sprite, hair_back_sprite, hair_front_sprite, accessory_sprite]:
		if sprite and sprite.texture:
			sprite.region_enabled = true
			sprite.region_rect = Rect2(col * 32, row * 48, 32, 48)