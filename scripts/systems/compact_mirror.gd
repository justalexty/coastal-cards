extends Control

# Magic Compact Mirror System
# Handles character creation, witch messages, scrying, and save functionality

class_name CompactMirror

signal character_created(character_data)
signal message_received(sender, message)
signal scrying_complete(vision_data)

enum CompactMode {
	CLOSED,
	STYLING,
	MESSAGES,
	SCRYING,
	SAVE_MENU
}

var current_mode: CompactMode = CompactMode.CLOSED
var is_first_time: bool = true
var character_data: Dictionary = {}
var message_queue: Array = []
var scrying_charges: int = 3

# Character options
var pronouns: Array = [
	{"label": "She/Her", "subject": "she", "object": "her", "possessive": "her"},
	{"label": "He/Him", "subject": "he", "object": "him", "possessive": "his"},
	{"label": "They/Them", "subject": "they", "object": "them", "possessive": "their"},
	{"label": "Custom", "subject": "", "object": "", "possessive": ""}
]
var body_types: Array = ["feminine", "androgynous", "masculine"]
var skin_tones: Array = ["pale", "light", "medium", "tan", "dark", "deep"]
var hair_styles: Array = ["short_straight", "short_wavy", "long_straight", "long_wavy", "braids", "bun", "ponytail", "buzzcut", "mohawk"]
var hair_colors: Array = ["black", "brown", "blonde", "red", "purple", "blue", "green", "white", "pink"]
var eye_colors: Array = ["brown", "hazel", "green", "blue", "grey", "violet", "amber", "red"]
var outfit_styles: Array = ["traditional", "modern_witch", "casual", "formal", "traveler", "apprentice", "punk_witch"]
var accessories: Array = ["none", "glasses", "hat", "scarf", "earrings", "necklace", "piercings"]

func _ready():
	if is_first_time:
		_start_opening_sequence()
	else:
		visible = false

func open_compact():
	visible = true
	$AnimationPlayer.play("open_compact")
	$CompactSFX.play()
	
	if is_first_time:
		current_mode = CompactMode.STYLING
		_show_styling_interface()
	else:
		_show_main_menu()

func close_compact():
	$AnimationPlayer.play("close_compact")
	await $AnimationPlayer.animation_finished
	visible = false
	current_mode = CompactMode.CLOSED

func _start_opening_sequence():
	# This is called from the main game scene
	# Shows the compact opening for first time
	$OpeningSequence/TrainBG.visible = true
	$OpeningSequence/DialogueBox.visible = true
	
	var opening_dialogue = [
		"The coastal express rattles along the tracks. Cheaper than broom travel, even if yours wasn't broken.",
		"Your stomach growls. That station sandwich was your last splurge before... everything.",
		"Deposit AND first month's rent. Your wallet's never been this empty.",
		"At least you still have your compact. Time to check your appearance before arrival..."
	]
	
	for line in opening_dialogue:
		await _show_dialogue(line)
	
	# Transition to compact opening
	$OpeningSequence.visible = false
	open_compact()

func _show_dialogue(text: String):
	$OpeningSequence/DialogueBox/Text.text = text
	$OpeningSequence/DialogueBox/ContinueButton.visible = false
	
	# Typewriter effect
	var visible_chars = 0
	$OpeningSequence/DialogueBox/Text.visible_characters = 0
	
	while visible_chars < text.length():
		visible_chars += 1
		$OpeningSequence/DialogueBox/Text.visible_characters = visible_chars
		await get_tree().create_timer(0.03).timeout
	
	$OpeningSequence/DialogueBox/ContinueButton.visible = true
	await $OpeningSequence/DialogueBox/ContinueButton.pressed

func _show_styling_interface():
	$MirrorInterface/StylingPanel.visible = true
	$MirrorInterface/MainMenu.visible = false
	
	# Initialize character preview
	_update_character_preview()

func _show_main_menu():
	$MirrorInterface/StylingPanel.visible = false
	$MirrorInterface/MainMenu.visible = true
	
	# Update message notification
	if message_queue.size() > 0:
		$MirrorInterface/MainMenu/MessagesButton/NotificationBadge.visible = true
		$MirrorInterface/MainMenu/MessagesButton/NotificationBadge/Count.text = str(message_queue.size())
		
	# Update Croneslist indicator (subtle, not pushy)
	var active_brooms = get_node("/root/CroneslistTimer").active_broom_listings.size()
	if active_brooms > 0 and not GameState.has_broom:
		$MirrorInterface/MainMenu/CroneslistButton/ActiveDot.visible = true
		$MirrorInterface/MainMenu/CroneslistButton/ActiveDot.modulate = Color(0.7, 1, 0.7, 0.7)
	else:
		$MirrorInterface/MainMenu/CroneslistButton/ActiveDot.visible = false

func _update_character_preview():
	var preview = $MirrorInterface/StylingPanel/CharacterPreview
	
	# Apply current character data to preview sprite
	# This would load and composite the appropriate sprite layers
	preview.skin_tone = character_data.get("skin_tone", "medium")
	preview.hair_style = character_data.get("hair_style", "long_straight")
	preview.hair_color = character_data.get("hair_color", "black")
	preview.eye_color = character_data.get("eye_color", "brown")
	preview.outfit = character_data.get("outfit", "traditional")
	preview.accessory = character_data.get("accessory", "none")
	
	preview.update_appearance()

