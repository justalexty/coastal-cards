extends Control

# Player's selling interface for Croneslist
# The hardest decisions in the game happen here

class_name CroneslistSelling

signal broom_listed(listing_data)
signal listing_sold(amount)

@onready var sell_button = $Panel/SellButton
@onready var price_slider = $Panel/PriceSlider
@onready var price_label = $Panel/PriceLabel
@onready var time_slider = $Panel/TimeSlider
@onready var time_label = $Panel/TimeLabel
@onready var preview_panel = $Panel/PreviewPanel

var suggested_price: int = 0
var player_listing = null

func _ready():
	if not GameState.has_broom:
		_show_no_broom()
		return
	
	_setup_selling_interface()
	
	price_slider.value_changed.connect(_on_price_changed)
	time_slider.value_changed.connect(_on_time_changed)
	sell_button.pressed.connect(_on_sell_pressed)

func _show_no_broom():
	$Panel/NoBroomLabel.visible = true
	$Panel/NoBroomLabel.text = "You don't have a broom to sell.\n\n(Walking everywhere builds character, right?)"
	sell_button.visible = false
	price_slider.visible = false
	time_slider.visible = false

func _setup_selling_interface():
	var broom = GameState.broom_data
	
	# Calculate suggested price based on what you paid and condition
	var purchase_price = broom.get("purchase_price", 200)
	suggested_price = int(purchase_price * 0.8)  # 20% depreciation
	
	# Price slider from 50% to 120% of suggested
	price_slider.min_value = int(suggested_price * 0.5)
	price_slider.max_value = int(suggested_price * 1.2)
	price_slider.value = suggested_price
	
	# Time slider 5-60 minutes
	time_slider.min_value = 5
	time_slider.max_value = 60
	time_slider.value = 30
	
	_update_preview()

func _on_price_changed(value: float):
	price_label.text = "$%d" % int(value)
	
	# Color code based on competitiveness
	if value < suggested_price * 0.7:
		price_label.modulate = Color(0.5, 1, 0.5)  # Green - will sell fast
		$Panel/PriceHint.text = "Priced to move!"
	elif value > suggested_price * 1.1:
		price_label.modulate = Color(1, 0.5, 0.5)  # Red - might not sell
		$Panel/PriceHint.text = "Might sit a while..."
	else:
		price_label.modulate = Color.WHITE
		$Panel/PriceHint.text = "Fair price"
	
	_update_preview()

func _on_time_changed(value: float):
	time_label.text = "%d minutes" % int(value)
	_update_preview()

func _update_preview():
	var broom = GameState.broom_data
	preview_panel.get_node("NameLabel").text = broom.name
	preview_panel.get_node("PriceLabel").text = "$%d" % int(price_slider.value)
	preview_panel.get_node("DescLabel").text = broom.description
	preview_panel.get_node("SellerLabel").text = "Posted by YOU"
	preview_panel.get_node("TimeLabel").text = "%d min" % int(time_slider.value)

func _on_sell_pressed():
	if player_listing:
		_show_already_listed()
		return
	
	# Are you SURE? (Especially if selling for rent)
	var confirm_text: String
	var broom_name = GameState.broom_data.name
	var price = int(price_slider.value)
	
	if GameState.days_until_rent <= 3 and not GameState.is_rent_paid:
		# Desperate times
		confirm_text = "Sell your %s for $%d?\n\n" % [broom_name, price]
		confirm_text += "You REALLY need rent money, but...\n"
		confirm_text += "you'll be walking everywhere again.\n\n"
		confirm_text += "This is going to hurt."
		
	elif GameState.broom_data.get("is_premium", false):
		# Selling a PREMIUM broom?!
		confirm_text = "ARE YOU INSANE?!\n\n"
		confirm_text += "You want to sell your %s?!\n" % broom_name
		confirm_text += "This is a PREMIUM BROOM!\n\n"
		confirm_text += "You'll probably never find another one!\n\n"
		confirm_text += "Really sell for $%d?" % price
		
	else:
		# Normal sale
		confirm_text = "List your %s for $%d?\n\n" % [broom_name, price]
		confirm_text += '"%s"\n\n' % GameState.broom_data.description
		confirm_text += "It will be available for %d minutes." % int(time_slider.value)
	
	var dialog = ConfirmationDialog.new()
	dialog.dialog_text = confirm_text
	dialog.get_ok_button().text = "List it"
	dialog.get_cancel_button().text = "Keep it"
	
	get_tree().root.add_child(dialog)
	dialog.popup_centered()
	
	await dialog.confirmed
	dialog.queue_free()
	
	_list_broom()

