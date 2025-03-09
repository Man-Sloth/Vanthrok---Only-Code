extends Button

@onready var stat_remaining = $"../Panel/Amount"
@onready var strength_value = $"../Panel/Strength Box/Strength Value"
@onready var dexterity_value = $"../Panel/Dexterity Box/Dexterity Value"
@onready var intelligence_value = $"../Panel/Intelligence Box/Inteligence Value"
@onready var constitution_value = $"../Panel/Constitution Box/Constitution Value"
@onready var username_input = $"../Panel/Username Input"
@onready var character_selection = $"../../Character Selection"
@onready var character_creation = $".."

var default_scale: float = 0.125
var character_slot: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_down():
	scale.x = default_scale * 0.95
	scale.y = default_scale * 0.95


func _on_button_up():
	scale.x = default_scale * 1.05
	scale.y = default_scale * 1.05


func _on_mouse_entered():
	scale.x = default_scale * 1.05
	scale.y = default_scale * 1.05


func _on_mouse_exited():
	scale.x = default_scale
	scale.y = default_scale


func _on_pressed():
	if username_input.text != "":
		var char_name = username_input.text
		var slot = GameManager.character_slot
		var str = strength_value.text
		var dex = dexterity_value.text
		var intel = intelligence_value.text
		var con = constitution_value.text
		var remaining = stat_remaining.text
		
		GameServer.Save_Character(char_name, slot, str, dex, intel, con, remaining)
		character_creation.visible = false
		character_selection.visible = true
		
