extends Panel

@onready var health_bar = $"GridContainer/Health Bar"
@onready var mana_bar = $"GridContainer/Mana Bar"
@onready var food_bar = $"GridContainer/Food Bar"
@onready var exp_bar = $"GridContainer/Experience Bar"
@onready var encumbrance_bar = $"GridContainer/Encumbrance Bar"

@onready var health_value = $LineEdit
@onready var mana_value = $LineEdit2
@onready var food_value = $LineEdit3
@onready var exp_value = $LineEdit4
@onready var encumbrance_value = $LineEdit5
@onready var alignment_selector = $"Alignment Selector"
var loaded = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#GameServer.FetchPlayerStats()

func _process(_delta):
	if !loaded:
		GameServer.FetchPlayerStats()
	
func LoadPlayerStats(stats):
	health_value.set_text(str(stats.Health) + " / " + str(stats.MaxHealth))
	health_bar.max_value = stats.MaxHealth
	health_bar.value = stats.Health
	
	mana_value.set_text(str(stats.Mana) + " / " + str(stats.MaxMana))
	mana_bar.max_value = stats.MaxMana
	mana_bar.value = stats.Mana
	
	food_value.set_text(str(stats.Food) + " / " + str(stats.MaxFood))
	food_bar.max_value = stats.MaxFood
	food_bar.value = stats.Food
	
	exp_value.set_text(str(stats.Exp) + " / " + str(stats.MaxExp))
	exp_bar.max_value = stats.MaxExp
	exp_bar.value = stats.Exp
	
	encumbrance_value.set_text(str(stats.Encumbrance) + " / " + str(stats.MaxEncumbrance))
	encumbrance_bar.max_value = stats.MaxEncumbrance
	encumbrance_bar.value = stats.Encumbrance
	
	#bar length and size for selector
	var selector_min = 250.635
	var selector_max = 374.705
	var selector_total = selector_max - selector_min
	
	var server_max = stats.MaxAlignment
	var server_value = stats.Alignment
	

	var ratio = float(server_value) / server_max
	var add = selector_total * ratio
	alignment_selector.position.x = selector_min + add
	
	loaded = true
