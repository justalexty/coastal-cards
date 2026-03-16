extends Node

# Handles Croneslist broom posting schedule
# Brooms appear ~6 times per day at random times
# Each listing lasts 10-40 minutes before being "sold"

# class_name CroneslistTimer

signal broom_posted(listing)
signal broom_sold(listing)
signal refresh_listings()

var active_broom_listings: Array = []
var next_post_time: float = 0.0
var posts_today: int = 0
var last_check_time: int = 0

# Posting windows (rough times when brooms tend to appear)
var posting_windows = [
	{"hour": 7, "variance": 90},   # Morning: 7am ± 1.5 hours
	{"hour": 10, "variance": 60},  # Mid-morning: 10am ± 1 hour
	{"hour": 13, "variance": 90},  # Lunch: 1pm ± 1.5 hours
	{"hour": 16, "variance": 60},  # Afternoon: 4pm ± 1 hour  
	{"hour": 19, "variance": 90},  # Evening: 7pm ± 1.5 hours
	{"hour": 22, "variance": 60}   # Late night: 10pm ± 1 hour
]

func _ready():
	# Check every game minute
	GameState.time_changed.connect(_check_listings)
	_schedule_next_post()

func _check_listings():
	var current_minutes = GameState.current_hour * 60 + GameState.current_minute
	
	# Check if we should post a new broom
	if current_minutes >= next_post_time and posts_today < 6:
		_post_new_broom()
	
	# Check if any listings have expired
	for listing in active_broom_listings:
		if current_minutes >= listing.expires_at:
			_sell_broom(listing)

func _schedule_next_post():
	# Pick a random posting window we haven't used yet today
	var available_windows = []
	var current_hour = GameState.current_hour
	
	for window in posting_windows:
		if window.hour > current_hour:
			available_windows.append(window)
	
	if available_windows.is_empty():
		# Tomorrow
		posts_today = 0
		return
	
	# Pick random window and time within it
	var window = available_windows[randi() % available_windows.size()]
	var variance_minutes = randf_range(-window.variance, window.variance)
	next_post_time = (window.hour * 60) + variance_minutes

func _post_new_broom():
	posts_today += 1
	
	# Generate the listing
	var broom_type = _get_random_broom_type()
	var is_premium = broom_type.retail > 500
	
	var price: int
	var duration: int
	var aesthetic: String
	
	if is_premium:
		# Premium brooms: 30-50% off retail
		var discount = randf_range(0.5, 0.7)
		price = int(broom_type.retail * discount)
		duration = randi_range(3, 8)  # Sells SUPER fast!
		aesthetic = "Previous owner's pride and joy"
	else:
		# Regular brooms
		price = randi_range(180, 280)
		duration = randi_range(10, 40)
		aesthetic = broom_aesthetics[randi() % broom_aesthetics.size()]
	
	var listing = {
		"id": Time.get_unix_time_from_system(),
		"name": broom_type.name,
		"price": price,
		"retail_price": broom_type.retail,
		"description": aesthetic,
		"is_premium": is_premium,
		"posted_at": GameState.current_hour * 60 + GameState.current_minute,
		"expires_at": GameState.current_hour * 60 + GameState.current_minute + duration,
		"seller": _generate_seller_name(is_premium)
	}
	
	active_broom_listings.append(listing)
	broom_posted.emit(listing)
	
	# Send notification based on player preferences
	if _should_notify_player(listing):
		_send_notification(listing)
	
	# Schedule next post
	_schedule_next_post()

func _sell_broom(listing):
	active_broom_listings.erase(listing)
	broom_sold.emit(listing)

func _get_random_broom_type():
	# Check if this should be a premium broom (once per week-ish)
	var days_since_last_premium = GameState.current_day - GameState.last_premium_broom_day
	var premium_chance = days_since_last_premium * 0.02  # 2% per day, caps at ~14% after a week
	
	if randf() < premium_chance:
		# PREMIUM BROOM!
		GameState.last_premium_broom_day = GameState.current_day
		return _get_premium_broom()
	
	# Regular brooms
	var types = [
		{"name": "Apprentice Ash", "speed": "steady", "retail": 300},
		{"name": "City Birch", "speed": "reliable", "retail": 300},
		{"name": "Old Hazel", "speed": "slow but wise", "retail": 250},
		{"name": "Student Maple", "speed": "basic", "retail": 250},
		{"name": "Coastal Driftwood", "speed": "swift in sea breeze", "retail": 450}
	]
	return types[randi() % types.size()]

