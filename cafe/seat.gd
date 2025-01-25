extends Marker2D
class_name Seat

var is_available: 
	get: return guest == null
var guest:Guest

func set_guest(new_guest:Guest):
	guest = new_guest
	
