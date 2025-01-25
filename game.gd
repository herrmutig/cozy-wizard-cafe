extends Node

@onready var music_bus = AudioServer.get_bus_index("Music")
@onready var music_slider = $RecipeCanvas/Control/MusicSlider
func _ready() -> void:
	music_slider.value = Globals.music_volume

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))
	Globals.music_volume = value
	pass # Replace with function body.
