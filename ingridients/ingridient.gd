extends Node2D
class_name Ingridient

@export var ingridient:String = ""

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body is Player):
		body.set_interactable(self)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if (body is Player):
		body.notify_interactable_out_of_reach(self)
