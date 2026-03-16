extends Node2D

# Train Station Scene - First explorable location

@onready var player = $Player
@onready var instructions = $UI/Instructions

const MOVE_SPEED = 200.0
var first_time = true

func _ready():
	# Show instructions briefly
	if first_time:
		var tween = create_tween()
		tween.tween_interval(3.0)
		tween.tween_property(instructions, "modulate:a", 0.0, 1.0)
		tween.tween_callback(func(): instructions.visible = false)

func _physics_process(delta):
	# Simple player movement
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * MOVE_SPEED
		player.velocity = velocity
		player.move_and_slide()
	
	# Check if player exits to the left
	if player.position.x < -50:
		_go_to_town()

func _go_to_town():
	# For now, go to the apartment
	# Later this would go to a town map
	print("Heading into town...")
	get_tree().change_scene_to_file("res://scenes/locations/studio_apartment.tscn")