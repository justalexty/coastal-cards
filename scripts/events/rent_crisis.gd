extends Node

# Handles the emotional story beat of selling your broom for rent
# One of the most memorable moments in the game

class_name RentCrisisEvent

static func trigger_rent_crisis_dialogue():
	if not GameState.has_broom:
		return
		
	if GameState.days_until_rent > 3 or GameState.is_rent_paid:
		return
		
	# Only trigger once per game
	if GameState.has_shown_rent_crisis:
		return
		
	GameState.has_shown_rent_crisis = true
	
	var dialogue_sequence = [
		{
			"speaker": "You",
			"text": "Three days until rent. $%d in the bank. $%d short." % [
				GameState.current_money,
				GameState.rent_amount - GameState.current_money
			]
		},
		{
			"speaker": "You", 
			"text": "The broom sits in the corner, bristles askew."
		},
		{
			"speaker": "You",
			"text": "It's worth at least $%d on Croneslist..." % int(GameState.broom_data.purchase_price * 0.8)
		},
		{
			"speaker": "You",
			"text": "No. There has to be another way."
		},
		{
			"speaker": "You",
			"text": "...",
		},
		{
			"speaker": "You",
			"text": "...right?"
		}
	]
	
	# If it's a premium broom, extra pain
	if GameState.broom_data.get("is_premium", false):
		dialogue_sequence.append({
			"speaker": "You",
			"text": "But it's a %s. You saved for WEEKS." % GameState.broom_data.name
		})
		dialogue_sequence.append({
			"speaker": "You",
			"text": "You'll never find another one at that price."
		})
	
	DialogueManager.show_sequence(dialogue_sequence)

static func handle_post_sale_regret():
	var time_since_sale = GameState.hours_since_broom_sale
	
	if time_since_sale == 1:
		DialogueManager.show_thought("Your broom hook looks so empty.")
		
	elif time_since_sale == 3:
		DialogueManager.show_thought("Someone just flew past your window. Must be nice.")
		
	elif time_since_sale == 24:
		DialogueManager.show_thought("One day without flying. Feet hurt. Pride hurts more.")
		
	elif time_since_sale == 72:
		DialogueManager.show_thought("Three days walking. Was rent worth this?")

static func show_buyer_joy_notification():
	# Salt in the wound - show how happy the buyer is
	var messages = [
		"CharmingChariot: 'Just got an amazing deal on CL! Flying to the beach!'",
		"WitchyWings22: 'Someone sold their broom super cheap! Their loss lol'",
		"CloudHopper: 'Best purchase ever! Thanks desperate seller!'"
	]
	
	if GameState.sold_broom_data.get("is_premium", false):
		messages = [
			"LuckyFlyer: 'OMG SOMEONE SOLD A %s! Christmas miracle!'" % GameState.sold_broom_data.name,
			"SkyDancer: 'Just snagged a premium broom for half price! SOMEONE messed up!'",
			"BroomCollector99: 'Whoever sold that %s must be crying right now lmaooo'" % GameState.sold_broom_data.name
		]
	
	var msg = messages[randi() % messages.size()]
	CompactMirror.add_message("WitchNet", msg)

static func unlock_achievement_if_applicable():
	if GameState.sold_broom_for_rent:
		Achievements.unlock("sold_for_rent")
		
		if GameState.sold_broom_data.get("is_premium", false):
			Achievements.unlock("sold_premium_for_rent")
			
			# Special notification for this tragedy
			var notification = preload("res://scenes/ui/achievement_popup.tscn").instantiate()
			notification.set_achievement_data({
				"name": "The Ultimate Sacrifice",
				"description": "You did what you had to do.",
				"subtext": "But at what cost?"
			})
			get_tree().root.add_child(notification)