extends Control

# Daily Card UI - Morning ritual interface
class_name DailyCardUI

@onready var card_back = $CardContainer/CardBack
@onready var card_front = $CardContainer/CardFront
@onready var card_name_label = $CardContainer/CardFront/CardName
@onready var card_image = $CardContainer/CardFront/CardImage
@onready var interpretation_box = $InterpretationPanel/ScrollContainer/InterpretationText
@onready var effects_list = $EffectsPanel/EffectsList
@onready var mood_label = $MoodPanel/MoodLabel
@onready var skip_button = $ButtonContainer/SkipButton
@onready var draw_button = $ButtonContainer/DrawButton
@onready var continue_button = $ButtonContainer/ContinueButton

var daily_card_system: DailyCardSystem
var card_data: Dictionary = {}
var is_revealing: bool = false

func _ready():
	daily_card_system = get_node("/root/DailyCardSystem")
	
	# Set initial state
	card_front.visible = false
	card_back.visible = true
	continue_button.visible = false
	interpretation_box.text = ""
	
	# Connect buttons
	draw_button.pressed.connect(_on_draw_pressed)
	skip_button.pressed.connect(_on_skip_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	
	# No skip option - daily card is part of the ritual
	skip_button.visible = false
	
	# Morning greeting
	_show_morning_greeting()

func _show_morning_greeting():
	var date_info = Calendar.get_current_date_info()
	var greeting = "Good morning!\n"
	
	# Add date
	greeting += date_info.weekday + ", " + date_info.month + " " + str(date_info.day)
	
	# Add moon phase
	greeting += "\n" + date_info.moon_phase.emoji + " " + date_info.moon_phase.name
	
	# Add holiday if any
	if date_info.holiday != "":
		greeting += "\n✨ " + date_info.holiday + " ✨"
	
	# Add energy state (should be refreshed from sleep)
	greeting += "\n\nEnergy: " + str(GameState.max_energy) + "/" + str(GameState.max_energy)
	
	# Morning mood after rest
	mood_label.text = "Well rested and ready for the day!"
	
	interpretation_box.text = greeting + "\n\nDraw your daily card for guidance?"

func _on_draw_pressed():
	if is_revealing:
		return
	
	is_revealing = true
	draw_button.disabled = true
	skip_button.visible = false
	
	# Draw the card
	card_data = daily_card_system.draw_daily_card()
	
	# Animate card flip
	_animate_card_reveal()

func _animate_card_reveal():
	var tween = create_tween()
	
	# Shake animation while "shuffling"
	for i in range(3):
		tween.tween_property(card_back, "position:x", 10, 0.1)
		tween.tween_property(card_back, "position:x", -10, 0.1)
	tween.tween_property(card_back, "position:x", 0, 0.1)
	
	# Flip animation
	tween.tween_property(card_back, "scale:x", 0, 0.3)
	tween.tween_callback(_show_card_front)
	tween.tween_property(card_front, "scale:x", 1, 0.3).from(0)
	
	# Show interpretation after flip
	tween.tween_callback(_show_interpretation)

func _show_card_front():
	# Update card display
	card_name_label.text = card_data.name
	
	# Set card image based on card
	if card_data.has("image_path"):
		card_image.texture = load(card_data.image_path)
	else:
		# Use placeholder or generate based on suit/number
		card_image.texture = _get_card_placeholder(card_data)
	
	# Apply card colors based on suit
	match card_data.get("suit", ""):
		"cups":
			card_front.modulate = Color(0.5, 0.8, 1.0)  # Blue
		"wands":
			card_front.modulate = Color(1.0, 0.8, 0.5)  # Orange
		"swords":
			card_front.modulate = Color(0.9, 0.9, 1.0)  # Silver
		"pentacles":
			card_front.modulate = Color(0.8, 1.0, 0.5)  # Green
		_:  # Major Arcana
			card_front.modulate = Color(1.0, 0.9, 1.0)  # Purple tint
	
	card_back.visible = false
	card_front.visible = true

func _show_interpretation():
	# Get personal interpretation
	var interp = daily_card_system._get_personal_interpretation(card_data)
	
	# Add general meaning
	if card_data.has("keywords"):
		interp += "\n\nKeywords: " + ", ".join(card_data.keywords)
	
	interpretation_box.text = interp
	
	# Show effects
	_display_daily_effects()
	
	# Enable continue
	continue_button.visible = true
	is_revealing = false

func _display_daily_effects():
	# Clear previous effects
	for child in effects_list.get_children():
		child.queue_free()
	
	var effects = daily_card_system.daily_effects
	
	for effect_type in effects:
		var value = effects[effect_type]
		var effect_label = Label.new()
		
		# Format effect display
		match effect_type:
			"energy":
				var sign = "+" if value > 0 else ""
				effect_label.text = "⚡ Energy " + sign + str(value)
				effect_label.modulate = Color(1, 1, 0) if value > 0 else Color(0.7, 0.7, 1)
			
			"luck":
				effect_label.text = "🍀 Luck +" + str(int(value * 100)) + "%"
				effect_label.modulate = Color(0, 1, 0)
			
			"tips":
				var sign = "+" if value > 0 else ""
				effect_label.text = "💰 Tips " + sign + str(int(value * 100)) + "%"
				effect_label.modulate = Color(1, 0.9, 0)
			
			"accuracy":
				effect_label.text = "🎯 Accuracy +" + str(int(value * 100)) + "%"
				effect_label.modulate = Color(0.9, 0.9, 1)
			
			"intuition":
				effect_label.text = "👁 Intuition +" + str(int(value * 100)) + "%"
				effect_label.modulate = Color(0.8, 0.7, 1)
			
			"rapport":
				effect_label.text = "💕 Rapport +" + str(int(value * 100)) + "%"
				effect_label.modulate = Color(1, 0.7, 0.8)
			
			"breakthrough":
				effect_label.text = "💡 Breakthrough insights today!"
				effect_label.modulate = Color(1, 1, 0.5)
			
			"transformation":
				effect_label.text = "🦋 Transformation energy"
				effect_label.modulate = Color(0.9, 0.7, 1)
		
		if effect_label.text != "":
			effects_list.add_child(effect_label)

func _on_skip_pressed():
	# No skip allowed - daily card is essential
	pass

func _on_continue_pressed():
	# Transition to main game
	get_tree().change_scene_to_file("res://scenes/locations/studio_apartment.tscn")

func _get_card_placeholder(card: Dictionary) -> Texture2D:
	# This would return appropriate placeholder texture
	# For now, return null - implement with actual card art
	return null