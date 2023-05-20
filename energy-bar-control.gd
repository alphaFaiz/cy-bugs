extends Control

const TEXTURE_EMPTY := preload("res://prototype-sprites/energy-point-empty.png")
const TEXTURE_ENERGY_FULL := preload("res://prototype-sprites/energy-point.png")


var max_energy := 8
var energy := 1: 
	set(value):
		energy = set_energy(value)
	get:
		return energy

@onready var _row := $TextureRect/EnergyVBoxContainer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_energy(1)

func set_energy(new_energy: int) -> int:
	for index in _row.get_child_count():
		var energy_point: TextureRect = _row.get_child(index)
		if new_energy > index:
			energy_point.texture = TEXTURE_ENERGY_FULL
		else:
			energy_point.texture = TEXTURE_EMPTY
	for child in _row.get_children():  
		_row.move_child(child, 0)  
	return new_energy
