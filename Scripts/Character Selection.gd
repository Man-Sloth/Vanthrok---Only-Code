extends Control

@onready var cname0 = $"Panel/Character Slot 0/Character Name"
@onready var cname1 = $"Panel/Character Slot 1/Character Name"
@onready var cname2 = $"Panel/Character Slot 2/Character Name"
@onready var cname3 = $"Panel/Character Slot 3/Character Name"

@onready var button = $"Panel/Character Slot 0/Button"
@onready var button_2 = $"Panel/Character Slot 1/Button2"
@onready var button_3 = $"Panel/Character Slot 2/Button3"
@onready var button_4 = $"Panel/Character Slot 3/Button4"
@onready var character_creation = $"../Character Creation"
@onready var character_0 = $"Panel/Character Slot 0/Character 0"
@onready var character_1 = $"Panel/Character Slot 1/Character 1"
@onready var character_2 = $"Panel/Character Slot 2/Character 2"
@onready var character_3 = $"Panel/Character Slot 3/Character 3"


var default_scale = 1

func _process(delta):
	if GameManager.logged_in:
		if GameManager.characters.has("0"):
			cname0.text = GameManager.characters["0"]["name"]
			button.visible = false
			character_0.visible = true
		if GameManager.characters.has("1"):
			cname1.text = GameManager.characters["1"]["name"]
			button_2.visible = false
			character_1.visible = true
		if GameManager.characters.has("2"):
			cname2.text = GameManager.characters["2"]["name"]
			button_3.visible = false
			character_2.visible = true
		if GameManager.characters.has("3"):
			cname3.text = GameManager.characters["3"]["name"]
			button_4.visible = false
			character_3.visible = true


func _on_button_pressed():
	character_creation.visible = true
	GameManager.character_slot = 0
	visible = false

func _on_button_2_pressed():
	character_creation.visible = true
	GameManager.character_slot = 1
	visible = false
	
func _on_button_3_pressed():
	character_creation.visible = true
	GameManager.character_slot = 2
	visible = false

func _on_button_4_pressed():
	character_creation.visible = true
	GameManager.character_slot = 3
	visible = false

func _on_button_mouse_entered():
	button.scale.x = default_scale * 1.05
	button.scale.y = default_scale * 1.05

func _on_button_2_mouse_entered():
	button_2.scale.x = default_scale * 1.05
	button_2.scale.y = default_scale * 1.05

func _on_button_3_mouse_entered():
	button_3.scale.x = default_scale * 1.05
	button_3.scale.y = default_scale * 1.05

func _on_button_4_mouse_entered():
	button_4.scale.x = default_scale * 1.05
	button_4.scale.y = default_scale * 1.05

func _on_button_mouse_exited():
	button.scale.x = default_scale
	button.scale.y = default_scale
	
func _on_button_2_mouse_exited():
	button_2.scale.x = default_scale
	button_2.scale.y = default_scale

func _on_button_3_mouse_exited():
	button_3.scale.x = default_scale
	button_3.scale.y = default_scale

func _on_button_4_mouse_exited():
	button_4.scale.x = default_scale
	button_4.scale.y = default_scale

func _on_button_button_down():
	button.scale.x = default_scale * 0.95
	button.scale.y = default_scale * 0.95

func _on_button_2_button_down():
	button_2.scale.x = default_scale * 0.95
	button_2.scale.y = default_scale * 0.95

func _on_button_3_button_down():
	button_3.scale.x = default_scale * 0.95
	button_3.scale.y = default_scale * 0.95

func _on_button_4_button_down():
	button_4.scale.x = default_scale * 0.95
	button_4.scale.y = default_scale * 0.95

func _on_button_button_up():
	button.scale.x = default_scale * 1.05
	button.scale.y = default_scale * 1.05

func _on_button_2_button_up():
	button_2.scale.x = default_scale * 1.05
	button_2.scale.y = default_scale * 1.05

func _on_button_3_button_up():
	button_3.scale.x = default_scale * 1.05
	button_3.scale.y = default_scale * 1.05

func _on_button_4_button_up():
	button_4.scale.x = default_scale * 1.05
	button_4.scale.y = default_scale * 1.05

func _on_character_0_pressed():
	GameManager.selected_character = GameManager.characters["0"]
	get_node("/root/OmegaScene/CanvasLayer").queue_free()
	get_node("/root/OmegaScene/Map").visible = true
	get_node("/root/OmegaScene/Map/CanvasLayer").visible = true
	
