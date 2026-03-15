extends Node

# Global game state manager
# Handles save/load and tracks all persistent data

class_name GameStateManager

# Signals
signal time_changed
signal money_changed(amount)

# Financial state
var current_money: float = 25.0
var days_until_rent: int = 30
var rent_amount: float = 700.0
var is_rent_paid: bool = false
var days_overdue: int = 0
var lifetime_earnings: float = 0.0

# Character data
var player_character: Dictionary = {}
var witch_name: String = ""

# Broom status
var has_broom: bool = false
var broom_data: Dictionary = {}  # Stores type, condition, reliability
var sold_broom_for_rent: bool = false
var sold_broom_data: Dictionary = {}  # Remember what we sacrificed
var hours_since_broom_sale: int = 0
var has_shown_rent_crisis: bool = false

# Business progression
var reputation: float = 0.0
var total_readings: int = 0
var successful_readings: int = 0
var permits: Array = []  # ["market_square", "university_district"]

# Time and energy
var current_hour: int = 9  # 24-hour clock
var current_minute: int = 0  # 0-59
var energy: int = 100
var max_energy: int = 100
var current_mood: String = "neutral"  # Set by daily card

# Calendar reference (day tracking moved to CalendarSystem)
var calendar: CalendarSystem

# Daily card system
var show_daily_card_on_wake: bool = true
var skipped_daily_draw: bool = false
var tarot_journal: Array = []  # Stores daily card draws and interpretations

# Inventory
var inventory: Array = []
var table_upgrades: Dictionary = {
	"cloth": "worn",
	"candles": false,
	"crystal_ball": false,
	"incense": 5  # Number of uses left
}

# Tarot mastery - track understanding of each card
var card_mastery: Dictionary = {}  # card_name: mastery_level (0-100)

# Client history
var clients_served: Array = []
var regular_clients: Array = []

# Current game flags
var tutorial_complete: bool = false
var has_croneslist_access: bool = true  # Unlocked from start
var croneslist_notifications_enabled: bool = false  # Off by default
var has_seen_croneslist_tutorial: bool = false  # Show notification prompt once
var current_location: String = "studio_apartment"
var last_croneslist_check: int = 0  # Day last checked
var missed_broom_count: int = 0  # Track how many you've missed
var last_premium_broom_day: int = -7  # Start ready for premium
var missed_premium_count: int = 0  # Extra painful to track

# Notification preferences
var croneslist_notification_prefs: Dictionary = {
	"regular_brooms": false,
	"premium_brooms": false,
	"max_price": 250,
	"search_terms": [],
	"other_items": false  # For future: crystals, cards, etc.
}

func _ready():
	# Initialize save directory
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

func advance_time(hours: int, minutes: int = 0):
	current_minute += minutes
	
	while current_minute >= 60:
		current_minute -= 60
		current_hour += 1
	
	current_hour += hours
	
	while current_hour >= 24:
		current_hour -= 24
		advance_day()
	
	# Drain energy over time
	var total_minutes = (hours * 60) + minutes
	energy = max(0, energy - (total_minutes / 12))  # 5 energy per hour

func advance_day():
	# Use calendar system for day tracking
	if calendar:
		calendar.advance_day()
	
	# Rent tracking
	var date_info = calendar.get_current_date_info() if calendar else {}
	if date_info.get("day", 1) == 1:
		# First of the month - rent due!
		if not is_rent_paid:
			days_overdue = 1
			days_until_rent = 0
		else:
			# Reset for new month
			is_rent_paid = false
			days_until_rent = 30
			days_overdue = 0
	elif days_overdue > 0:
		days_overdue += 1
	else:
		days_until_rent = date_info.get("days_until_rent", 30)
	
	# Sleep refreshes energy to full
	energy = max_energy
	
	# Daily events
	_trigger_daily_events()
	
	# Show daily card scene for new day
	show_daily_card_on_wake = true

func advance_to_morning():
	current_hour = 7
	advance_day()
	energy = max_energy

func has_save_game() -> bool:
	# Check if save file exists
	return FileAccess.file_exists("user://savegame.dat")

func save_game():
	var save_file = FileAccess.open("user://savegame.dat", FileAccess.WRITE)
	if save_file:
		var save_data = {
			"money": current_money,
			"energy": energy,
			"reputation": reputation,
			"day": Calendar.get_current_date_info() if Calendar else {}
		}
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()

