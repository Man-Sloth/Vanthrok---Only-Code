extends Button
var default_scale: float = 1.0
@onready var amount: Label = $"../../Amount"
var default_amount: int = 10
@export var stat: Label
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var amount_value: int = int(amount.text)
	var stat_value: int = int(stat.text)
	if name == "Add_Button":
		if amount_value == 0:
			visible = false
		else:
			visible = true
	elif name == "Minus Button":
		if stat_value == default_amount:
			visible = false
		else:
			visible = true

func _on_mouse_entered():
	scale.x = default_scale * 1.10
	scale.y = default_scale * 1.10

func _on_mouse_exited():
	scale.x = default_scale
	scale.y = default_scale

func _on_button_down():
	scale.x = default_scale * 0.95
	scale.y = default_scale * 0.95

func _on_button_up():
	scale.x = default_scale * 1.10
	scale.y = default_scale * 1.10

func _on_pressed():
	var stat_value: int = int(stat.text)
	var amount_value: int = int(amount.text)
	if name == "Add_Button":
		if amount_value > 0:
			stat_value += 1
			amount_value -= 1
			stat.text = str(stat_value)
			amount.text = str(amount_value)
	elif name == "Minus Button":
		if stat_value > default_amount:
			stat_value -= 1
			amount_value += 1
			stat.text = str(stat_value)
			amount.text = str(amount_value)
