extends Node

# Calendar system tracking dates, lunar cycles, and witch holidays
class_name CalendarSystem

signal day_changed(date_info)
signal lunar_phase_changed(phase)
signal holiday_reached(holiday_name)
signal rent_warning(days_left)

# Month names and days
const MONTHS = ["March", "April", "May", "June", "July", "August", 
                "September", "October", "November", "December", "January", "February"]
const DAYS_IN_MONTH = [31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31, 28]  # Non-leap year
const WEEKDAYS = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

# Game always starts March 1st
var current_year: int = 2024  # Or whatever year makes sense
var current_month: int = 0  # 0 = March (our first month)
var current_day: int = 1
var total_days_elapsed: int = 0

# Lunar cycle (29.5 days)
const LUNAR_CYCLE_LENGTH = 29.5
var moon_phase_names = ["New Moon", "Waxing Crescent", "First Quarter", "Waxing Gibbous", 
                        "Full Moon", "Waning Gibbous", "Last Quarter", "Waning Crescent"]

# Major holidays
var holidays = {
	# Fixed date holidays
	"Spring Equinox": {"month": "March", "day": 20, "importance": "major"},
	"Summer Solstice": {"month": "June", "day": 21, "importance": "major"},
	"Autumn Equinox": {"month": "September", "day": 22, "importance": "major"},
	"Winter Solstice": {"month": "December", "day": 21, "importance": "major"},
	
	# Minor witch holidays
	"Beltane": {"month": "May", "day": 1, "importance": "minor"},
	"Lammas": {"month": "August", "day": 1, "importance": "minor"},
	"Samhain": {"month": "October", "day": 31, "importance": "minor"},
	"Imbolc": {"month": "February", "day": 2, "importance": "minor"},
	
	# Modern witch culture
	"International Witch Day": {"month": "March", "day": 31, "importance": "minor"},
	"Black Cat Appreciation": {"month": "October", "day": 27, "importance": "minor"},
	"Broom Blessing Day": {"month": "May", "day": 15, "importance": "minor"}
}

# Lunar New Year (varies - calculate based on actual lunar calendar)
# For simplicity, using fixed dates that approximate real dates
var lunar_new_years = {
	2024: {"month": "February", "day": 10},
	2025: {"month": "January", "day": 29},
	2026: {"month": "February", "day": 17}
}

func _ready():
	_calculate_weekday()

func advance_day():
	current_day += 1
	total_days_elapsed += 1
	
	# Check if we need to advance month
	if current_day > DAYS_IN_MONTH[current_month]:
		current_day = 1
		current_month += 1
		
		# Wrap around year
		if current_month >= MONTHS.size():
			current_month = 0
			current_year += 1
	
	# Check for events
	_check_holidays()
	_check_rent_due()
	_check_lunar_events()
	
	# Emit signal with current date info
	var date_info = get_current_date_info()
	day_changed.emit(date_info)

func get_current_date_info() -> Dictionary:
	return {
		"year": current_year,
		"month": MONTHS[current_month],
		"month_num": current_month,
		"day": current_day,
		"weekday": _get_weekday(),
		"moon_phase": _get_moon_phase(),
		"days_until_rent": _get_days_until_rent(),
		"total_days": total_days_elapsed,
		"season": _get_season(),
		"holiday": _get_todays_holiday()
	}

func _get_weekday() -> String:
	# Calculate day of week (March 1, 2024 was a Friday)
	var days_from_start = total_days_elapsed
	var weekday_index = (4 + days_from_start) % 7  # 4 = Friday
	return WEEKDAYS[weekday_index]

func _calculate_weekday():
	# Helper for initialization
	pass

func _get_moon_phase() -> Dictionary:
	# New moon on March 10, 2024 as reference
	var days_since_new_moon = total_days_elapsed + 9  # March 1 to March 10
	var moon_age = fmod(days_since_new_moon, LUNAR_CYCLE_LENGTH)
	var phase_index = int((moon_age / LUNAR_CYCLE_LENGTH) * 8)
	
	return {
		"name": moon_phase_names[phase_index],
		"emoji": _get_moon_emoji(phase_index),
		"age_days": moon_age,
		"illumination": _calculate_illumination(moon_age),
		"is_powerful": phase_index == 0 or phase_index == 4  # New and Full
	}

func _get_moon_emoji(phase_index: int) -> String:
	var emojis = ["🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘"]
	return emojis[phase_index]

func _calculate_illumination(moon_age: float) -> float:
	# Simple approximation of moon illumination
	if moon_age <= LUNAR_CYCLE_LENGTH / 2:
		return (moon_age / (LUNAR_CYCLE_LENGTH / 2)) * 100
	else:
		return ((LUNAR_CYCLE_LENGTH - moon_age) / (LUNAR_CYCLE_LENGTH / 2)) * 100

