extends Control

# Croneslist UI accessed through compact mirror
# Shows ONLY brooms (the only thing worth refreshing for)

class_name CroneslistInterface

@onready var listings_container = $Panel/ScrollContainer/VBox
@onready var no_listings_label = $Panel/NoListings
@ontml var refresh_timer = $Panel/RefreshTimer
@onready var sell_button = $Panel/TopBar/SellButton
@onready var balance_label = $Panel/TopBar/BalanceLabel
@onready var settings_button = $Panel/TopBar/SettingsButton
@onready var notification_indicator = $Panel/TopBar/NotificationIndicator

var croneslist_timer: CroneslistTimer
var is_showing_sell_interface: bool = false
var is_showing_settings: bool = false

func _ready():
	croneslist_timer = get_node("/root/CroneslistTimer")
	croneslist_timer.broom_posted.connect(_on_broom_posted)
	croneslist_timer.broom_sold.connect(_on_broom_sold)
	
	# First time tutorial
	if not GameState.has_seen_croneslist_tutorial:
		_show_first_time_tutorial()
	
	# Set up sell button
	if GameState.has_broom:
		sell_button.visible = true
		sell_button.text = "Sell Your Broom"
		sell_button.pressed.connect(_on_sell_button_pressed)
		
		# Color based on desperation
		if GameState.days_until_rent <= 3 and not GameState.is_rent_paid:
			sell_button.modulate = Color(1, 0.8, 0.8)  # Reddish - you need money
			sell_button.text = "Sell for Rent Money"
	else:
		sell_button.visible = false
	
	# Update balance
	balance_label.text = "Balance: $%d" % GameState.current_money
	
	# Set up settings button
	settings_button.pressed.connect(_on_settings_pressed)
	_update_notification_indicator()
	
	_refresh_display()

func _update_notification_indicator():
	# Show indicator based on notification status
	if GameState.croneslist_notifications_enabled:
		notification_indicator.visible = true
		
		var active_count = 0
		var prefs = GameState.croneslist_notification_prefs
		if prefs.get("regular_brooms", false):
			active_count += 1
		if prefs.get("premium_brooms", false):
			active_count += 1
		if prefs.get("search_terms", []).size() > 0:
			active_count += prefs["search_terms"].size()
		
		if active_count > 0:
			notification_indicator.text = "🔔 %d" % active_count
			notification_indicator.modulate = Color(0.8, 1, 0.8)
		else:
			notification_indicator.text = "🔔"
			notification_indicator.modulate = Color(0.7, 0.7, 0.7)
	else:
		notification_indicator.visible = false

func _on_settings_pressed():
	# Show settings panel
	is_showing_settings = true
	$Panel/ScrollContainer.visible = false
	
	var settings = preload("res://scenes/ui/croneslist_notifications.tscn").instantiate()
	$Panel.add_child(settings)
	
	settings.preferences_saved.connect(_on_settings_closed)
	settings.tree_exited.connect(_on_settings_closed)

func _on_settings_closed():
	is_showing_settings = false
	$Panel/ScrollContainer.visible = true
	_update_notification_indicator()
	_refresh_display()

func _show_first_time_tutorial():
	GameState.has_seen_croneslist_tutorial = true
	
	# Create welcome dialog
	var dialog = ConfirmationDialog.new()
	dialog.title = "Welcome to Croneslist!"
	dialog.dialog_text = "The witch community's used broom marketplace.\n\n"
	dialog.dialog_text += "🧹 Brooms post throughout the day\n"
	dialog.dialog_text += "⏱️ Each listing only lasts 10-40 minutes\n"
	dialog.dialog_text += "💰 All brooms work - they just look rough\n\n"
	dialog.dialog_text += "Want notifications when brooms matching your criteria post?"
	
	dialog.get_ok_button().text = "Set up notifications"
	dialog.get_cancel_button().text = "I'll check manually"
	
	get_tree().root.add_child(dialog)
	dialog.popup_centered(Vector2(400, 300))
	
	dialog.confirmed.connect(_on_tutorial_notifications_yes)
	dialog.canceled.connect(_on_tutorial_notifications_no)
	dialog.popup_hide.connect(dialog.queue_free)

