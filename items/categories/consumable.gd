@tool
class_name Consumable extends GDItem

@export_group("Consumable Info")
@export var heal: int
@export var mana: int

func use(player: CharacterBody2D):
	player.hp += heal
