extends Control

# Financial pressure tracker UI
# Shows money, days until rent, and broom savings progress

class_name FinancialTracker

@onready var money_label = $Panel/VBox/MoneyLabel
@onready var rent_label = $Panel/VBox/RentLabel
@onready var rent_progress = $Panel/VBox/RentProgress
@onready var broom_label = $Panel/VBox/BroomLabel
@onready var broom_progress = $Panel/VBox/BroomProgress

var pulse_timer: float = 0.0
var show_warnings: bool = true

func _ready():
	_update_display()
	
	# Update every game hour
	GameState.time_changed.connect(_update_display)
	GameState.money_changed.connect(_on_money_changed)

func _process(delta):
	# Pulse warning colors
	if GameState.days_until_rent <= 3 and GameState.days_until_rent > 0:
		pulse_timer += delta
		var pulse = (sin(pulse_timer * 3.0) + 1.0) / 2.0
		rent_label.modulate = Color(1, pulse, pulse)

func _update_display():
	# Money display
	money_label.text = "$%.2f" % GameState.current_money
	
	# Color code based on immediate needs
	if GameState.current_money < 8:
		money_label.modulate = Color(1, 0.5, 0.5)  # Red - can't afford food
		money_label.text += " 🍽️!"  # Hungry indicator
	elif GameState.current_money < 25:
		money_label.modulate = Color(1, 1, 0.5)  # Yellow - low funds
	else:
		money_label.modulate = Color.WHITE
	
	# Rent tracker
	if GameState.days_overdue > 0:
		rent_label.text = "RENT OVERDUE: %d days" % GameState.days_overdue
		rent_label.modulate = Color(1, 0.2, 0.2)
		
		var late_fee = GameState.get_late_fee()
		rent_label.text += "\nTotal due: $%d" % (GameState.rent_amount + late_fee)
		
		rent_progress.value = 0
		rent_progress.modulate = Color(1, 0.2, 0.2)
	else:
		rent_label.text = "Rent due: %d days" % GameState.days_until_rent
		
		# Progress bar shows money saved toward rent
		rent_progress.max_value = GameState.rent_amount
		rent_progress.value = min(GameState.current_money, GameState.rent_amount)
		
		# Color based on urgency and progress
		if GameState.days_until_rent <= 3:
			if GameState.current_money >= GameState.rent_amount:
				rent_progress.modulate = Color(0.5, 1, 0.5)  # Green - can pay
				rent_label.text += " ✓"
			else:
				rent_progress.modulate = Color(1, 0.5, 0.5)  # Red - urgent
				rent_label.text += " ⚠️"
		elif GameState.days_until_rent <= 7:
			rent_progress.modulate = Color(1, 1, 0.5)  # Yellow - warning
		else:
			rent_progress.modulate = Color.WHITE
	
	# Broom savings tracker
	if GameState.has_broom:
		broom_label.text = "Broom: %s" % GameState.broom_data.get("name", "Basic")
		broom_progress.visible = false
		
		# Show condition warning
		if GameState.broom_data.get("condition", "") == "needs_work":
			broom_label.text += " ⚠️"
			broom_label.modulate = Color(1, 0.8, 0.5)
	else:
		broom_label.text = "Broom fund"
		broom_progress.visible = true
		
		# Track progress toward cheapest broom
		var cheapest_broom = 200  # Used trainee broom
		broom_progress.max_value = cheapest_broom
		
		# Only count money above rent needs
		var available_for_broom = max(0, GameState.current_money - GameState.rent_amount)
		broom_progress.value = available_for_broom
		
		# Show percentage
		var percent = (available_for_broom / cheapest_broom) * 100
		broom_label.text += ": %d%%" % percent
		
		if percent >= 100:
			broom_label.modulate = Color(0.5, 1, 0.5)
			broom_label.text += " 🧹✓"
			
			# Show Croneslist notification
			if show_warnings:
				_show_croneslist_hint()

func _on_money_changed(amount: float):
	_update_display()
	
	# Animate money change
	var change_label = Label.new()
	change_label.text = "+$%.2f" % amount if amount > 0 else "-$%.2f" % abs(amount)
	change_label.modulate = Color(0.5, 1, 0.5) if amount > 0 else Color(1, 0.5, 0.5)
	
	add_child(change_label)
	change_label.position = money_label.position + Vector2(50, 0)
	
	var tween = create_tween()
	tween.parallel().tween_property(change_label, "position:y", change_label.position.y - 30, 1.0)
	tween.parallel().tween_property(change_label, "modulate:a", 0, 1.0)
	tween.tween_callback(change_label.queue_free)

func _show_croneslist_hint():
	var hint = preload("res://scenes/ui/notification_popup.tscn").instantiate()
	hint.text = "You can afford a used broom! Check Croneslist in your compact."
	get_tree().root.add_child(hint)
	show_warnings = false  # Don't spam

func show_financial_summary():
	# Called at end of day
	var summary_text = "Daily Summary:\n"
	summary_text += "Earnings: $%.2f\n" % GameState.todays_earnings
	summary_text += "Expenses: $%.2f\n" % GameState.todays_expenses
	summary_text += "Net: $%.2f\n" % (GameState.todays_earnings - GameState.todays_expenses)
	
	if GameState.days_until_rent <= 7:
		var needed_daily = (GameState.rent_amount - GameState.current_money) / GameState.days_until_rent
		summary_text += "\nNeed $%.2f/day for rent!" % needed_daily
	
	# Show summary popup
	var popup = AcceptDialog.new()
	popup.dialog_text = summary_text
	popup.title = "End of Day %d" % GameState.current_day
	get_tree().root.add_child(popup)
	popup.popup_centered()
	popup.popup_hide.connect(popup.queue_free)