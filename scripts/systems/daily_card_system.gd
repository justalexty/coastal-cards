extends Node

# Daily Card Draw System - Personal morning ritual
# class_name DailyCardSystem

signal card_drawn(card_data)
signal daily_effect_applied(effect_type, modifier)

var current_daily_card: Dictionary = {}
var has_drawn_today: bool = false
var daily_effects: Dictionary = {}

# Card influence on the day
var card_day_effects = {
	# Major Arcana - Stronger effects
	"The Fool": {"energy": 10, "luck": 0.15, "mood": "adventurous"},
	"The Magician": {"accuracy": 0.10, "tips": 0.05, "mood": "confident"},
	"The High Priestess": {"intuition": 0.20, "energy": 5, "mood": "mystical"},
	"The Empress": {"tips": 0.15, "rapport": 0.10, "mood": "nurturing"},
	"The Emperor": {"confidence": 0.15, "structure": 0.10, "mood": "authoritative"},
	"The Hierophant": {"accuracy": 0.05, "repeat_clients": 0.10, "mood": "traditional"},
	"The Lovers": {"rapport": 0.20, "love_readings": 0.15, "mood": "romantic"},
	"The Chariot": {"energy": 15, "confidence": 0.10, "mood": "determined"},
	"Strength": {"energy": 10, "difficult_clients": 0.15, "mood": "patient"},
	"The Hermit": {"intuition": 0.15, "wisdom": 0.10, "mood": "introspective"},
	"Wheel of Fortune": {"luck": 0.25, "tips": 0.10, "mood": "optimistic"},
	"Justice": {"accuracy": 0.15, "karma": true, "mood": "balanced"},
	"The Hanged Man": {"intuition": 0.10, "patience": 0.15, "mood": "contemplative"},
	"Death": {"transformation": true, "new_clients": 0.20, "mood": "transformative"},
	"Temperance": {"energy_regen": 0.20, "accuracy": 0.05, "mood": "peaceful"},
	"The Devil": {"tips": 0.20, "awareness": 0.15, "mood": "mischievous"},
	"The Tower": {"breakthrough": true, "clarity": 0.20, "mood": "transformative"},
	"The Star": {"luck": 0.20, "energy": 10, "mood": "hopeful"},
	"The Moon": {"intuition": 0.25, "confusion": 0.10, "mood": "dreamy"},
	"The Sun": {"energy": 20, "tips": 0.15, "mood": "joyful"},
	"Judgement": {"accuracy": 0.20, "repeat_clients": 0.15, "mood": "reflective"},
	"The World": {"all_bonuses": 0.10, "energy": 15, "mood": "accomplished"},
	
	# Minor Arcana - Milder effects
	"Ace of Cups": {"new_clients": 0.10, "rapport": 0.10, "mood": "open-hearted"},
	"Three of Cups": {"tips": 0.10, "energy": 5, "mood": "social"},
	"Nine of Cups": {"luck": 0.15, "satisfaction": 0.20, "mood": "content"},
	"Ten of Cups": {"rapport": 0.15, "tips": 0.10, "mood": "harmonious"},
	
	"Ace of Wands": {"energy": 10, "new_clients": 0.15, "mood": "inspired"},
	"Three of Wands": {"accuracy": 0.10, "confidence": 0.10, "mood": "visionary"},
	"Six of Wands": {"tips": 0.20, "reputation": 2, "mood": "victorious"},
	"Eight of Wands": {"reading_speed": 0.20, "energy": 5, "mood": "swift"},
	
	"Ace of Swords": {"accuracy": 0.20, "clarity": true, "mood": "sharp"},
	"Two of Swords": {"decision_paralysis": true, "mood": "indecisive"},
	"Four of Swords": {"energy_regen": 0.30, "rest_quality": 0.20, "mood": "restful"},
	"Nine of Swords": {"awareness": 0.20, "insight": 0.15, "mood": "alert"},
	
	"Ace of Pentacles": {"tips": 0.25, "new_clients": 0.10, "mood": "prosperous"},
	"Four of Pentacles": {"security": 0.15, "savings": 0.20, "mood": "grounded"},
	"Nine of Pentacles": {"tips": 0.15, "energy": 10, "mood": "luxurious"},
	"Ten of Pentacles": {"repeat_clients": 0.20, "tips": 0.10, "mood": "established"}
}