func load_game():
	if FileAccess.file_exists("user://savegame.dat"):
		var save_file = FileAccess.open("user://savegame.dat", FileAccess.READ)
		var save_data = JSON.parse_string(save_file.get_as_text())
		save_file.close()
		
		current_money = save_data.get("money", 25)
		energy = save_data.get("energy", 100)
		reputation = save_data.get("reputation", 0)

func _trigger_daily_events():
	var events = []
	
	# Rent reminders
	if days_until_rent == 7:
		events.append({"type": "rent_reminder", "text": "One week until rent is due!"})
	elif days_until_rent == 3:
		events.append({"type": "rent_warning", "text": "Rent due in 3 days! You need $700!"})
	elif days_until_rent == 0:
		events.append({"type": "rent_due", "text": "RENT IS DUE TODAY! $700 needed!"})
	
	# Croneslist updates
	if has_croneslist_access and randf() < 0.3:
		events.append({"type": "croneslist", "text": "New listings on Croneslist!"})
	
	return events

func get_time_of_day() -> String:
	if current_hour < 6 or current_hour >= 22:
		return "night"
	elif current_hour < 12:
		return "morning"
	elif current_hour < 18:
		return "afternoon"
	else:
		return "evening"

func can_afford(amount: float) -> bool:
	return current_money >= amount

func spend_money(amount: float) -> bool:
	if can_afford(amount):
		current_money -= amount
		return true
	return false

func earn_money(amount: float):
	current_money += amount
	lifetime_earnings += amount

func pay_rent() -> bool:
	if can_afford(rent_amount):
		spend_money(rent_amount)
		is_rent_paid = true
		days_overdue = 0
		days_until_rent = 30
		return true
	return false

func get_late_fee() -> float:
	if days_overdue <= 3:
		return 25.0
	elif days_overdue <= 7:
		return 50.0
	else:
		return 100.0

func has_permit(location: String) -> bool:
	return location in permits

func add_permit(location: String):
	if not has_permit(location):
		permits.append(location)

func improve_reputation(amount: float):
	reputation = clamp(reputation + amount, 0.0, 100.0)

func get_reputation_level() -> String:
	if reputation < 20:
		return "Unknown"
	elif reputation < 40:
		return "Novice"
	elif reputation < 60:
		return "Known"
	elif reputation < 80:
		return "Respected"
	else:
		return "Renowned"

func get_reading_price_multiplier() -> float:
	# Base multiplier based on reputation
	return 1.0 + (reputation / 100.0)

func save_game(slot: int = 0):
	var save_data = {
		"version": 1,
		"timestamp": Time.get_datetime_string_from_system(),
		"financial": {
			"money": current_money,
			"rent_due": days_until_rent,
			"rent_paid": is_rent_paid,
			"overdue": days_overdue
		},
		"character": player_character,
		"progression": {
			"reputation": reputation,
			"readings": total_readings,
			"successful": successful_readings,
			"permits": permits
		},
		"time": {
			"day": current_day,
			"hour": current_hour,
			"energy": energy
		},
		"inventory": {
			"items": inventory,
			"upgrades": table_upgrades,
			"has_broom": has_broom,
			"broom_data": broom_data
		},
		"mastery": card_mastery,
		"flags": {
			"tutorial": tutorial_complete,
			"location": current_location
		}
	}
	
	var save_file = FileAccess.open("user://saves/slot_%d.save" % slot, FileAccess.WRITE)
	save_file.store_var(save_data)
	save_file.close()

func load_game(slot: int = 0) -> bool:
	var save_path = "user://saves/slot_%d.save" % slot
	
	if not FileAccess.file_exists(save_path):
		return false
	
	var save_file = FileAccess.open(save_path, FileAccess.READ)
	var save_data = save_file.get_var()
	save_file.close()
	
	# Restore all data
	current_money = save_data.financial.money
	days_until_rent = save_data.financial.rent_due
	is_rent_paid = save_data.financial.rent_paid
	days_overdue = save_data.financial.overdue
	
	player_character = save_data.character
	reputation = save_data.progression.reputation
	total_readings = save_data.progression.readings
	successful_readings = save_data.progression.successful
	permits = save_data.progression.permits
	
	current_day = save_data.time.day
	current_hour = save_data.time.hour
	energy = save_data.time.energy
	
	inventory = save_data.inventory.items
	table_upgrades = save_data.inventory.upgrades
	has_broom = save_data.inventory.has_broom
	broom_data = save_data.inventory.broom_data
	
	card_mastery = save_data.mastery
	tutorial_complete = save_data.flags.tutorial
	current_location = save_data.flags.location
	
	return true

# Make it a singleton
func _init():
	if not Engine.has_singleton("GameState"):
		Engine.register_singleton("GameState", self)