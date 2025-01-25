extends CharacterBody2D
class_name Player

const SLIDE_MULTIPLIER = 75

@export_range(50, 1000) var movement_speed:float = 150


@onready var anim_player:AnimationPlayer = $AnimationPlayer
@onready var cup_marker:Marker2D = $CupMarker2D
var interactable:Node2D
var cup:Cup

func _physics_process(delta: float) -> void:
	var move_vector = get_move_vector()
	_handle_movement(move_vector, delta)
	_handle_animation(move_vector)
	_handle_interaction()

func _handle_interaction():
	# do we have an interactable and if so can we interact with it?
	if !interactable || (interactable.get(&"can_interact") != null && interactable.get(&"can_interact") == false):
		return
	
	if Input.is_action_just_pressed("game_interact"):		
		if interactable is Cup:
			_pick_up_cup(interactable)
		elif interactable is Boiler:
			_interact_with_boiler(interactable)
		elif interactable is Ingridient:
			_interact_with_ingridient(interactable)
		elif interactable is Guest:
			_interact_with_guest(interactable)
		else:
			printerr("interactable was not found")

func _handle_movement(move_vector:Vector2, delta:float):
	velocity = move_vector * ceil(movement_speed * delta);
	
	var collision = move_and_collide(velocity)
	# when colliding with walls the player can slide along the normal with 
	# a speed that does not feel laggy ( = SLIDE_MULTIPLIER's purpose)
	if (collision != null):
		velocity = velocity.slide(collision.get_normal()) * SLIDE_MULTIPLIER

	move_and_slide()
	
func _handle_animation(move_vector:Vector2):
	# handle animation, You could also use move_vector == Vector2.ZERO. doesn't matter.
	if move_vector.length_squared() > 0.01:
		anim_player.play(&"walk")
	else:
		anim_player.play(&"idle")

func _pick_up_cup(new_cup:Cup):
	new_cup.get_parent().remove_child(new_cup)
	new_cup.position = cup_marker.position
	new_cup.can_interact = false
	add_child(new_cup)
	
	if (cup):
		remove_child(cup)
		cup.global_position = global_position
		get_tree().root.call_deferred(&"add_child", cup)
		cup.can_interact = true
	
	cup = new_cup

func _interact_with_boiler(_boiler:Boiler):
	if cup:
		cup.fill()
	else:
		print("Player has no cup")

func _interact_with_guest(guest:Guest):
	if cup:
		if guest.take_cup(cup):
			cup = null # freeing cup to avoid bad references
	else:
		print("No cup for guest. maybe random dialogs to show?")

func _interact_with_ingridient(ingridient:Ingridient):
	if cup && cup._is_filled:
		cup.add_ingridient(ingridient)
	else:
		print("Cup is missing or cup is not filled.")

# public methods
func get_move_vector() -> Vector2:
	return Input.get_vector("game_move_left", "game_move_right", "game_move_up", "game_move_down")


# Interaction Methods
func set_interactable(new_interactable:Node2D):
	if (new_interactable is Cup && cup != null): 
		return
	interactable = new_interactable 

func notify_interactable_out_of_reach(oor_interactable:Node2D):
	if oor_interactable == interactable:
		interactable = null
