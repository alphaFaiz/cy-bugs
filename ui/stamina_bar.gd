extends ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_stamina(max_value)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func set_stamina(new_stamina: int) -> int:
	value = new_stamina
	return value
