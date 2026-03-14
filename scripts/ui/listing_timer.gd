extends PanelContainer

# Individual listing timer updater

var listing_data: Dictionary
var timer_label: Label
var croneslist_timer: CroneslistTimer

func _ready():
	croneslist_timer = get_node("/root/CroneslistTimer")

func update_timer():
	if not timer_label or not listing_data:
		return
		
	var minutes_left = croneslist_timer.get_minutes_remaining(listing_data)
	
	if minutes_left <= 0:
		timer_label.text = "SOLD"
		timer_label.modulate = Color(0.5, 0.5, 0.5)
		get_node("BuyButton").disabled = true
		return
	
	# Update text
	if minutes_left == 1:
		timer_label.text = "1 min left!"
	else:
		timer_label.text = "%d min left" % minutes_left
	
	# Update color based on urgency
	if minutes_left <= 2:
		# Blink red for final 2 minutes
		var blink = sin(Time.get_ticks_msec() / 200.0) * 0.5 + 0.5
		timer_label.modulate = Color(1, blink, blink)
		timer_label.text = "HURRY! " + timer_label.text
	elif minutes_left <= 5:
		timer_label.modulate = Color(1, 0.3, 0.3)
	elif minutes_left <= 10:
		timer_label.modulate = Color(1, 0.8, 0.3)
	else:
		timer_label.modulate = Color(0.8, 1, 0.8)