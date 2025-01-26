extends Node

var scoreboard_scene = "res://main_menu.tscn"

var start_tutorial_when_time_is_zero = 1.5
var tutorial_four_one_time = 2

@onready var master_bus = AudioServer.get_bus_index("Master")
@onready var music_slider = $RecipeCanvas/SliderControl/MusicSlider
@onready var tutorial_step_one = $RecipeCanvas/TutorialControl/Step_One
@onready var tutorial_step_two = $RecipeCanvas/TutorialControl/Step_Two
@onready var tutorial_step_three = $RecipeCanvas/TutorialControl/Step_Three
@onready var tutorial_step_four = $RecipeCanvas/TutorialControl/Step_Four 
@onready var tutorial_step_four_one = $RecipeCanvas/TutorialControl/Step_Four_One 
@onready var tutorial_step_four_two = $RecipeCanvas/TutorialControl/Step_Four_Two
@onready var tutorial_step_five = $RecipeCanvas/TutorialControl/Step_Five
@onready var cafe:Cafe = $Cafe
@onready var back_to_menu_timer = $BackToMenuTimer

var tutorial_step:int = 1
var player:Player = null
var tutorial_guest = null

func _enter_tree() -> void:
	Globals.cup_count = 0

func _ready() -> void:
	music_slider.value = Globals.music_volume
	Messenger.order_finished.connect(_on_cup_consumed)
	tutorial_step_one.visible = false
	tutorial_step_two.visible = false
	tutorial_step_three.visible = false
	tutorial_step_four.visible = false
	tutorial_step_four_one.visible = false
	tutorial_step_four_two.visible = false
	tutorial_step_five.visible = false
	player = Globals.player
	tutorial_guest = Globals.tutorial_guest
	player.enable_movement = Globals.watched_tutorial
	cafe.open_cafe = Globals.watched_tutorial

func _process(delta):
	if Globals.watched_tutorial:
		return
	
	if start_tutorial_when_time_is_zero > 0:
		start_tutorial_when_time_is_zero -= delta
		return
		
	match tutorial_step:
		1: 
			tutorial_step_one.visible = true
			if Input.is_action_just_pressed("game_interact"):
				tutorial_step_one.visible = false
				tutorial_step = 2
				player.enable_movement = true
		2:
			tutorial_step_two.visible = true
			if player.cup != null:
				tutorial_step_two.visible = false
				tutorial_step = 3
		3:
			tutorial_step_three.visible = true
			if player.cup.is_filled:
				tutorial_step_three.visible = false
				tutorial_step = 4
				tutorial_guest.place_order()
		4: 
			tutorial_step_four.visible = true
							
			if !tutorial_guest.has_order:
				tutorial_step = 5
				tutorial_step_four.visible = false
				tutorial_step_four_one.visible = false
				tutorial_step_four_two.visible = false
				tutorial_guest.exit_cafe()
				return
			
			if tutorial_four_one_time < 0:
				tutorial_step_four_one.visible = true
			else:
				tutorial_four_one_time -= delta
					
			if player.cup != null && player.cup.ingridients.size() > 0:
				tutorial_step_four_two.visible = true
		5:
			tutorial_step_five.visible = true
			if tutorial_guest == null || tutorial_guest.is_queued_for_deletion():
				tutorial_step_five.visible = false
				Globals.watched_tutorial = true
				cafe.open_cafe = true

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	Globals.music_volume = value
	pass # Replace with function body.
	
func _on_cup_consumed(_guest:Guest):
	if Globals.cup_count == 0:
		back_to_menu_timer.start()


func _on_back_to_menu_timer_timeout() -> void:
	SceneManager.change_scene(scoreboard_scene)
