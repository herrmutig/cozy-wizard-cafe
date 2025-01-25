extends Node

var scoreboard_scene = "res://main_menu.tscn"

@onready var master_bus = AudioServer.get_bus_index("Master")
@onready var music_slider = $RecipeCanvas/Control/MusicSlider

func _enter_tree() -> void:
	Globals.cup_count = 0

func _ready() -> void:
	music_slider.value = Globals.music_volume
	Messenger.order_finished.connect(_on_cup_consumed)

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	Globals.music_volume = value
	pass # Replace with function body.
	
func _on_cup_consumed(guest:Guest):
	if Globals.cup_count == 0:
		SceneManager.change_scene(scoreboard_scene)
		
