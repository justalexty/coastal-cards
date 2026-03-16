extends Node

# Tarot Deck System - Manages the 78 card deck
# class_name TarotDeck

var major_arcana = []
var minor_arcana = []
var full_deck = []

func _ready():
	_initialize_deck()

func _initialize_deck():
	# Initialize Major Arcana (0-21)
	major_arcana = [
		{"name": "The Fool", "number": 0, "arcana": "major", "keywords": ["beginnings", "innocence", "spontaneity"]},
		{"name": "The Magician", "number": 1, "arcana": "major", "keywords": ["manifestation", "willpower", "skill"]},
		{"name": "The High Priestess", "number": 2, "arcana": "major", "keywords": ["intuition", "sacred knowledge", "mystery"]},
		{"name": "The Empress", "number": 3, "arcana": "major", "keywords": ["femininity", "beauty", "abundance"]},
		{"name": "The Emperor", "number": 4, "arcana": "major", "keywords": ["authority", "structure", "control"]},
		{"name": "The Hierophant", "number": 5, "arcana": "major", "keywords": ["tradition", "conformity", "spirituality"]},
		{"name": "The Lovers", "number": 6, "arcana": "major", "keywords": ["love", "harmony", "choices"]},
		{"name": "The Chariot", "number": 7, "arcana": "major", "keywords": ["control", "willpower", "triumph"]},
		{"name": "Strength", "number": 8, "arcana": "major", "keywords": ["inner strength", "courage", "patience"]},
		{"name": "The Hermit", "number": 9, "arcana": "major", "keywords": ["soul searching", "introspection", "wisdom"]},
		{"name": "Wheel of Fortune", "number": 10, "arcana": "major", "keywords": ["luck", "karma", "cycles"]},
		{"name": "Justice", "number": 11, "arcana": "major", "keywords": ["justice", "fairness", "truth"]},
		{"name": "The Hanged Man", "number": 12, "arcana": "major", "keywords": ["surrender", "letting go", "perspective"]},
		{"name": "Death", "number": 13, "arcana": "major", "keywords": ["endings", "transformation", "transition"]},
		{"name": "Temperance", "number": 14, "arcana": "major", "keywords": ["balance", "moderation", "patience"]},
		{"name": "The Devil", "number": 15, "arcana": "major", "keywords": ["bondage", "addiction", "materialism"]},
		{"name": "The Tower", "number": 16, "arcana": "major", "keywords": ["sudden change", "upheaval", "chaos"]},
		{"name": "The Star", "number": 17, "arcana": "major", "keywords": ["hope", "faith", "renewal"]},
		{"name": "The Moon", "number": 18, "arcana": "major", "keywords": ["illusion", "fear", "intuition"]},
		{"name": "The Sun", "number": 19, "arcana": "major", "keywords": ["joy", "success", "vitality"]},
		{"name": "Judgement", "number": 20, "arcana": "major", "keywords": ["reflection", "reckoning", "awakening"]},
		{"name": "The World", "number": 21, "arcana": "major", "keywords": ["completion", "accomplishment", "fulfillment"]}
	]
	
	# Initialize Minor Arcana
	var suits = ["cups", "wands", "swords", "pentacles"]
	var court_cards = ["Page", "Knight", "Queen", "King"]
	
	for suit in suits:
		# Number cards (Ace through 10)
		for num in range(1, 11):
			var card_name = _get_number_name(num) + " of " + suit.capitalize()
			var keywords = _get_minor_keywords(suit, num)
			minor_arcana.append({
				"name": card_name,
				"number": num,
				"suit": suit,
				"arcana": "minor",
				"keywords": keywords
			})
		
		# Court cards
		for court in court_cards:
			var card_name = court + " of " + suit.capitalize()
			var keywords = _get_court_keywords(suit, court)
			minor_arcana.append({
				"name": card_name,
				"court": court,
				"suit": suit,
				"arcana": "minor",
				"keywords": keywords
			})
	
	# Combine into full deck
	full_deck = major_arcana + minor_arcana

