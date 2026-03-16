extends Control

# Character Creation in Compact Mirror

@onready var name_input = $CompactMirror/CreationForm/NameInput
@onready var pronoun_option = $CompactMirror/CreationForm/PronounOption
@onready var confirm_button = $CompactMirror/CreationForm/ConfirmButton
@onready var mirror_reflection = $CompactMirror/MirrorReflection
@onready var compact_mirror = $CompactMirror
@onready var instructions = $Instructions

var pronoun_sets = [
	{"subject": "she", "object": "her", "possessive": "her", "display": "she/her"},
	{"subject": "he", "object": "him", "possessive": "his", "display": "he/him"},  
	{"subject": "they", "object": "them", "possessive": "their", "display": "they/them"},
	{"subject": "xe", "object": "xir", "possessive": "xir", "display": "xe/xir"},
	{"subject": "fae", "object": "faer", "possessive": "faer", "display": "fae/faer"}
]

func _ready():
	# Set up pronouns dropdown
	for pronoun in pronoun_sets:
		pronoun_option.add_item(pronoun.display)
	
	# Connect signals
	confirm_button.pressed.connect(_on_confirm_pressed)
	name_input.text_changed.connect(_on_name_changed)
	
	# Add magical shimmer to mirror
	_animate_mirror_magic()
	
	# Focus on name input
	name_input.grab_focus()

func _animate_mirror_magic():
	# Subtle shimmer effect on the mirror
	var tween = create_tween().set_loops()
	tween.tween_property(mirror_reflection, "modulate:a", 0.3, 1.5)
	tween.tween_property(mirror_reflection, "modulate:a", 0.2, 1.5)
	
	# Gentle rotation for magical effect
	var rotate_tween = create_tween().set_loops()
	rotate_tween.tween_property(compact_mirror, "rotation", 0.02, 2.0)
	rotate_tween.tween_property(compact_mirror, "rotation", -0.02, 2.0)

func _on_name_changed(new_text: String):
	# Enable confirm button only with a name
	confirm_button.disabled = new_text.strip_edges().length() == 0

func _on_confirm_pressed():
	if name_input.text.strip_edges() == "":
		# Shake the mirror if no name
		_shake_mirror()
		return
	
	# Save character data  
	GameState.player_character = {
		"name": name_input.text.strip_edges(),
		"pronouns": pronoun_sets[pronoun_option.selected],
		"created_at": Time.get_datetime_string_from_system()
	}
	
	# Also store in GameState for easy access
	GameState.player_name = GameState.player_character.name
	GameState.player_pronouns = GameState.player_character.pronouns.display
	
	print("Character created: ", GameState.player_character.name, " (", GameState.player_pronouns, ")")
	
	# Visual feedback - mirror flash
	_mirror_flash()
	
	# Proceed to game
	await get_tree().create_timer(1.0).timeout
	_transition_to_game()

func _shake_mirror():
	var tween = create_tween()
	var original_pos = compact_mirror.position
	for i in range(3):
		tween.tween_property(compact_mirror, "position:x", original_pos.x + 10, 0.05)
		tween.tween_property(compact_mirror, "position:x", original_pos.x - 10, 0.05)
	tween.tween_property(compact_mirror, "position", original_pos, 0.05)

func _mirror_flash():
	# Create a white flash overlay
	var flash = ColorRect.new()
	flash.color = Color.WHITE
	flash.size = Vector2(500, 500)
	flash.modulate.a = 0
	compact_mirror.add_child(flash)
	
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.8, 0.2)
	tween.tween_property(flash, "modulate:a", 0.0, 0.5)
	tween.tween_callback(flash.queue_free)

func _transition_to_game():
	# Update instruction text
	instructions.text = "[center][color=#C5A55A]The mirror accepts your true self...[/color][/center]"
	
	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.finished.connect(func(): get_tree().change_scene_to_file("res://scenes/locations/train_station.tscn"))

# Allow Enter key to confirm
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER and not confirm_button.disabled:
			_on_confirm_pressed()