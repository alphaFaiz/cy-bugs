extends Control

const TEXTURE_EMPTY := preload("res://prototype-sprites/energy-point-empty.png")
const TEXTURE_ENERGY_FULL := preload("res://prototype-sprites/energy-point.png")


var max_energy := 8
var energy := max_energy
@onready var _row := $TextureRect/EnergyVBoxContainer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_energy(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_energy(new_energy: int) -> void:
	energy = new_energy

	for index in _row.get_child_count():
		var energy_point: TextureRect = _row.get_child(index)
		if energy > index:
			energy_point.texture = TEXTURE_ENERGY_FULL
		else:
			energy_point.texture = TEXTURE_EMPTY
