extends Control

# Handles all dialogue display with pronoun integration
class_name DialogueSystem

@onready var dialogue_box = $DialogueBox
@onready var speaker_label = $DialogueBox/SpeakerLabel
@onready var text_label = $DialogueBox/TextLabel
@onready var portrait_rect = $DialogueBox/Portrait

signal dialogue_finished
signal choice_made(index)

var current_dialogue: Array = []
var current_index: int = 0
var is_typing: bool = false
var text_speed: float = 0.03

func show_dialogue(text: String, speaker: String = "", portrait: Texture2D = null):
	# Parse pronouns in the text
	text = PronounManager.parse_text(text)
	
	dialogue_box.visible = true
	speaker_label.text = speaker
	
	if portrait:
		portrait_rect.texture = portrait
		portrait_rect.visible = true
	else:
		portrait_rect.visible = false
	
	await _type_text(text)

func show_dialogue_sequence(dialogues: Array):
	current_dialogue = dialogues
	current_index = 0
	
	for dialogue in dialogues:
		var parsed_text = PronounManager.parse_text(dialogue.text)
		await show_dialogue(parsed_text, dialogue.get("speaker", ""), dialogue.get("portrait", null))
		
		if dialogue.has("choices"):
			await show_choices(dialogue.choices)
	
	dialogue_finished.emit()
	dialogue_box.visible = false

func show_choices(choices: Array):
	var choice_container = $DialogueBox/ChoiceContainer
	choice_container.visible = true
	
	# Clear old choices
	for child in choice_container.get_children():
		child.queue_free()
	
	# Create new choice buttons
	for i in range(choices.size()):
		var button = Button.new()
		# Parse pronouns in choice text too
		button.text = PronounManager.parse_text(choices[i])
		button.pressed.connect(_on_choice_pressed.bind(i))
		choice_container.add_child(button)
	
	# Wait for choice
	await choice_made
	choice_container.visible = false

func _type_text(text: String):
	text_label.text = text
	text_label.visible_characters = 0
	is_typing = true
	
	for i in range(text.length()):
		if not is_typing:  # Allow skip
			text_label.visible_characters = text.length()
			break
			
		text_label.visible_characters = i + 1
		await get_tree().create_timer(text_speed).timeout
	
	is_typing = false

func _on_choice_pressed(index: int):
	choice_made.emit(index)

func _input(event):
	# Skip typing with click/space
	if is_typing and (event.is_action_pressed("ui_accept") or event is InputEventMouseButton):
		is_typing = false

# Example usage:
# var dialogues = [
#     {
#         "speaker": "Client",
#         "text": "I've heard {subj} {is/are} new in town. Can {subj} really read the cards?"
#     },
#     {
#         "speaker": "You",
#         "text": "I may be new to Coralhaven, but I come from a long line of witches.",
#         "choices": [
#             "Would you like a single card reading? ($5)",
#             "Perhaps a three-card spread would serve you better? ($15)",
#             "Actually, I should find a better spot first."
#         ]
#     }
# ]