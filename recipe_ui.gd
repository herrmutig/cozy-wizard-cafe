extends Control

var order_bar_scene = preload("res://ui/order_bar.tscn")

var order_bar_instances = []
@onready var order_container = $MarginContainer/VBoxContainer
@onready var score_val_label = $MarginContainer/VBoxContainer/HBoxContainer/ScoreVal
func _ready() -> void:
	Messenger.new_order_created.connect(_order_created)
	Messenger.order_finished.connect(_order_finished)
	score_val_label.text = str(Globals.score)
	
func _order_created(guest:Guest):
	var instance = order_bar_scene.instantiate()
	instance.guest = guest
	order_container.add_child(instance)
	order_bar_instances.append(instance)
	
func _order_finished(guest:Guest):
	var index = -1
	var instance = null
	for order_bar in order_bar_instances:
		index +=1
		if order_bar.guest == guest:
			instance = order_bar
			break
	
	if index < 0:
		return
	
	# weird place to perform score calculations,
	# but again. Just a prototype. Light-Speed Development is key!
	if guest.last_order_was_correct:
		Globals.score += 10 * guest.last_order_ingridients_count * max(1, Globals.guests_count) * Globals.order_multiplier
		Globals.order_multiplier += 1
	else:
		Globals.order_multiplier = 1
		Globals.score -= 50
		# disallove negative score..
		Globals.score = max(0, Globals.score)
		
	score_val_label.text = str(Globals.score)
	order_bar_instances.remove_at(index)
	order_container.remove_child(instance)
	instance.queue_free()
