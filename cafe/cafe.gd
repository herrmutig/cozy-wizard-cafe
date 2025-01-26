extends Node2D
class_name Cafe

@export var guest_scenes:Array[PackedScene]
@export var open_cafe:bool = false

@onready var guest_spawn_marker:Marker2D = $GuestSpawnMarker2D

var seats = []
var spawn_first_guest_after = 10
var had_already_a_guest = false

func _ready():
	Globals.guests_count = 0
	Globals.score = 0
	seats = find_children("*", "Seat")

func _process(delta:float):
	if had_already_a_guest || !open_cafe:
		return

	spawn_first_guest_after -= delta
	if spawn_first_guest_after < 0:
		_on_guest_spawn_timer_timeout()

func _on_guest_spawn_timer_timeout() -> void:
	if open_cafe == false:
		return
	
	if guest_scenes == null || guest_scenes.size() == 0:
		return
	
	for seat in seats:
		if seat.is_available:
			spawn_random_guest_with_seat(seat)
			Globals.guests_count += 1
			return

func spawn_random_guest_with_seat(seat:Seat):
		var rand_index = randi_range(0, guest_scenes.size() - 1)
		var guest_instance = guest_scenes[rand_index].instantiate()
		guest_instance.seat = seat
		guest_instance.exit_cafe_target = guest_spawn_marker
		seat.set_guest(guest_instance)
		add_child(guest_instance)
		guest_instance.global_position = guest_spawn_marker.global_position
		had_already_a_guest = true