func _on_tutorial_notifications_yes():
	# Open settings with recommendations
	_on_settings_pressed()
	
	# Pre-fill recommended settings
	GameState.croneslist_notifications_enabled = true
	GameState.croneslist_notification_prefs["premium_brooms"] = true
	GameState.croneslist_notification_prefs["regular_brooms"] = true
	GameState.croneslist_notification_prefs["max_price"] = 220
	
	# Show tip
	var tip = AcceptDialog.new()
	tip.dialog_text = "Recommended: Enable notifications for:\n"
	tip.dialog_text += "✓ Premium brooms (super rare!)\n"
	tip.dialog_text += "✓ Regular brooms under $220\n\n"
	tip.dialog_text += "This way you'll only be notified for good deals."
	get_tree().root.add_child(tip)
	tip.popup_centered()
	tip.popup_hide.connect(tip.queue_free)

func _on_tutorial_notifications_no():
	# Acknowledge choice
	var tip = AcceptDialog.new()
	tip.dialog_text = "No problem! Check back whenever you want.\n\n"
	tip.dialog_text += "Tip: Brooms tend to post more often:\n"
	tip.dialog_text += "• Morning (7-9 AM)\n"
	tip.dialog_text += "• Lunch (12-1 PM)\n"
	tip.dialog_text += "• Evening (6-8 PM)\n\n"
	tip.dialog_text += "You can always enable notifications later in settings."
	get_tree().root.add_child(tip)
	tip.popup_centered()
	tip.popup_hide.connect(tip.queue_free)

func _process(delta):
	# Update timers on active listings
	for child in listings_container.get_children():
		if child.has_method("update_timer"):
			child.update_timer()

func _refresh_display():
	# Clear current display
	for child in listings_container.get_children():
		child.queue_free()
	
	# Show active broom listings
	if croneslist_timer.active_broom_listings.is_empty():
		no_listings_label.visible = true
		no_listings_label.text = "No brooms available right now.\nCheck back soon - they post throughout the day!"
	else:
		no_listings_label.visible = false
		
		for listing in croneslist_timer.active_broom_listings:
			_create_listing_ui(listing)

func _create_listing_ui(listing: Dictionary):
	var panel = preload("res://scenes/ui/broom_listing.tscn").instantiate()
	
	# Check if this is the player's listing
	if listing.get("is_player_listing", false):
		# Style differently
		panel.modulate = Color(0.9, 0.95, 1.0)  # Slight blue tint
		panel.get_node("NameLabel").text = "YOUR LISTING: " + listing.name
		panel.get_node("PriceLabel").text = "$%d" % listing.price
		panel.get_node("DescLabel").text = listing.description
		panel.get_node("SellerLabel").text = "This is YOUR broom!"
		
		# Can't buy your own broom
		panel.get_node("BuyButton").visible = false
		
		# Show cancel button instead
		var cancel_button = Button.new()
		cancel_button.text = "Cancel Listing"
		cancel_button.pressed.connect(_on_cancel_listing.bind(listing))
		panel.get_node("ButtonContainer").add_child(cancel_button)
		
	# Regular listings
	elif listing.get("is_premium", false):
		# PREMIUM STYLING
		panel.modulate = Color(1.2, 1.1, 0.9)  # Slight golden glow
		panel.get_node("NameLabel").text = "✨ %s ✨" % listing.name
		panel.get_node("PriceLabel").text = "$%d" % listing.price
		
		# Show savings
		var savings_label = Label.new()
		savings_label.text = "SAVE $%d!" % (listing.retail_price - listing.price)
		savings_label.add_theme_color_override("font_color", Color(0.2, 1, 0.2))
		panel.get_node("PriceContainer").add_child(savings_label)
		
		panel.get_node("DescLabel").text = listing.description + "\n⚡ PREMIUM BROOM - RARE DEAL! ⚡"
		panel.get_node("SellerLabel").text = "Lucky find from %s" % listing.seller
	else:
		# Regular listing
		panel.get_node("NameLabel").text = listing.name
		panel.get_node("PriceLabel").text = "$%d" % listing.price
		panel.get_node("DescLabel").text = listing.description
		panel.get_node("SellerLabel").text = "Posted by %s" % listing.seller
	
	# Timer display
	var timer_label = panel.get_node("TimerLabel")
	var minutes_left = croneslist_timer.get_minutes_remaining(listing)
	timer_label.text = "%d min left" % minutes_left
	
	# Color code based on time remaining
	if minutes_left <= 5:
		timer_label.modulate = Color(1, 0.3, 0.3)  # Red - about to expire!
		panel.get_node("UrgentIcon").visible = true
	elif minutes_left <= 10:
		timer_label.modulate = Color(1, 0.8, 0.3)  # Orange - hurry!
	else:
		timer_label.modulate = Color(0.8, 1, 0.8)  # Green - you have time
	
	# Buy button
	var buy_button = panel.get_node("BuyButton")
	buy_button.text = "BUY NOW"
	
	if GameState.current_money < listing.price:
		buy_button.disabled = true
		buy_button.text = "Can't afford"
	else:
		buy_button.pressed.connect(_on_buy_pressed.bind(listing))
	
	# Custom update function for timer
	panel.set_script(preload("res://scripts/ui/listing_timer.gd"))
	panel.listing_data = listing
	panel.timer_label = timer_label
	
	listings_container.add_child(panel)

