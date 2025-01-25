extends Control

@onready var master_bus = AudioServer.get_bus_index("Master")
@onready var anim_player = $AnimationPlayer
@onready var score_container = %ScoreContainer
@onready var main_menu_container = %MainMenuContainer
@onready var music_slider = $Control/MusicSlider
@onready var score_label:Label = %Score
func _ready() -> void:
	anim_player.play("menu_anim")
	music_slider.value = Globals.music_volume
	score_label.text = str(Globals.score)

	if Globals.app_started_first_time == true:
		main_menu_container.visible = true
		score_container.visible = false
		Globals.app_started_first_time = false
	else:
		main_menu_container.visible = false
		score_container.visible = true
		
	


func _on_start_pressed() -> void:
	SceneManager.change_scene("res://game.tscn")
	pass # Replace with function body.


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	Globals.music_volume = value
