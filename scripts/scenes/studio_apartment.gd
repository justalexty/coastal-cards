extends Node2D

# The witch's crappy studio apartment
# Safe haven but also financial pressure

class_name StudioApartment

@onready var rent_calendar = $UI/RentCalendar
@onready var money_display = $UI/MoneyDisplay
@onready var dialogue_box = $UI/DialogueBox

var days_until_rent: int = 30
var current_money: float = 25.0
var rent_amount: float = 700.0
var is_rent_paid: bool = false

var apartment_observations = [
	"The radiator clanks again. At least it works.",
	"That water stain on the ceiling has definitely grown.",
	"The view isn't much, but you can see a sliver of ocean between the buildings.",
	"Your kitchenette is barely big enough to brew a proper potion.",
	"The bed creaks, but it's yours. Your own place.",
	"Someday you'll afford curtains. Someday.",
	"The neighbors are loud, but at least they don't complain about incense.",
	"No room for a proper altar, but the windowsill will have to do."
]

func _ready():
	_update_displays()
	
	# Set up interactables
	$Interactables/Bed.interact.connect(_on_bed_interact)
	$Interactables/Window.interact.connect(_on_window_interact)
	$Interactables/Table.interact.connect(_on_table_interact)
	$Interactables/Kitchenette.interact.connect(_on_kitchenette_interact)

func _enter_tree():
	# Called when scene is entered
	if GameState.days_until_rent <= 0 and not GameState.is_rent_paid:
		_show_rent_warning()
	
	# Random observation about the apartment
	if randf() < 0.3:
		var observation = apartment_observations[randi() % apartment_observations.size()]
		show_thought(observation)

func _update_displays():
	rent_calendar.text = str(GameState.days_until_rent) + " days until rent"
	money_display.text = "$" + str(GameState.current_money)
	
	# Color code based on urgency
	if GameState.days_until_rent <= 3:
		rent_calendar.modulate = Color.RED
	elif GameState.days_until_rent <= 7:
		rent_calendar.modulate = Color.YELLOW
	else:
		rent_calendar.modulate = Color.WHITE

func _show_rent_warning():
	var warning_text = "Rent is due! You need $700 or you'll be charged late fees."
	if GameState.days_overdue > 0:
		warning_text = "Rent is %d days overdue! Late fee: $%d" % [GameState.days_overdue, _calculate_late_fee()]
	
	dialogue_box.show_dialogue(warning_text, "urgent")

func _calculate_late_fee() -> int:
	var days = GameState.days_overdue
	if days <= 3:
		return 25
	elif days <= 7:
		return 50
	else:
		return 100

func show_thought(text: String):
	# Show internal monologue
	dialogue_box.show_dialogue(text, "thought")

# Interactable callbacks
func _on_bed_interact():
	if GameState.energy < 30:
		# Rest option
		dialogue_box.show_choices(
			"You're exhausted. Rest?",
			["Sleep until morning", "Take a short nap", "Not yet"],
			_on_rest_choice
		)
	else:
		show_thought("Not tired yet. There's still work to do.")

func _on_rest_choice(choice: int):
	match choice:
		0:  # Sleep until morning
			GameState.advance_to_morning()
			GameState.energy = 100
			show_thought("A new day, a new chance to read the cards.")
		1:  # Short nap
			GameState.advance_time(2)
			GameState.energy = min(GameState.energy + 30, 100)
			show_thought("That helped a little.")
		2:  # Not yet
			pass

func _on_window_interact():
	var time_of_day = GameState.get_time_of_day()
	match time_of_day:
		"morning":
			show_thought("The city is waking up. Time to find a good spot for readings.")
		"afternoon":
			show_thought("Busy streets below. Prime time for business.")
		"evening":
			show_thought("The sunset paints the buildings gold. Almost beautiful.")
		"night":
			show_thought("City lights twinkle like earthbound stars.")

func _on_table_interact():
	# This is where tarot practice could happen
	dialogue_box.show_choices(
		"Your folding table and tarot deck.",
		["Practice a reading", "Check your cards", "Organize supplies"],
		_on_table_choice
	)

func _on_table_choice(choice: int):
	match choice:
		0:  # Practice reading
			get_tree().change_scene_to_file("res://scenes/tarot_practice/practice.tscn")
		1:  # Check cards
			show_thought("All 78 cards accounted for. Your most valuable possession.")
		2:  # Organize supplies
			show_thought("Candles: 3. Incense: Half a box. Cloth: Slightly worn but clean.")

func _on_kitchenette_interact():
	if GameState.current_money >= 5:
		dialogue_box.show_choices(
			"Make something to eat? ($5)",
			["Cook a simple meal", "Just water"],
			_on_kitchen_choice
		)
	else:
		show_thought("Can't afford groceries. Water it is.")

func _on_kitchen_choice(choice: int):
	match choice:
		0:  # Cook
			if GameState.current_money >= 5:
				GameState.current_money -= 5
				GameState.energy = min(GameState.energy + 20, 100)
				show_thought("Not much, but it's warm and filling.")
				_update_displays()
		1:  # Water
			show_thought("At least the tap water is free.")

# Called when leaving apartment
func _on_exit_pressed():
	get_tree().change_scene_to_file("res://scenes/city_map/city_map.tscn")