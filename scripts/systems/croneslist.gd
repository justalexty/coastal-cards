extends Control

# Croneslist - The witch community's buy/sell/trade board
# Access through the magic compact's network features

class_name Croneslist

signal listing_purchased(item_data)
signal listing_posted(item_data)

@onready var listings_container = $ScrollContainer/ListingsContainer
@onready var money_label = $MoneyLabel
@onready var refresh_button = $RefreshButton

# Broom aesthetics (all fly fine, just look rough)
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

# Base broom types that might appear used
var used_broom_types = [
	{"name": "Apprentice Ash", "base_price": 300, "speed": "steady", "years_old": "3-5"},
	{"name": "City Birch", "base_price": 300, "speed": "reliable", "years_old": "2-4"},
	{"name": "Coastal Driftwood", "base_price": 450, "speed": "swift", "years_old": "1-3"},
	{"name": "Old Hazel", "base_price": 250, "speed": "slow", "years_old": "5-10"},
	{"name": "Student Maple", "base_price": 250, "speed": "basic", "years_old": "4-6"}
]

var current_listings = []

func _ready():
	refresh_listings()
	refresh_button.pressed.connect(refresh_listings)
	_update_money_display()

func refresh_listings():
	# Clear old listings
	for child in listings_container.get_children():
		child.queue_free()
	
	current_listings.clear()
	
	# Generate 3-6 random listings
	var num_listings = randi_range(3, 6)
	
	# Always have at least one cheap broom available
	_add_broom_listing(0, true)  # Guaranteed cheap option
	
	# Random other listings
	for i in range(1, num_listings):
		if randf() < 0.7:  # 70% chance of broom
			_add_broom_listing(i, false)
		else:  # 30% chance of other items
			_add_misc_listing(i)

func _add_broom_listing(index: int, guaranteed_cheap: bool = false):
	var broom = used_broom_types[randi() % used_broom_types.size()]
	var condition_keys = broom_conditions.keys()
	var condition: String
	
	if guaranteed_cheap:
		# Make sure there's always one affordable option
		condition = condition_keys[randi_range(2, 3)]  # fair or needs_work
	else:
		condition = condition_keys[randi() % condition_keys.size()]
	
	var condition_data = broom_conditions[condition]
	var price = int(broom.base_price * condition_data.price_mult)
	
	var listing = {
		"type": "broom",
		"name": broom.name,
		"condition": condition,
		"price": price,
		"speed": broom.speed,
		"years_old": broom.years_old,
		"reliability": condition_data.reliability,
		"description": condition_data.description,
		"seller": _generate_seller_name(),
		"posted": _generate_post_time()
	}
	
	current_listings.append(listing)
	_create_listing_ui(listing)

func _add_misc_listing(index: int):
	var misc_items = [
		{"name": "Crystal Ball (cloudy)", "price": 45, "type": "equipment"},
		{"name": "Tarot Deck (missing 3 cards)", "price": 15, "type": "equipment"},
		{"name": "Silver Candlesticks", "price": 80, "type": "equipment"},
		{"name": "Enchanted Tablecloth", "price": 60, "type": "equipment"},
		{"name": "Incense Bundle (6 months)", "price": 35, "type": "supplies"},
		{"name": "Protective Charms Set", "price": 40, "type": "equipment"}
	]
	
	var item = misc_items[randi() % misc_items.size()]
	
	var listing = {
		"type": item.type,
		"name": item.name,
		"price": item.price,
		"seller": _generate_seller_name(),
		"posted": _generate_post_time()
	}
	
	current_listings.append(listing)
	_create_listing_ui(listing)

func _generate_seller_name() -> String:
	var names = [
		"MoonMaven", "CrystalCrone", "UrbanWitch22", "BroomlessinBrooklyn",
		"StardustSeller", "ThriftyThaumaturge", "WitchyDeals", "CauldronKate",
		"HexAndTheCity", "MagicMarge", "EnchantedEstate", "SpellboundSales"
	]
	return names[randi() % names.size()]

func _generate_post_time() -> String:
	var times = [
		"2 hours ago", "5 hours ago", "yesterday", "2 days ago",
		"3 days ago", "last week", "just now", "1 hour ago"
	]
	return times[randi() % times.size()]

