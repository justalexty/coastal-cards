extends Node
# AudioManager - Handles all game audio

var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 0.8

func _ready():
	print("AudioManager initialized")

func play_sfx(sound_name: String, volume: float = 0.0):
	# Placeholder for sound effects
	pass

func play_music(track_name: String, volume: float = 0.0):
	# Placeholder for background music
	pass

func stop_music():
	# Placeholder for stopping music
	pass

func set_master_volume(value: float):
	master_volume = clamp(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))

func set_sfx_volume(value: float):
	sfx_volume = clamp(value, 0.0, 1.0)
	# Update SFX bus if it exists

func set_music_volume(value: float):
	music_volume = clamp(value, 0.0, 1.0)
	# Update Music bus if it exists

func play_notification(sound_name: String):
	# Placeholder for notification sounds
	print("Playing notification: " + sound_name)
	play_sfx(sound_name)