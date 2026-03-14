extends PanelContainer

# Notification preferences UI for Croneslist
# Because nobody wants their compact buzzing for every duct-taped broom

class_name CroneslistNotifications

signal preferences_saved

@onready var enabled_toggle = $VBox/EnabledToggle
@onready var regular_toggle = $VBox/NotifyOptions/RegularToggle
@onready var premium_toggle = $VBox/NotifyOptions/PremiumToggle
@onready var price_slider = $VBox/NotifyOptions/PriceContainer/PriceSlider
@onready var price_label = $VBox/NotifyOptions/PriceContainer/PriceLabel
@onready var search_input = $VBox/SearchContainer/SearchInput
@onready var search_list = $VBox/SearchContainer/SearchList
@onready var save_button = $VBox/SaveButton

var current_prefs: Dictionary

func _ready():
	# Load current preferences
	current_prefs = GameState.croneslist_notification_prefs.duplicate()
	
	# Set up UI from saved prefs
	enabled_toggle.button_pressed = GameState.croneslist_notifications_enabled
	regular_toggle.button_pressed = current_prefs.get("regular_brooms", false)
	premium_toggle.button_pressed = current_prefs.get("premium_brooms", false)
	price_slider.value = current_prefs.get("max_price", 250)
	
	# Connect signals
	enabled_toggle.toggled.connect(_on_enabled_toggled)
	regular_toggle.toggled.connect(_on_regular_toggled)
	premium_toggle.toggled.connect(_on_premium_toggled)
	price_slider.value_changed.connect(_on_price_changed)
	save_button.pressed.connect(_save_preferences)
	
	# Set up search terms
	_update_search_list()
	
	# Initial UI state
	_update_ui_state()

func _on_enabled_toggled(pressed: bool):
	GameState.croneslist_notifications_enabled = pressed
	_update_ui_state()
	
	if pressed:
		$VBox/StatusLabel.text = "Notifications ON - Your compact will glow"
		$VBox/StatusLabel.modulate = Color(0.7, 1, 0.7)
	else:
		$VBox/StatusLabel.text = "Notifications OFF - Check manually"
		$VBox/StatusLabel.modulate = Color(1, 0.7, 0.7)

func _update_ui_state():
	# Disable options if notifications are off
	var enabled = GameState.croneslist_notifications_enabled
	$VBox/NotifyOptions.modulate = Color.WHITE if enabled else Color(0.5, 0.5, 0.5)
	regular_toggle.disabled = not enabled
	premium_toggle.disabled = not enabled
	price_slider.editable = enabled and regular_toggle.button_pressed
	search_input.editable = enabled

func _on_regular_toggled(pressed: bool):
	current_prefs["regular_brooms"] = pressed
	price_slider.editable = pressed and GameState.croneslist_notifications_enabled
	
	if pressed:
		$VBox/NotifyOptions/RegularLabel.text = "Notify for regular brooms under:"
	else:
		$VBox/NotifyOptions/RegularLabel.text = "Regular brooms (disabled)"

func _on_premium_toggled(pressed: bool):
	current_prefs["premium_brooms"] = pressed
	
	if pressed:
		$VBox/NotifyOptions/PremiumLabel.text = "✨ ALWAYS notify for premium brooms!"
		$VBox/NotifyOptions/PremiumLabel.modulate = Color(1, 0.9, 0.7)

func _on_price_changed(value: float):
	current_prefs["max_price"] = int(value)
	price_label.text = "$%d" % int(value)
	
	# Color based on range
	if value <= 200:
		price_label.modulate = Color(0.7, 1, 0.7)  # Green - only cheapest
	elif value >= 280:
		price_label.modulate = Color(1, 0.7, 0.7)  # Red - all brooms

func _on_add_search_pressed():
	var term = search_input.text.strip_edges()
	if term.length() > 0:
		if not term in current_prefs["search_terms"]:
			current_prefs["search_terms"].append(term)
			_update_search_list()
		search_input.clear()

func _update_search_list():
	# Clear current list
	for child in search_list.get_children():
		child.queue_free()
	
	# Add current search terms
	for term in current_prefs.get("search_terms", []):
		var hbox = HBoxContainer.new()
		
		var label = Label.new()
		label.text = term
		hbox.add_child(label)
		
		var remove_btn = Button.new()
		remove_btn.text = "X"
		remove_btn.custom_minimum_size.x = 30
		remove_btn.pressed.connect(_remove_search_term.bind(term))
		hbox.add_child(remove_btn)
		
		search_list.add_child(hbox)

func _remove_search_term(term: String):
	current_prefs["search_terms"].erase(term)
	_update_search_list()

func _save_preferences():
	# Save all preferences
	GameState.croneslist_notification_prefs = current_prefs.duplicate()
	
	# Show confirmation
	var saved_label = Label.new()
	saved_label.text = "Preferences saved!"
	saved_label.modulate = Color(0.7, 1, 0.7)
	$VBox.add_child(saved_label)
	
	# Fade out and remove
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(saved_label, "modulate:a", 0, 0.5)
	tween.tween_callback(saved_label.queue_free)
	
	preferences_saved.emit()

func show_quick_setup():
	# For first-time users
	var dialog = AcceptDialog.new()
	dialog.dialog_text = "Want Croneslist notifications?\n\n"
	dialog.dialog_text += "Your compact will glow when items match your preferences.\n\n"
	dialog.dialog_text += "Recommended settings:\n"
	dialog.dialog_text += "✓ Premium brooms (rare!)\n"
	dialog.dialog_text += "✓ Regular under $220\n\n"
	dialog.dialog_text += "You can change this anytime in Croneslist settings."
	
	dialog.add_button("Set up now", false)
	dialog.add_button("No thanks", true)
	
	get_tree().root.add_child(dialog)
	dialog.popup_centered()
	
	var result = await dialog.custom_action
	dialog.queue_free()
	
	if result == "Set up now":
		# Apply recommended settings
		GameState.croneslist_notifications_enabled = true
		current_prefs["premium_brooms"] = true
		current_prefs["regular_brooms"] = true
		current_prefs["max_price"] = 220
		_save_preferences()
		_update_ui_state()