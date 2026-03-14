extends Node

# Handles pronoun usage throughout the game
class_name PronounManager

static var player_pronouns: Dictionary = {
	"subject": "they",
	"object": "them", 
	"possessive": "their",
	"possessive_pronoun": "theirs",
	"reflexive": "themself",
	"is_plural": true  # for verb conjugation
}

# Set player pronouns from character creation
static func set_pronouns(pronoun_data: Dictionary):
	player_pronouns = pronoun_data.duplicate()
	
	# Generate additional forms
	if pronoun_data.subject == "they":
		player_pronouns.is_plural = true
		player_pronouns.reflexive = "themself"
		player_pronouns.possessive_pronoun = "theirs"
	elif pronoun_data.subject == "she":
		player_pronouns.is_plural = false
		player_pronouns.reflexive = "herself"
		player_pronouns.possessive_pronoun = "hers"
	elif pronoun_data.subject == "he":
		player_pronouns.is_plural = false
		player_pronouns.reflexive = "himself"
		player_pronouns.possessive_pronoun = "his"
	else:  # Custom pronouns
		# Player will need to provide all forms
		player_pronouns.is_plural = false  # default

# Replace pronouns in dialogue text
static func parse_text(text: String) -> String:
	# Replace pronoun placeholders
	text = text.replace("{subj}", player_pronouns.subject)
	text = text.replace("{obj}", player_pronouns.object)
	text = text.replace("{poss}", player_pronouns.possessive)
	text = text.replace("{poss_pronoun}", player_pronouns.possessive_pronoun)
	text = text.replace("{reflex}", player_pronouns.reflexive)
	
	# Handle capitalized versions
	text = text.replace("{Subj}", player_pronouns.subject.capitalize())
	text = text.replace("{Obj}", player_pronouns.object.capitalize())
	text = text.replace("{Poss}", player_pronouns.possessive.capitalize())
	
	# Handle verb conjugation
	if player_pronouns.is_plural:
		text = text.replace("{is/are}", "are")
		text = text.replace("{has/have}", "have")
		text = text.replace("{does/do}", "do")
		text = text.replace("{s/}", "")  # no 's' for plural
	else:
		text = text.replace("{is/are}", "is")
		text = text.replace("{has/have}", "has")
		text = text.replace("{does/do}", "does")
		text = text.replace("{s/}", "s")  # add 's' for singular
	
	return text

# Example usage in game:
# "The client looks at {obj}. '{Subj} seem{s/} trustworthy,' they think."
# "She" version: "The client looks at her. 'She seems trustworthy,' they think."
# "They" version: "The client looks at them. 'They seem trustworthy,' they think."

# For custom pronouns, provide a form
static func get_custom_pronoun_form():
	return {
		"subject": "",  # ze, xe, fae, etc.
		"object": "",   # zir, xem, faer
		"possessive": "",  # zir, xyr, faer
		"possessive_pronoun": "",  # zirs, xyrs, faers
		"reflexive": "",  # zirself, xemself, faerself
		"example": "Example: {Subj} read{s/} {poss} cards to {reflex}."
	}