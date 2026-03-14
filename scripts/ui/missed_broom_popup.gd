extends AcceptDialog

# Shows when you JUST missed a broom listing

func show_missed_premium(listing_name: String, minutes_ago: int, price: int, retail_price: int):
	# This is for missing PREMIUM brooms - maximum pain
	dialog_text = "💔 YOU MISSED A PREMIUM BROOM! 💔\n\n"
	
	if minutes_ago <= 2:
		dialog_text += "A %s was $%d (normally $%d)!\n\n" % [listing_name, price, retail_price]
		dialog_text += "You missed it by %d MINUTE%s!\n\n" % [
			minutes_ago,
			"" if minutes_ago == 1 else "S"
		]
		dialog_text += "THAT WAS $%d OFF!!!\n\n" % (retail_price - price)
		dialog_text += _get_premium_salt()
		
		# Extra dramatic
		modulate = Color(1, 0.7, 0.7)
		
		# More shaking
		var original_pos = position
		var tween = create_tween()
		for i in range(5):
			tween.tween_property(self, "position", original_pos + Vector2(randf_range(-10, 10), randf_range(-10, 10)), 0.05)
			tween.tween_property(self, "position", original_pos, 0.05)
	else:
		dialog_text += "A %s sold %d minutes ago.\n" % [listing_name, minutes_ago]
		dialog_text += "It was only $%d... (retail $%d)\n\n" % [price, retail_price]
		dialog_text += "Premium brooms only appear once a week. You blew it."
	
	GameState.missed_premium_count += 1
	
	popup_centered()

func _get_premium_salt() -> String:
	var salt = [
		"Someone is doing barrel rolls on YOUR Moonweave right now.",
		"You'll NEVER see a deal like that again.",
		"That's a month of walking you just missed.",
		"Hope you weren't planning on impressing anyone.",
		"Somewhere, a witch is laughing at the steal they just got.",
		"You could have been FLYING IN STYLE.",
		"Back to checking for regular ugly brooms, I guess...",
		"*plays funeral march*"
	]
	
	return salt[randi() % salt.size()]

func show_missed_broom(listing_name: String, minutes_ago: int, price: int):
	if minutes_ago <= 2:
		dialog_text = "ARE YOU KIDDING ME?!\n\n"
		dialog_text += "You missed a %s by %d MINUTE%s!\n" % [
			listing_name, 
			minutes_ago,
			"" if minutes_ago == 1 else "S"
		]
		dialog_text += "It was only $%d...\n\n" % price
		dialog_text += _get_salt_in_wound()
		
		# Make it sting
		modulate = Color(1, 0.9, 0.9)
		
	elif minutes_ago <= 5:
		dialog_text = "Oof. You just missed one.\n\n"
		dialog_text += "A %s sold %d minutes ago for $%d.\n\n" % [listing_name, minutes_ago, price]
		dialog_text += "Gotta be quicker than that!"
		
	else:
		dialog_text = "A %s sold %d minutes ago.\n\n" % [listing_name, minutes_ago]
		dialog_text += "Check more often if you want to catch them!"
	
	GameState.missed_broom_count += 1
	
	# Add insult to injury based on how many they've missed
	if GameState.missed_broom_count >= 10:
		dialog_text += "\n\n(You've missed %d brooms now...)" % GameState.missed_broom_count
	
	popup_centered()

func _get_salt_in_wound() -> String:
	var salt = [
		"Someone is flying home on YOUR broom right now.",
		"Hope you like walking!",
		"Your feet must be getting tired.",
		"Maybe try setting an alarm?",
		"That seller marked it SOLD while you were opening Croneslist.",
		"Someone bought it WHILE YOU WERE READING THIS.",
		"Better luck next time! (If there is a next time...)",
		"*sad trombone*"
	]
	
	return salt[randi() % salt.size()]

func show_sold_while_browsing(listing_name: String, price: int):
	dialog_text = "NO NO NO NO NO!\n\n"
	dialog_text += "The %s you were looking at JUST SOLD!\n\n" % listing_name
	dialog_text += "It was $%d! You were RIGHT THERE!\n\n" % price
	dialog_text += "WHY DIDN'T YOU CLICK FASTER?!"
	
	# Extra dramatic
	modulate = Color(1, 0.8, 0.8)
	
	# Shake the window for effect
	var original_pos = position
	var tween = create_tween()
	for i in range(3):
		tween.tween_property(self, "position", original_pos + Vector2(randf_range(-5, 5), randf_range(-5, 5)), 0.05)
		tween.tween_property(self, "position", original_pos, 0.05)
	
	popup_centered()