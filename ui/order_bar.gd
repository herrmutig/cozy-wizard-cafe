extends Control

var guest:Guest
@onready var guest_image_rect:TextureRect = %GuestImage
@onready var rich_label:RichTextLabel = %RichTextLabel
@onready var happyness_bar:ProgressBar = %HappynessBar
# Build UI here... Orderbar gets adde by recipe_ui
func _ready() -> void:
	if guest:
		guest_image_rect.texture = guest.sprite.texture
		_show_order_text()

func _process(delta: float) -> void:
	if guest:
		happyness_bar.value = float(guest.happyness)
	 

func _show_order_text():
	var img_text:String = ""
	for img in guest.get_guest_bb_images():
		img_text += img + " "
	rich_label.text = img_text
	rich_label.visible = true
