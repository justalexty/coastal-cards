extends Node2D

# Simple studio apartment for demo

@onready var player = $Player
@onready var money_label = $UI/TopBar/MoneyLabel
@onready var energy_label = $UI/TopBar/EnergyLabel
@onready var calendar_widget = $UI/CalendarWidget

var player_speed = 300
var interaction_range = 100
var calendar_visible = true
var can_interact_with = null

# Track if we've shown daily card yet
var shown_daily_card = false

func _ready():
	# Show daily card on first load
	if GameState.show_daily_card_on_wake and not shown_daily_card:
		shown_daily_card = true
		GameState.show_daily_card_on_wake = false
		get_tree().change_scene_to_file("res://scenes/ui/daily_card_scene.tscn")
		return
	
	_update_ui()

func _physics_process(delta):
	_handle_movement(delta)
	_check_interactions()

func _handle_movement(delta):
	var velocity = Vector2.ZERO
	
	# Get input
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	
	# Normalize and apply speed
	if velocity.length() > 0:
		velocity = velocity.normalized() * player_speed
	
	# Move player
	player.velocity = velocity
	player.move_and_slide()

func _check_interactions():
	var closest_object = null
	var closest_distance = interaction_range
	
	# Check distance to each interactable
	var objects = {
		"Bed": $Furniture/Bed,
		"Desk": $Furniture/Desk, 
		"Compact Mirror": $Furniture/CompactMirror,
		"Exit": $Furniture/Door
	}
	
	for name in objects:
		var obj = objects[name]
		var distance = player.global_position.distance_to(obj.global_position + obj.size / 2)
		if distance < closest_distance:
			closest_distance = distance
			closest_object = name
	
	# Update interaction prompt
	if closest_object != can_interact_with:
		can_interact_with = closest_object
		if can_interact_with:
			$UI/TopBar/InfoLabel.text = "Press E to interact with " + can_interact_with
		else:
			$UI/TopBar/InfoLabel.text = "Studio Apartment"

func _input(event):
	if event.is_action_pressed("interact") and can_interact_with:
		_interact_with(can_interact_with)
	
	if event.is_action_pressed("open_compact"):
		calendar_visible = !calendar_visible
		calendar_widget.visible = calendar_visible

func _interact_with(object_name: String):
	match object_name:
		"Bed":
			_show_popup("Your bed. Lumpy but yours. Sleep restores energy.")
		"Desk":
			_show_popup("Your tarot study desk. This is where you practice.")
		"Compact Mirror":
			_show_popup("Your magical compact. Opens to Croneslist and messages.")
		"Exit":
			_show_popup("Exit to the city. (Not implemented in demo)")

func _update_ui():
	money_label.text = "$" + str(GameState.current_money)
	energy_label.text = "Energy: " + str(GameState.energy) + "/" + str(GameState.max_energy)
	
	# Color code money based on rent situation
	if GameState.current_money < 100:
		money_label.modulate = Color(1, 0.5, 0.5)
	elif GameState.current_money < 700:
		money_label.modulate = Color(1, 1, 0.5)
	else:
		money_label.modulate = Color(0.5, 1, 0.5)

func _show_popup(text: String):
	# Simple popup for demo
	var popup = AcceptDialog.new()
	popup.dialog_text = text
	add_child(popup)
	popup.popup_centered()
	popup.show()