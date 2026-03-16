extends Control

# Compact Mirror Character Customization UI
# This is what players see when they look in their magical compact

@onready var character_preview = $MirrorReflection/CharacterViewport/CharacterPreview
@onready var name_input = $CustomizationPanel/OptionsContainer/NameSection/NameInput
@onready var pronoun_selector = $CustomizationPanel/OptionsContainer/PronounSection/PronounSelector

# Option displays
@onready var body_type_label = $CustomizationPanel/OptionsContainer/BodySection/BodyTypeLabel
@onready var skin_tone_preview = $CustomizationPanel/OptionsContainer/SkinSection/ColorPreview
@onready var hair_style_label = $CustomizationPanel/OptionsContainer/HairSection/StyleLabel
@onready var hair_color_preview = $CustomizationPanel/OptionsContainer/HairSection/ColorPreview
@onready var outfit_label = $CustomizationPanel/OptionsContainer/OutfitSection/OutfitLabel

var customization_system: Node
var current_character_sprite: Node2D

var pronoun_options = [
	{"display": "she/her", "subject": "she", "object": "her", "possessive": "her"},
	{"display": "he/him", "subject": "he", "object": "him", "possessive": "his"},
	{"display": "they/them", "subject": "they", "object": "them", "possessive": "their"},
	{"display": "xe/xir", "subject": "xe", "object": "xir", "possessive": "xir"},
	{"display": "custom", "subject": "", "object": "", "possessive": ""}
]

var body_type_names = ["Feminine", "Androgynous", "Masculine"]
var hair_style_names = [
	"Bob", "Long Straight", "Ponytail", "Braids", "Pixie Cut", 
	"Wavy", "Curly", "Messy", "Twin Tails", "Bun"
]
var outfit_names = [
	"Apprentice Robes", "Casual Witch", "Street Fortune Teller", 
	"Professional Reader", "Mystical Sage"
]

func _ready():
	customization_system = get_node("/root/CharacterCustomization")
	
	# Set up pronoun dropdown
	for pronoun in pronoun_options:
		pronoun_selector.add_item(pronoun.display)
	
	# Connect all the arrow buttons
	_connect_customization_buttons()
	
	# Load saved character or create new
	if customization_system.load_character_data():
		_update_all_displays()
	else:
		_create_default_character()
	
	# Initial preview
	_update_character_preview()

func _connect_customization_buttons():
	# Body type
	$CustomizationPanel/OptionsContainer/BodySection/PrevButton.pressed.connect(
		func(): _change_option("body_type", -1)
	)
	$CustomizationPanel/OptionsContainer/BodySection/NextButton.pressed.connect(
		func(): _change_option("body_type", 1)
	)
	
	# Skin tone
	$CustomizationPanel/OptionsContainer/SkinSection/PrevButton.pressed.connect(
		func(): _change_option("skin_tone", -1)
	)
	$CustomizationPanel/OptionsContainer/SkinSection/NextButton.pressed.connect(
		func(): _change_option("skin_tone", 1)
	)
	
	# Hair style
	$CustomizationPanel/OptionsContainer/HairSection/StylePrevButton.pressed.connect(
		func(): _change_option("hair_style", -1)
	)
	$CustomizationPanel/OptionsContainer/HairSection/StyleNextButton.pressed.connect(
		func(): _change_option("hair_style", 1)
	)
	
	# Hair color
	$CustomizationPanel/OptionsContainer/HairSection/ColorPrevButton.pressed.connect(
		func(): _change_option("hair_color", -1)
	)
	$CustomizationPanel/OptionsContainer/HairSection/ColorNextButton.pressed.connect(
		func(): _change_option("hair_color", 1)
	)
	
	# Outfit
	$CustomizationPanel/OptionsContainer/OutfitSection/PrevButton.pressed.connect(
		func(): _change_option("outfit", -1)
	)
	$CustomizationPanel/OptionsContainer/OutfitSection/NextButton.pressed.connect(
		func(): _change_option("outfit", 1)
	)
	
	# Name and pronouns
	name_input.text_changed.connect(_on_name_changed)
	pronoun_selector.item_selected.connect(_on_pronoun_selected)
	
	# Save button
	$CustomizationPanel/SaveButton.pressed.connect(_save_and_close)

