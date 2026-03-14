extends PanelContainer

# Calendar UI display widget
class_name CalendarDisplay

@onready var date_label = $VBox/DateLabel
@onready var moon_label = $VBox/MoonLabel
@onready var rent_label = $VBox/RentLabel
@onready var holiday_label = $VBox/HolidayLabel
@onready var calendar_view = $VBox/CalendarView

var calendar: CalendarSystem
var pulse_timer: float = 0.0

func _ready():
	calendar = get_node("/root/Calendar")
	calendar.day_changed.connect(_on_day_changed)
	calendar.holiday_reached.connect(_on_holiday)
	calendar.rent_warning.connect(_on_rent_warning)
	
	_update_display()

func _process(delta):
	# Pulse rent warning when close
	var days_until_rent = calendar._get_days_until_rent()
	if days_until_rent <= 3 and days_until_rent > 0:
		pulse_timer += delta * 3
		var pulse = (sin(pulse_timer) + 1.0) / 2.0
		rent_label.modulate = Color(1, pulse, pulse)
	elif days_until_rent == 0 and not GameState.is_rent_paid:
		# Flash red on rent day
		pulse_timer += delta * 6
		var pulse = (sin(pulse_timer) + 1.0) / 2.0
		rent_label.modulate = Color(1, 0, 0, pulse)

func _update_display():
	var date_info = calendar.get_current_date_info()
	
	# Date display
	date_label.text = calendar.get_date_string()
	
	# Moon phase
	var moon = date_info.moon_phase
	moon_label.text = moon.emoji + " " + moon.name
	
	if moon.is_powerful:
		moon_label.add_theme_color_override("font_color", Color(0.9, 0.8, 1.0))
		moon_label.text += " ✨"
	else:
		moon_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	
	# Rent countdown
	var days_until = date_info.days_until_rent
	if days_until == 0:
		rent_label.text = "RENT DUE TODAY!"
		rent_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	elif days_until == 1:
		rent_label.text = "Rent due TOMORROW"
		rent_label.add_theme_color_override("font_color", Color(1, 0.5, 0.2))
	else:
		rent_label.text = "Rent in %d days" % days_until
		if days_until <= 7:
			rent_label.add_theme_color_override("font_color", Color(1, 0.8, 0.3))
		else:
			rent_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	
	# Holiday
	if date_info.holiday != "":
		holiday_label.visible = true
		holiday_label.text = "🎊 " + date_info.holiday + " 🎊"
		
		if date_info.holiday == "LUNAR NEW YEAR!":
			holiday_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
			holiday_label.add_theme_font_size_override("font_size", 16)
		else:
			holiday_label.add_theme_color_override("font_color", Color(0.8, 0.9, 1))
			holiday_label.add_theme_font_size_override("font_size", 14)
	else:
		holiday_label.visible = false
	
	# Mini calendar
	calendar_view.text = calendar.get_calendar_view()

func _on_day_changed(date_info: Dictionary):
	_update_display()

func _on_holiday(holiday_name: String):
	# Special holiday notification
	var notification = preload("res://scenes/ui/holiday_notification.tscn").instantiate()
	notification.set_holiday(holiday_name)
	get_tree().root.add_child(notification)
	
	# Special effects for major holidays
	if holiday_name == "LUNAR NEW YEAR!":
		# Fireworks or special animation
		_show_lunar_new_year_effects()

func _on_rent_warning(days_left: int):
	# Animate the rent label
	var tween = create_tween()
	tween.tween_property(rent_label, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(rent_label, "scale", Vector2(1.0, 1.0), 0.2)

func _show_lunar_new_year_effects():
	# Could spawn particle effects, play special sounds, etc.
	AudioManager.play_sfx("fireworks")
	
	# Give player a lucky bonus
	var bonus_text = "Lunar New Year Luck! +20% reading accuracy today!"
	CompactMirror.add_message("Holiday Spirit", bonus_text)

# Minimal calendar for status bar
func get_minimal_display() -> String:
	var date_info = calendar.get_current_date_info()
	var date = "%s %d" % [date_info.month.substr(0, 3), date_info.day]
	var moon = date_info.moon_phase.emoji
	
	if date_info.holiday != "":
		return date + " " + moon + " 🎊"
	else:
		return date + " " + moon