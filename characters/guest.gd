extends CharacterBody2D
class_name Guest

#TODO Add Tutorial...

@export var movement_speed:float = 70
@export var wrong_drink_saddness = 20

var cinnamon_bb_img = "[img=20]res://ingridients/cinnamon.png[/img]"
var chocolate_bb_img = "[img=20]res://ingridients/chocolate.png[/img]"
var honey_bb_img = "[img=20]res://ingridients/honey.png[/img]"
var milk_bb_img = "[img=20]res://ingridients/milk.png[/img]"

var seat:Seat
var exit_cafe_target:Marker2D
var ingridients_to_order = ["cinnamon", "chocolate", "honey", "milk"]
var current_guest_order = []
var cup:Cup = null
var has_order:bool = false
var last_order_was_correct = false
var last_order_ingridients_count = 0
var happyness:int = 100
var wants_to_exit:bool = false

@onready var is_tutorial_guest = false
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var cup_marker:Marker2D = $CupMarker2D
@onready var speech_bubble_control = $SpeechBubbleControl
@onready var bubble_richtext:RichTextLabel = %BubbleRichText
@onready var consuming_order_timer:Timer = $ConsumingOrderTimer
@onready var place_order_timer:Timer = $PlaceOrderTimer
@onready var sprite:Sprite2D = $CharacterSprite2D
@onready var anim_player:AnimationPlayer = $AnimationPlayer
@onready var happyness_timer:Timer = $HappynessTimer
@onready var happy_audio_player = $HappyAudioStreamPlayer
@onready var sad_audio_player = $SadAudioStreamPlayer

func _ready():
	place_order_timer.start()
	speech_bubble_control.visible = false
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
	
	if (Globals.watched_tutorial):
		is_tutorial_guest = false
	else:
		Globals.watched_tutorial = true
	
	if seat != null:
		set_movement_target(seat.global_position)
	
func _physics_process(delta):
	_physics_navigation_process(delta)

	if navigation_agent.is_navigation_finished():
		anim_player.play(&"character_anim_library/idle")
	else:
		anim_player.play(&"character_anim_library/walk")
# navigation agent stuff
func set_movement_target(movement_target: Vector2):
	navigation_agent.set_target_position(movement_target)

func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()

func _physics_navigation_process(_delta):
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		if wants_to_exit == true:
			if seat:
				seat.set_guest(null)
			queue_free()
		return

	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func get_guest_bb_images() -> Array[String]:
	var bb_images:Array[String] = [] 
	if current_guest_order.has("cinnamon"):
		bb_images.append(cinnamon_bb_img)
	if current_guest_order.has("chocolate"):
		bb_images.append(chocolate_bb_img)
	if current_guest_order.has("honey"):
		bb_images.append(honey_bb_img)
	if current_guest_order.has("milk"):
		bb_images.append(milk_bb_img)
	return bb_images
		
func _create_random_order():
	var ingridients_count = randi_range(1, 4)
	var available_ingridients = ingridients_to_order.duplicate()
	current_guest_order = []
	
	for _i in range(0, ingridients_count):
		var random_index = randi_range(0, available_ingridients.size() - 1)
		var random_ingridient = available_ingridients[random_index]
		
		if !current_guest_order.has(random_ingridient):
			available_ingridients.remove_at(random_index)
			current_guest_order.append(random_ingridient)
	
	Messenger.new_order_created.emit(self)

func take_cup(cup_to_consume:Cup) -> bool:
	if (cup != null || has_order == false):
		return false
	
	if check_ingridients(cup_to_consume.ingridients):
		last_order_was_correct = true
		last_order_ingridients_count = cup_to_consume.ingridients.size()
		happy_audio_player.play()
	else:
		last_order_was_correct = false
		last_order_ingridients_count = 0
		sad_audio_player.play()
	
	cup_to_consume.get_parent().remove_child(cup_to_consume)
	add_child(cup_to_consume)
	cup_to_consume.position = cup_marker.position
	cup = cup_to_consume
	consuming_order_timer.start()
	speech_bubble_control.visible = false
	has_order = false
	Globals.cup_count = max(0, Globals.cup_count - 1)
	Messenger.order_finished.emit(self)
	return true

func check_ingridients(compare_ingridients) -> bool:
	if compare_ingridients.size() != current_guest_order.size():
		happyness -= max(0, wrong_drink_saddness)
		return false
	
	for ingridient in compare_ingridients:
		if !current_guest_order.has(ingridient):
			happyness -= max(0, wrong_drink_saddness)
			return false
	
	happyness = 100
	return true
		

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body is Player):
		print("interactable found")
		body.set_interactable(self)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if (body is Player):
		body.notify_interactable_out_of_reach(self)


func _on_consuming_order_timer_timeout() -> void:
	# free cup
	cup.queue_free()
	place_order_timer.start()
	
func _on_place_order_timer_timeout() -> void:
	_create_random_order()
	_show_order_bubble_text()
	speech_bubble_control.visible = true
	has_order = true
	
# BB Texts
func _show_order_bubble_text():
	var img_text:String = ""
	for img in get_guest_bb_images():
		img_text += img + " "
	bubble_richtext.text = img_text
	bubble_richtext.visible = true

func _on_happyness_timer_timeout() -> void:
	if has_order:
		happyness = max(0, happyness - 1)
	
	if happyness == 0 && !wants_to_exit:
		if exit_cafe_target:
			speech_bubble_control.visible = false
			has_order = false
			happyness_timer.stop()
			set_movement_target(exit_cafe_target.global_position)
					
		Messenger.order_finished.emit(self)
		wants_to_exit = true
