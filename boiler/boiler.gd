extends Node2D
class_name Boiler

@onready var a_sprite:AnimatedSprite2D = $AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	a_sprite.play("default")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body is Player):
		body.set_interactable(self)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if (body is Player):
		body.notify_interactable_out_of_reach(self)
