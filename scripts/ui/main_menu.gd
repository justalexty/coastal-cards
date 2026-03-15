extends Control

# Main Menu Controller

@onready var new_game_button = $MenuButtons/NewGameButton
@onready var continue_button = $MenuButtons/ContinueButton
@onready var settings_button = $MenuButtons/SettingsButton
@onready var quit_button = $MenuButtons/QuitButton

func _ready():
	# Connect buttons
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Check for save game
	if GameState.has_save_game():
		continue_button.disabled = false

func _on_new_game_pressed():
	# Start character creation
	get_tree().change_scene_to_file("res://scenes/compact_mirror/character_creation.tscn")

func _on_continue_pressed():
	# Load save and go to apartment
	GameState.load_game()
	get_tree().change_scene_to_file("res://scenes/locations/studio_apartment.tscn")

func _on_settings_pressed():
	# TODO: Settings menu
	print("Settings not implemented yet")

func _on_quit_pressed():
	get_tree().quit()