func _change_option(option_type: String, direction: int):
	var char_data = customization_system.current_character
	
	match option_type:
		"body_type":
			var types = ["feminine", "androgynous", "masculine"]
			var current_index = types.find(char_data.body_type)
			current_index = wrapi(current_index + direction, 0, types.size())
			char_data.body_type = types[current_index]
		
		"skin_tone":
			char_data.skin_tone = customization_system.get_next_option("skin_tone", char_data.skin_tone, direction)
		
		"hair_style":
			char_data.hair_style = customization_system.get_next_option("hair_style", char_data.hair_style, direction)
		
		"hair_color":
			char_data.hair_color = customization_system.get_next_option("hair_color", char_data.hair_color, direction)
		
		"outfit":
			char_data.outfit = customization_system.get_next_option("outfit", char_data.outfit, direction)
	
	_update_all_displays()
	_update_character_preview()
	
	# Add a little sparkle effect when changing
	_play_sparkle_effect()

func _update_all_displays():
	var char_data = customization_system.current_character
	
	# Update labels
	body_type_label.text = body_type_names[["feminine", "androgynous", "masculine"].find(char_data.body_type)]
	hair_style_label.text = hair_style_names[char_data.hair_style]
	outfit_label.text = outfit_names[char_data.outfit]
	
	# Update color previews
	skin_tone_preview.modulate = customization_system.skin_tones[char_data.skin_tone]
	hair_color_preview.modulate = customization_system.hair_colors[char_data.hair_color]
	
	# Update name
	if name_input.text != char_data.name:
		name_input.text = char_data.name

func _update_character_preview():
	# Remove old preview if exists
	if current_character_sprite:
		current_character_sprite.queue_free()
	
	# Create new character sprite
	current_character_sprite = customization_system.create_character_sprite(
		customization_system.current_character
	)
	
	if character_preview:
		character_preview.add_child(current_character_sprite)

func _on_name_changed(new_name: String):
	customization_system.current_character.name = new_name

func _on_pronoun_selected(index: int):
	var pronoun_data = pronoun_options[index]
	customization_system.current_character.pronouns = {
		"subject": pronoun_data.subject,
		"object": pronoun_data.object,
		"possessive": pronoun_data.possessive
	}

func _play_sparkle_effect():
	# Create a simple sparkle particle effect
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.amount = 20
	particles.lifetime = 0.5
	particles.one_shot = true
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_BOX
	particles.emission_box_extents = Vector2(100, 100)
	particles.initial_velocity_min = 50
	particles.initial_velocity_max = 150
	particles.angular_velocity_min = -180
	particles.angular_velocity_max = 180
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.5
	
	# Star-like texture
	var gradient = Gradient.new()
	gradient.set_color(0, Color(1, 1, 0.8, 1))
	gradient.set_color(1, Color(1, 1, 1, 0))
	
	$MirrorReflection.add_child(particles)
	particles.position = $MirrorReflection.size / 2
	
	# Clean up after effect
	await particles.finished
	particles.queue_free()

func _save_and_close():
	customization_system.save_character_data()
	
	# Mirror closing animation
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 0), 0.3)
	tween.finished.connect(func(): self.visible = false)

func _create_default_character():
	# Set some defaults for new character
	customization_system.current_character = {
		"name": "",
		"pronouns": pronoun_options[0],
		"body_type": "androgynous",
		"skin_tone": 2,
		"hair_style": 0,
		"hair_color": 1,
		"eye_color": 0,
		"outfit": 0,
		"accessory": null
	}