func _create_listing_ui(listing: Dictionary):
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 80)
	
	var hbox = HBoxContainer.new()
	panel.add_child(hbox)
	
	# Main info
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)
	
	# Title
	var title = Label.new()
	title.text = listing.name
	title.add_theme_font_size_override("font_size", 16)
	info_vbox.add_child(title)
	
	# Details
	var details = Label.new()
	if listing.type == "broom":
		details.text = "Condition: %s | %s | %s years old" % [listing.condition, listing.speed, listing.years_old]
		if listing.condition == "needs_work":
			details.modulate = Color(1, 0.7, 0.7)  # Red tint for risky items
	else:
		details.text = "Type: %s" % listing.type
	
	details.add_theme_font_size_override("font_size", 12)
	info_vbox.add_child(details)
	
	# Seller info
	var seller = Label.new()
	seller.text = "Posted by %s %s" % [listing.seller, listing.posted]
	seller.add_theme_font_size_override("font_size", 10)
	seller.modulate = Color(0.7, 0.7, 0.7)
	info_vbox.add_child(seller)
	
	# Price and buy button
	var price_vbox = VBoxContainer.new()
	hbox.add_child(price_vbox)
	
	var price_label = Label.new()
	price_label.text = "$%d" % listing.price
	price_label.add_theme_font_size_override("font_size", 18)
	
	if listing.price <= GameState.current_money:
		price_label.modulate = Color(0.7, 1, 0.7)  # Green if affordable
	else:
		price_label.modulate = Color(1, 0.7, 0.7)  # Red if too expensive
	
	price_vbox.add_child(price_label)
	
	var buy_button = Button.new()
	buy_button.text = "Contact"
	buy_button.disabled = listing.price > GameState.current_money
	buy_button.pressed.connect(_on_buy_pressed.bind(listing))
	price_vbox.add_child(buy_button)
	
	listings_container.add_child(panel)

func _on_buy_pressed(listing: Dictionary):
	if listing.type == "broom":
		# Show confirmation with risk warning for poor condition
		var warning = ""
		if listing.condition == "needs_work":
			warning = "\n\nWARNING: This broom may fail during flight!"
		elif listing.condition == "fair":
			warning = "\n\nNote: This broom may have occasional issues."
		
		DialogueManager.show_choices(
			"Buy %s for $%d?%s" % [listing.name, listing.price, warning],
			["Yes, I need to fly!", "No, too risky", "Try to negotiate"],
			_on_purchase_choice.bind(listing)
		)
	else:
		# Non-broom items
		DialogueManager.show_choices(
			"Buy %s for $%d?" % [listing.name, listing.price],
			["Yes", "No"],
			_on_purchase_choice.bind(listing)
		)

func _on_purchase_choice(choice: int, listing: Dictionary):
	match choice:
		0:  # Yes
			GameState.current_money -= listing.price
			listing_purchased.emit(listing)
			
			if listing.type == "broom":
				GameState.has_broom = true
				GameState.broom_data = listing
				DialogueManager.show_dialogue(
					"You are now the proud owner of a used %s! Time to test those flying skills..." % listing.name
				)
			else:
				# Add to inventory
				GameState.inventory.append(listing)
				DialogueManager.show_dialogue(
					"You purchased: %s" % listing.name
				)
			
			# Remove from listings
			var index = current_listings.find(listing)
			if index >= 0:
				listings_container.get_child(index).queue_free()
				current_listings.remove_at(index)
			
			_update_money_display()
			
		1:  # No
			pass
			
		2:  # Negotiate (only for brooms)
			if randf() < 0.3:  # 30% success chance
				var discount = randi_range(10, 30)
				listing.price = int(listing.price * (1.0 - discount / 100.0))
				DialogueManager.show_dialogue(
					"The seller agrees to $%d! That's %d%% off!" % [listing.price, discount]
				)
				# Update the UI
				refresh_listings()
			else:
				DialogueManager.show_dialogue(
					"The seller says the price is firm. Take it or leave it."
				)

func _update_money_display():
	money_label.text = "Your funds: $%d" % GameState.current_money