func draw_random_card() -> Dictionary:
	if full_deck.is_empty():
		_initialize_deck()
	
	return full_deck[randi() % full_deck.size()].duplicate()

func draw_card_by_name(card_name: String) -> Dictionary:
	for card in full_deck:
		if card.name == card_name:
			return card.duplicate()
	
	return {}  # Card not found

func get_card_meaning(card: Dictionary, reversed: bool = false) -> String:
	# This would return contextual meanings
	# For now, return basic keyword-based meaning
	if reversed:
		return "Reversed: " + card.keywords[0] + " blocked or inverted"
	else:
		return "Upright: " + card.keywords[0].capitalize()

func _get_number_name(num: int) -> String:
	match num:
		1: return "Ace"
		2: return "Two"
		3: return "Three"
		4: return "Four"
		5: return "Five"
		6: return "Six"
		7: return "Seven"
		8: return "Eight"
		9: return "Nine"
		10: return "Ten"
	return str(num)

func _get_minor_keywords(suit: String, number: int) -> Array:
	# Basic keywords based on suit and number
	match suit:
		"cups":
			match number:
				1: return ["new love", "emotional beginnings", "intuition"]
				2: return ["partnership", "unity", "attraction"]
				3: return ["celebration", "friendship", "community"]
				4: return ["contemplation", "apathy", "reevaluation"]
				5: return ["loss", "grief", "disappointment"]
				6: return ["nostalgia", "childhood", "innocence"]
				7: return ["choices", "illusion", "imagination"]
				8: return ["walking away", "disillusionment", "seeking"]
				9: return ["wishes fulfilled", "satisfaction", "contentment"]
				10: return ["harmony", "happiness", "fulfillment"]
		
		"wands":
			match number:
				1: return ["inspiration", "new opportunities", "growth"]
				2: return ["planning", "decisions", "discovery"]
				3: return ["expansion", "foresight", "leadership"]
				4: return ["celebration", "harmony", "homecoming"]
				5: return ["conflict", "competition", "tension"]
				6: return ["success", "recognition", "victory"]
				7: return ["perseverance", "defensive", "challenge"]
				8: return ["speed", "action", "movement"]
				9: return ["courage", "persistence", "resilience"]
				10: return ["burden", "responsibility", "completion"]
		
		"swords":
			match number:
				1: return ["mental clarity", "breakthrough", "truth"]
				2: return ["indecision", "choices", "stalemate"]
				3: return ["heartbreak", "sorrow", "grief"]
				4: return ["rest", "contemplation", "recovery"]
				5: return ["conflict", "defeat", "betrayal"]
				6: return ["transition", "moving on", "journey"]
				7: return ["deception", "strategy", "betrayal"]
				8: return ["restriction", "imprisonment", "victim"]
				9: return ["anxiety", "worry", "nightmares"]
				10: return ["endings", "loss", "betrayal"]
		
		"pentacles":
			match number:
				1: return ["opportunity", "manifestation", "abundance"]
				2: return ["balance", "adaptability", "juggling"]
				3: return ["teamwork", "collaboration", "skill"]
				4: return ["security", "control", "conservation"]
				5: return ["financial loss", "poverty", "insecurity"]
				6: return ["generosity", "charity", "sharing"]
				7: return ["patience", "investment", "reward"]
				8: return ["apprenticeship", "skill", "diligence"]
				9: return ["luxury", "self-sufficiency", "success"]
				10: return ["legacy", "inheritance", "wealth"]
	
	return ["unknown"]

func _get_court_keywords(suit: String, court: String) -> Array:
	var base = {
		"Page": ["messages", "new beginnings", "curiosity"],
		"Knight": ["action", "adventure", "impulsiveness"],
		"Queen": ["nurturing", "intuition", "mastery"],
		"King": ["authority", "control", "mastery"]
	}
	
	return base[court]

# Singleton
func _init():
	if not Engine.has_singleton("TarotDeck"):
		Engine.register_singleton("TarotDeck", self)