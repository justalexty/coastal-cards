extends Node

# Stub for CompactMirror system - just for demo

class_name CompactMirror

static func add_message(sender: String, message: String):
	print("[" + sender + "]: " + message)

# Singleton
func _init():
	if not Engine.has_singleton("CompactMirror"):
		Engine.register_singleton("CompactMirror", self)