func _list_broom():
	# Create the listing
	player_listing = {
		"id": "player_" + str(Time.get_unix_time_from_system()),
		"name": GameState.broom_data.name,
		"price": int(price_slider.value),
		"description": GameState.broom_data.description,
		"duration": int(time_slider.value),
		"posted_at": GameState.current_hour * 60 + GameState.current_minute,
		"expires_at": GameState.current_hour * 60 + GameState.current_minute + int(time_slider.value),
		"is_player_listing": true
	}
	
	# Remove broom from inventory immediately
	GameState.has_broom = false
	var old_broom = GameState.broom_data.duplicate()
	GameState.broom_data = {}
	
	# Add to active listings
	CroneslistTimer.active_broom_listings.append(player_listing)
	broom_listed.emit(player_listing)
	
	# Show confirmation
	var confirm = AcceptDialog.new()
	confirm.dialog_text = "Your %s is now listed for $%d!\n\n" % [old_broom.name, player_listing.price]
	
	if GameState.days_until_rent <= 3:
		confirm.dialog_text += "Hope it sells quick - rent is due soon.\n\n"
		
	confirm.dialog_text += "(You're already regretting this, aren't you?)"
	
	get_tree().root.add_child(confirm)
	confirm.popup_centered()
	confirm.popup_hide.connect(confirm.queue_free)
	
	# Start checking for sale
	_start_sale_timer()

func _start_sale_timer():
	# Check every minute if it sold
	var timer = Timer.new()
	timer.wait_time = 60.0
	timer.timeout.connect(_check_if_sold)
	add_child(timer)
	timer.start()

func _check_if_sold():
	if not player_listing:
		return
		
	var current_minutes = GameState.current_hour * 60 + GameState.current_minute
	
	if current_minutes >= player_listing.expires_at:
		# Calculate if it sold based on price competitiveness
		var sell_chance = _calculate_sell_chance()
		
		if randf() < sell_chance:
			_handle_sale()
		else:
			_handle_no_sale()

func _calculate_sell_chance() -> float:
	var price = player_listing.price
	
	# Premium brooms always sell if priced reasonably
	if GameState.broom_data.get("is_premium", false):
		if price <= suggested_price:
			return 1.0
		else:
			return 0.7
	
	# Regular brooms
	if price <= suggested_price * 0.7:
		return 0.95  # Cheap = almost guaranteed
	elif price <= suggested_price * 0.9:
		return 0.8   # Good price
	elif price <= suggested_price * 1.1:
		return 0.5   # Fair price
	else:
		return 0.2   # Overpriced

func _handle_sale():
	var amount = player_listing.price
	GameState.earn_money(amount)
	
	# Different messages based on context
	var message: String
	
	if GameState.days_until_rent <= 0 and not GameState.is_rent_paid:
		message = "Your broom sold for $%d!\n\n" % amount
		if amount >= GameState.rent_amount:
			message += "You can pay rent! But now you're walking everywhere...\n\n"
			message += "Was it worth it?"
		else:
			message += "It helps with rent, but you still need $%d more.\n\n" % (GameState.rent_amount - amount)
			message += "And now you don't even have a broom."
			
	elif player_listing.name.contains("weave") or player_listing.name.contains("storm"):
		# Sold a premium
		message = "Someone bought your %s for $%d.\n\n" % [player_listing.name, amount]
		message += "They're probably doing loop-de-loops right now.\n"
		message += "On YOUR premium broom.\n\n"
		message += "Hope the money was worth it..."
		
	else:
		message = "Your broom sold for $%d!\n\n" % amount
		message += "Back to walking. Again.\n"
		message += "At least you have money for food now."
	
	_show_sale_notification(message)
	listing_sold.emit(amount)
	player_listing = null

func _handle_no_sale():
	# It didn't sell! Do you want it back?
	var dialog = ConfirmationDialog.new()
	dialog.dialog_text = "Your broom didn't sell.\n\n"
	dialog.dialog_text += "Take it back, or keep trying to sell?"
	dialog.get_ok_button().text = "Take it back"
	dialog.get_cancel_button().text = "Relist cheaper"
	
	get_tree().root.add_child(dialog)
	dialog.popup_centered()
	
	await dialog.confirmed
	dialog.queue_free()
	
	# Give broom back
	GameState.has_broom = true
	GameState.broom_data = {
		"name": player_listing.name,
		"description": player_listing.description + " (couldn't even sell it...)",
		"purchase_price": player_listing.price
	}
	
	player_listing = null

func _show_already_listed():
	var dialog = AcceptDialog.new()
	dialog.dialog_text = "You already have a broom listed!\n\n"
	dialog.dialog_text += "Wait for it to sell or expire first."
	get_tree().root.add_child(dialog)
	dialog.popup_centered()
	dialog.popup_hide.connect(dialog.queue_free)

func _show_sale_notification(message: String):
	var dialog = AcceptDialog.new()
	dialog.dialog_text = message
	get_tree().root.add_child(dialog)
	dialog.popup_centered()
	dialog.popup_hide.connect(dialog.queue_free)