func _ready():
	# Reset daily draw when day changes
	if Calendar:
		Calendar.day_changed.connect(_on_new_day)

func draw_daily_card() -> Dictionary:
	if has_drawn_today:
		return current_daily_card
	
	# Get random card from deck
	var card = TarotDeck.draw_random_card()
	current_daily_card = card
	has_drawn_today = true
	
	# Apply the day's effects
	_apply_daily_effects(card)
	
	# Save to journal
	_record_in_journal(card)
	
	# Emit signal
	card_drawn.emit(card)
	
	return card

func _apply_daily_effects(card: Dictionary):
	var card_name = card.name
	
	# Check if we have specific effects for this card
	if card_name in card_day_effects:
		var effects = card_day_effects[card_name]
		daily_effects = effects.duplicate()
		
		# Apply immediate effects
		if "energy" in effects:
			GameState.energy = min(GameState.max_energy, GameState.energy + effects.energy)
			daily_effect_applied.emit("energy", effects.energy)
		
		if "reputation" in effects:
			GameState.reputation += effects.reputation
			daily_effect_applied.emit("reputation", effects.reputation)
		
		if "mood" in effects:
			GameState.current_mood = effects.mood
			daily_effect_applied.emit("mood", effects.mood)
	
	# General effects based on card type
	if card.arcana == "major":
		daily_effects["major_arcana_day"] = true
		CompactMirror.add_message("Daily Card", "A Major Arcana day - expect significant events!")
	
	# Suit-based bonuses
	match card.suit:
		"cups":
			daily_effects["emotional_depth"] = 0.10
		"wands":
			daily_effects["creative_energy"] = 0.10
		"swords":
			daily_effects["mental_clarity"] = 0.10
		"pentacles":
			daily_effects["material_focus"] = 0.10

func get_daily_modifier(effect_type: String) -> float:
	if effect_type in daily_effects:
		return daily_effects[effect_type]
	return 0.0

func has_daily_effect(effect_type: String) -> bool:
	return effect_type in daily_effects

func _record_in_journal(card: Dictionary):
	var journal_entry = {
		"date": Calendar.get_date_string(),
		"card": card.name,
		"interpretation": _get_personal_interpretation(card),
		"mood": daily_effects.get("mood", "neutral")
	}
	
	# This would save to player's tarot journal
	GameState.tarot_journal.append(journal_entry)

func _get_personal_interpretation(card: Dictionary) -> String:
	# Personal interpretations for daily draws
	var personal_meanings = {
		"The Fool": "Today is for new adventures. Don't overthink, just begin.",
		"The Tower": "Old structures fall away to reveal truth. Breakthrough awaits!",
		"The Sun": "Joy and success are yours today. Share your light!",
		"Death": "Time to let something go. Make space for the new.",
		"The Lovers": "Connections deepen today. Open your heart.",
		# Add more...
	}
	
	if card.name in personal_meanings:
		return personal_meanings[card.name]
	
	# Generic interpretation based on card type
	if card.arcana == "major":
		return "A powerful day for " + card.keywords[0].to_lower() + "."
	elif card.number == 1:  # Aces
		return "New beginnings in " + card.suit + " await you."
	else:
		return "Focus on " + card.keywords[0].to_lower() + " today."

func _on_new_day(_date_info: Dictionary):
	# Reset for new day
	has_drawn_today = false
	current_daily_card.clear()
	daily_effects.clear()

func get_daily_card_scene_data() -> Dictionary:
	# Data for the daily card UI scene
	return {
		"has_drawn": has_drawn_today,
		"current_card": current_daily_card,
		"effects": daily_effects,
		"can_skip": false  # Daily card is part of the morning ritual
	}