extends Node

# Simple scene manager for transitions

# class_name SceneManager

func change_scene(path: String):
	get_tree().change_scene_to_file(path)

# Singleton
func _init():
	if not Engine.has_singleton("SceneManager"):
		Engine.register_singleton("SceneManager", self)