func save_character():
	# Validate character data
	if not character_data.has("name") or character_data.name == "":
		$MirrorInterface/StylingPanel/ErrorLabel.text = "Please enter your name"
		return
	
	# Save to game state
	GameState.player_character = character_data
	GameState.save_game()
	
	# If first time, transition to game
	if is_first_time:
		is_first_time = false
		character_created.emit(character_data)
		
		# Show welcome message from Witch Network
		add_message("WitchNet Alert", "Welcome to Coralhaven! New registrant detected. Reminder: Street vending requires permits in Market Square and University District. Boardwalk and parks are permit-free. Good luck!")
		
		close_compact()
	else:
		# Just close the styling panel
		_show_main_menu()

func add_message(sender: String, content: String):
	var message = {
		"sender": sender,
		"content": content,
		"timestamp": Time.get_datetime_string_from_system(),
		"read": false
	}
	
	message_queue.append(message)
	message_received.emit(sender, content)
	
	# Play notification sound if compact is closed
	if current_mode == CompactMode.CLOSED:
		$NotificationSFX.play()

func start_urgent_glow():
	# For premium broom notifications
	if current_mode == CompactMode.CLOSED:
		$GlowAnimation.play("urgent_pulse")
		$UrgentSFX.play()

func start_scrying(target_type: String = ""):
	if scrying_charges <= 0:
		$MirrorInterface/ScryingPanel/ErrorLabel.text = "Your scrying energy is depleted. Rest to restore it."
		return
		
	current_mode = CompactMode.SCRYING
	$MirrorInterface/ScryingPanel.visible = true
	
	# Start scrying animation
	$MirrorInterface/ScryingPanel/MirrorSurface.material.set_shader_param("ripple_active", true)
	
	# Generate vision based on target
	var vision_data = _generate_scrying_vision(target_type)
	
	await get_tree().create_timer(3.0).timeout
	
	# Show vision
	_display_vision(vision_data)
	scrying_charges -= 1
	scrying_complete.emit(vision_data)

func _generate_scrying_vision(target_type: String) -> Dictionary:
	# This would generate contextual visions based on game state
	var visions = {
		"next_client": [
			"A figure approaches, burdened by a choice between two paths...",
			"Someone seeks answers about a letter they're afraid to send...",
			"A merchant worries about a journey across the sea..."
		],
		"good_location": [
			"The boardwalk hums with weekend energy...",
			"Students gather in the university square this evening...",
			"The market awakens early, full of possibility..."
		],
		"weather": [
			"Storm clouds gather for tomorrow afternoon...",
			"Clear skies and warm sun for the next three days...",
			"Morning fog will lift by noon..."
		]
	}
	
	var vision_pool = visions.get(target_type, visions.values().reduce(func(acc, val): return acc + val, []))
	return {
		"text": vision_pool[randi() % vision_pool.size()],
		"type": target_type,
		"accuracy": randf_range(0.7, 0.95)  # Scrying isn't always 100% accurate
	}

func _display_vision(vision_data: Dictionary):
	$MirrorInterface/ScryingPanel/VisionText.text = vision_data.text
	$MirrorInterface/ScryingPanel/VisionText.modulate.a = 0
	
	var tween = create_tween()
	tween.tween_property($MirrorInterface/ScryingPanel/VisionText, "modulate:a", 1.0, 2.0)

# UI Callbacks
func _on_styling_next_pressed():
	var current_page = $MirrorInterface/StylingPanel/CurrentPage.value
	if current_page < 5:  # Assuming 5 pages of customization
		current_page += 1
		_show_styling_page(current_page)

func _on_styling_previous_pressed():
	var current_page = $MirrorInterface/StylingPanel/CurrentPage.value
	if current_page > 0:
		current_page -= 1
		_show_styling_page(current_page)

func _show_styling_page(page: int):
	# Hide all pages
	for child in $MirrorInterface/StylingPanel/Pages.get_children():
		child.visible = false
	
	# Show current page based on what it is
	match page:
		0:  # Name and pronouns
			_show_identity_page()
		1:  # Body type and skin tone
			_show_body_page()
		2:  # Hair options
			_show_hair_page()
		3:  # Outfit and accessories
			_show_outfit_page()
		4:  # Final review
			_show_review_page()
	
	$MirrorInterface/StylingPanel/CurrentPage.value = page
	
	# Update navigation buttons
	$MirrorInterface/StylingPanel/PreviousButton.disabled = (page == 0)
	$MirrorInterface/StylingPanel/NextButton.visible = (page < 4)
	$MirrorInterface/StylingPanel/FinishButton.visible = (page == 4)

func _show_identity_page():
	# Name input and pronoun selection
	var page = $MirrorInterface/StylingPanel/Pages/Identity
	page.visible = true
	
	# Set up pronoun buttons
	for i in range(pronouns.size()):
		var btn = page.get_node("PronounGrid/PronounButton" + str(i))
		btn.text = pronouns[i].label
		btn.toggled.connect(_on_pronoun_selected.bind(i))

func _on_pronoun_selected(pressed: bool, index: int):
	if pressed:
		character_data["pronouns"] = pronouns[index]
		
		if pronouns[index].label == "Custom":
			# Show custom pronoun input fields
			$MirrorInterface/StylingPanel/Pages/Identity/CustomPronouns.visible = true
		else:
			$MirrorInterface/StylingPanel/Pages/Identity/CustomPronouns.visible = false
			PronounManager.set_pronouns(pronouns[index])