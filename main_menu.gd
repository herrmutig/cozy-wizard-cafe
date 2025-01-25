extends Control

@onready var music_bus = AudioServer.get_bus_index("Music")
@onready var anim_player = $AnimationPlayer

func _ready() -> void:
	anim_player.play("menu_anim")


func _on_start_pressed() -> void:
	SceneManager.change_scene("res://game.tscn")
	pass # Replace with function body.


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))
	Globals.music_volume = value
	pass # Replace with function body.
