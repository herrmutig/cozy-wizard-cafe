extends Node2D
class_name Cup

@export var can_interact = true
@onready var a_sprite = $AnimatedSprite2D

@export var is_filled = false
@export var ingridients:Array[String] = []

var is_readied_first_time:bool = true
# cant use ready or enter_tree because cup is getting in and out
# of the tree when changing owners (guests, player, cafe)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_readied_first_time:
		Globals.cup_count += 1

	if is_filled:
		fill()
		_update_cup_fill()
	else:
		a_sprite.play("default")

func _update_cup_fill():
	if !is_filled:
		return
	var animation = ""
	
	# animations are ordered alphabetically.
	# check cup_spriteframes.tres how the animations are set up.
	# Quick and easy solution for prototyping but for real application
	# this setup becomes hard to maintain
	if ingridients.has("cinnamon"):
		animation += "cinnamon_"
	if ingridients.has("chocolate"):
		animation += "chocolate_"
	if ingridients.has("honey"):
		animation += "honey_"
	if ingridients.has("milk"):
		animation += "milk_"
	
	# remove ending _ 
	if animation.length() > 0:
		animation = animation.erase(animation.length() - 1, 1)
		a_sprite.play(animation)

func add_ingridient(ingridient:Ingridient):
	if !is_filled:
		return
	
	# bit bad naming. I want the "string name" of the ingridient
	# check out ingridient.gd...
	if !ingridients.has(ingridient.ingridient):
		ingridients.append(ingridient.ingridient)
		_update_cup_fill()

func fill():
	ingridients.clear()
	a_sprite.play("water")
	is_filled = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body is Player):
		body.set_interactable(self)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if (body is Player):
		body.notify_interactable_out_of_reach(self)