func _get_days_until_rent() -> int:
	# Rent due on the 1st of each month
	if current_day == 1:
		return 0  # Due today!
	else:
		return DAYS_IN_MONTH[current_month] - current_day + 1

func _get_season() -> String:
	match MONTHS[current_month]:
		"March", "April", "May":
			return "Spring"
		"June", "July", "August":
			return "Summer"
		"September", "October", "November":
			return "Autumn"
		"December", "January", "February":
			return "Winter"
	return ""

func _get_todays_holiday() -> String:
	var month_name = MONTHS[current_month]
	
	# Check fixed holidays
	for holiday_name in holidays:
		var holiday = holidays[holiday_name]
		if holiday.month == month_name and holiday.day == current_day:
			return holiday_name
	
	# Check Lunar New Year
	if current_year in lunar_new_years:
		var lny = lunar_new_years[current_year]
		if lny.month == month_name and lny.day == current_day:
			return "LUNAR NEW YEAR!"  # Biggest holiday!
	
	return ""

func _check_holidays():
	var holiday = _get_todays_holiday()
	if holiday != "":
		holiday_reached.emit(holiday)
		
		# Special effects for major holidays
		if holiday == "LUNAR NEW YEAR!":
			GameState.add_holiday_bonus("lunar_new_year")
		elif holiday in ["Spring Equinox", "Summer Solstice", "Autumn Equinox", "Winter Solstice"]:
			GameState.add_holiday_bonus("major_sabbat")

func _check_rent_due():
	var days_left = _get_days_until_rent()
	
	match days_left:
		7:
			rent_warning.emit(7)
			CompactMirror.add_message("Landlord", "Friendly reminder: Rent of $700 due in one week!")
		3:
			rent_warning.emit(3)
			CompactMirror.add_message("Landlord", "Rent due in 3 days. $700 please.")
		1:
			rent_warning.emit(1)
			CompactMirror.add_message("Landlord", "RENT DUE TOMORROW! Don't be late!")
		0:
			if not GameState.is_rent_paid:
				CompactMirror.add_message("Landlord", "Rent is DUE TODAY. $700 + any late fees.")

func _check_lunar_events():
	var moon = _get_moon_phase()
	
	# Special events on new and full moons
	if moon.name == "New Moon" and total_days_elapsed > 0:
		lunar_phase_changed.emit(moon)
		CompactMirror.add_message("WitchNet", "🌑 New Moon tonight! Ideal for new beginnings and setting intentions.")
	elif moon.name == "Full Moon":
		lunar_phase_changed.emit(moon)
		CompactMirror.add_message("WitchNet", "🌕 Full Moon rising! Enhanced intuition for readings.")

func get_date_string() -> String:
	var weekday = _get_weekday()
	var month = MONTHS[current_month]
	var suffix = _get_day_suffix(current_day)
	
	var date_str = "%s, %s %d%s" % [weekday, month, current_day, suffix]
	
	# Add holiday if there is one
	var holiday = _get_todays_holiday()
	if holiday != "":
		date_str += " - " + holiday
	
	return date_str

func _get_day_suffix(day: int) -> String:
	if day % 10 == 1 and day != 11:
		return "st"
	elif day % 10 == 2 and day != 12:
		return "nd"
	elif day % 10 == 3 and day != 13:
		return "rd"
	else:
		return "th"

func get_calendar_view() -> String:
	# Generate a mini calendar view for the UI
	var cal = "« %s %d »\n" % [MONTHS[current_month], current_year]
	cal += "Su Mo Tu We Th Fr Sa\n"
	
	# Figure out what day of week the 1st falls on
	var first_weekday = _get_first_of_month_weekday()
	
	# Add spacing for first week
	for i in range(first_weekday):
		cal += "   "
	
	# Add all days
	for day in range(1, DAYS_IN_MONTH[current_month] + 1):
		if day == current_day:
			cal += "[%2d]" % day  # Highlight current day
		else:
			cal += " %2d " % day
		
		# New line after Saturday
		if (first_weekday + day - 1) % 7 == 6:
			cal += "\n"
	
	# Add moon phase
	var moon = _get_moon_phase()
	cal += "\n" + moon.emoji + " " + moon.name
	
	return cal

func _get_first_of_month_weekday() -> int:
	# Calculate what day of week the 1st is
	var days_into_month = current_day - 1
	var current_weekday_index = WEEKDAYS.find(_get_weekday())
	var first_weekday_index = (current_weekday_index - days_into_month) % 7
	if first_weekday_index < 0:
		first_weekday_index += 7
	return first_weekday_index

# Singleton
func _init():
	if not Engine.has_singleton("Calendar"):
		Engine.register_singleton("Calendar", self)