func _get_premium_broom():
	var premium_types = [
		{"name": "Moonweave", "speed": "silent & swift", "retail": 1500},
		{"name": "Stormchaser", "speed": "lightning fast, all-weather", "retail": 3000},
		{"name": "Twilight Willow", "speed": "graceful", "retail": 1200}
	]
	return premium_types[randi() % premium_types.size()]

func _generate_seller_name(is_premium: bool = false) -> String:
	if is_premium:
		# Premium sellers have different vibe
		var premium_names = [
			"UpgradingToStormchaser", "GotPromoted", "TooManyBrooms",
			"CollectorDownsizing", "MovingAbroad", "InheritedBetterOne",
			"WifeNaggedMe", "SpringCleaning2026"
		]
		return premium_names[randi() % premium_names.size()]
	
	# Regular desperate sellers
	var names = [
		"BroomlessinBrooklyn", "WitchOnABudget", "FlyingOnFumes",
		"DesperateDiviner", "MovingMustSell", "CantMakeRent",
		"SkywardBargains", "LastMinuteListings", "QuickSaleQuinn"
	]
	return names[randi() % names.size()]

func _should_notify_player(listing: Dictionary) -> bool:
	# Check if notifications are enabled at all
	if not GameState.croneslist_notifications_enabled:
		return false
	
	# Check notification preferences
	var prefs = GameState.croneslist_notification_prefs
	
	# Premium brooms
	if listing.is_premium and prefs.get("premium_brooms", false):
		return true
	
	# Regular brooms under certain price
	if not listing.is_premium and prefs.get("regular_brooms", false):
		var max_price = prefs.get("max_price", 999)
		if listing.price <= max_price:
			return true
	
	# Specific searches (if player is looking for something particular)
	var search_terms = prefs.get("search_terms", [])
	for term in search_terms:
		if term.to_lower() in listing.name.to_lower():
			return true
	
	return false

func _send_notification(listing):
	var message: String
	
	if listing.is_premium:
		# PREMIUM ALERT - Maximum drama!
		var savings = listing.retail_price - listing.price
		message = "🚨 PREMIUM BROOM ALERT!!! 🚨\n"
		message += "%s listed at $%d (retail $%d)!\n" % [listing.name, listing.price, listing.retail_price]
		message += "That's $%d OFF! GO GO GO GO GO!" % savings
		
		# Special urgent sound
		AudioManager.play_notification("premium_broom_alert")
		
		# Make the compact mirror glow/pulse
		CompactMirror.start_urgent_glow()
	else:
		# Regular notification
		message = "BROOM ALERT! %s posted for $%d - hurry!" % [listing.name, listing.price]
		AudioManager.play_notification("croneslist_alert")
	
	CompactMirror.add_message("Croneslist", message)

func get_minutes_remaining(listing) -> int:
	var current_minutes = GameState.current_hour * 60 + GameState.current_minute
	return max(0, listing.expires_at - current_minutes)

func try_purchase_broom(listing_id: int) -> bool:
	# Find the listing
	for listing in active_broom_listings:
		if listing.id == listing_id:
			if GameState.current_money >= listing.price:
				GameState.spend_money(listing.price)
				GameState.has_broom = true
				GameState.broom_data = {
					"name": listing.name,
					"description": listing.description,
					"purchase_price": listing.price,
					"purchase_day": GameState.current_day
				}
				
				# Remove from active listings
				active_broom_listings.erase(listing)
				
				return true
			else:
				return false  # Can't afford
	
	# Listing already sold
	return false

var broom_aesthetics = [
	"Bristles like a bad haircut",
	"Duct tape holds the handle", 
	"Suspicious burn marks",
	"Smells faintly of wet dog",
	"Previous owner bedazzled it",
	"Painted neon green",
	"Missing half the bristles (still flies)",
	"Handle is two different woods",
	"Covered in band stickers", 
	"Looks like it was found in a dumpster"
]