func _on_buy_pressed(listing: Dictionary):
	# Quick confirmation
	var confirm = AcceptDialog.new()
	confirm.dialog_text = "Buy %s for $%d?\n\n\"%s\"\n\nIt's ugly but it flies!" % [
		listing.name, 
		listing.price, 
		listing.description
	]
	confirm.add_cancel_button("Wait")
	get_tree().root.add_child(confirm)
	confirm.popup_centered()
	
	await confirm.confirmed
	confirm.queue_free()
	
	# Try to purchase
	if croneslist_timer.try_purchase_broom(listing.id):
		_show_success(listing)
	else:
		_show_too_late()

func _show_success(listing: Dictionary):
	var success = AcceptDialog.new()
	success.dialog_text = "You got it! One %s, slightly used.\n\n%s\n\nBut who cares? You can FLY again!" % [
		listing.name,
		listing.description
	]
	get_tree().root.add_child(success)
	success.popup_centered()
	success.popup_hide.connect(success.queue_free)
	
	# Refresh the display
	_refresh_display()
	
	# Play success sound
	AudioManager.play_sfx("purchase_success")

func _show_too_late():
	var fail = AcceptDialog.new()
	fail.dialog_text = "Too late! Someone else just bought it.\n\nBrooms sell FAST on Croneslist. You have to be quick!"
	get_tree().root.add_child(fail)
	fail.popup_centered()
	fail.popup_hide.connect(fail.queue_free)
	
	# Refresh to remove sold listing
	_refresh_display()

func _on_broom_posted(listing: Dictionary):
	# Refresh to show new listing
	_refresh_display()
	
	# Flash the screen or something to draw attention
	var flash = ColorRect.new()
	flash.color = Color(1, 1, 0, 0.3)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)
	
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0, 0.5)
	tween.tween_callback(flash.queue_free)

func _on_broom_sold(listing: Dictionary):
	# Just refresh to remove it
	_refresh_display()

func _on_sell_button_pressed():
	# Switch to selling interface
	is_showing_sell_interface = true
	
	# Hide listings, show sell panel
	$Panel/ScrollContainer.visible = false
	
	# Create sell interface
	var sell_interface = preload("res://scenes/ui/croneslist_selling.tscn").instantiate()
	$Panel.add_child(sell_interface)
	
	# Connect to know when done
	sell_interface.broom_listed.connect(_on_player_broom_listed)
	sell_interface.tree_exited.connect(_on_sell_interface_closed)

func _on_player_broom_listed(listing_data: Dictionary):
	# Return to main view
	is_showing_sell_interface = false
	$Panel/ScrollContainer.visible = true
	
	# Update sell button
	sell_button.visible = false
	
	# Refresh to show their listing
	_refresh_display()

func _on_sell_interface_closed():
	is_showing_sell_interface = false
	$Panel/ScrollContainer.visible = true
	_refresh_display()

func _on_cancel_listing(listing: Dictionary):
	# Confirm cancellation
	var dialog = ConfirmationDialog.new()
	dialog.dialog_text = "Cancel your listing and take your broom back?"
	
	get_tree().root.add_child(dialog)
	dialog.popup_centered()
	
	await dialog.confirmed
	dialog.queue_free()
	
	# Remove from active listings
	croneslist_timer.active_broom_listings.erase(listing)
	
	# Give broom back
	GameState.has_broom = true
	GameState.broom_data = {
		"name": listing.name,
		"description": listing.description,
		"purchase_price": listing.price
	}
	
	# Show button again
	sell_button.visible = true
	
	# Refresh
	_refresh_display()
	
	# Notification
	var notify = AcceptDialog.new()
	notify.dialog_text = "Listing cancelled. At least you have your broom back..."
	get_tree().root.add_child(notify)
	notify.popup_centered()
	notify.popup_hide.connect(notify.queue_free)