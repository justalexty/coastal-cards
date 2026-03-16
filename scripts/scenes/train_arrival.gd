extends Node2D

# Train Arrival Scene Controller

@onready var dialogue_text = $DialogueBox/DialogueText
@onready var dialogue_box = $DialogueBox
@onready var compact_notification = $CompactNotification
@onready var click_prompt = $ClickPrompt
@onready var window = $TrainInterior/Window

var dialogue_sequence = [
	"[center]The train begins to slow as you approach the coastal city...[/center]",
	"[center]You clutch your broken broom handle - all that's left of your apprentice broom.[/center]",
	"[center]$700 for rent. $25 in your pocket. This is it.[/center]",
	"[center]Time to make it as a real witch.[/center]",
	"[center]The conductor announces: 'Final stop - Seavale Station!'[/center]"
]

var current_dialogue = 0
var can_advance = false
var dialogue_finished = false

func _ready():
	# Start with first dialogue
	_show_dialogue(0)
	
	# Subtle animation for the window
	_animate_scenery()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if can_advance and not dialogue_finished:
			_advance_dialogue()
		elif dialogue_finished:
			_show_compact_notification()

func _show_dialogue(index: int):
	can_advance = false
	click_prompt.visible = false
	
	if index < dialogue_sequence.size():
		dialogue_text.text = dialogue_sequence[index]
		
		# Fade in effect
		dialogue_box.modulate.a = 0
		var tween = create_tween()
		tween.tween_property(dialogue_box, "modulate:a", 1.0, 0.5)
		tween.finished.connect(_on_dialogue_shown)
	else:
		dialogue_finished = true
		_end_dialogue()

func _on_dialogue_shown():
	can_advance = true
	click_prompt.visible = true
	
	# Subtle pulse on click prompt
	var tween = create_tween().set_loops()
	tween.tween_property(click_prompt, "modulate:a", 0.5, 0.5)
	tween.tween_property(click_prompt, "modulate:a", 1.0, 0.5)

func _advance_dialogue():
	current_dialogue += 1
	_show_dialogue(current_dialogue)

func _end_dialogue():
	# Fade out dialogue
	var tween = create_tween()
	tween.tween_property(dialogue_box, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): dialogue_box.visible = false)
	
	# Wait a moment then show compact notification
	await get_tree().create_timer(1.0).timeout
	_show_compact_notification()

func _show_compact_notification():
	compact_notification.visible = true
	compact_notification.modulate.a = 0
	
	# Fade in with a magical glow effect
	var tween = create_tween()
	tween.tween_property(compact_notification, "modulate:a", 1.0, 0.5)
	
	# Add subtle glow animation
	var glow_tween = create_tween().set_loops(3)
	glow_tween.tween_property(compact_notification, "modulate:v", 1.2, 0.5)
	glow_tween.tween_property(compact_notification, "modulate:v", 1.0, 0.5)
	
	# Wait then transition to character creation
	await get_tree().create_timer(3.0).timeout
	_open_compact_mirror()

func _open_compact_mirror():
	print("Opening compact mirror for character creation...")
	# Fade to black
	var fade_rect = ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.size = Vector2(960, 540)
	fade_rect.modulate.a = 0
	add_child(fade_rect)
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 1.0)
	tween.finished.connect(_go_to_character_creation)

func _go_to_character_creation():
	# Now the character creation makes sense - you're looking in your compact!
	get_tree().change_scene_to_file("res://scenes/compact_mirror/character_creation_fixed.tscn")

func _animate_scenery():
	# Subtle parallax effect on window scenery
	if window:
		var tween = create_tween().set_loops()
		tween.tween_property(window, "position:x", window.position.x - 20, 3.0)
		tween.tween_property(window, "position:x", window.position.x + 20, 3.0)
		
	# You could add more scenery elements here:
	# - Passing trees/buildings in the window
	# - Swaying motion for train movement
	# - Other passengers (if we add them)