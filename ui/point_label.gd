extends Label


func _ready() -> void:
	set_point(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func set_point(new_point: int):
	text = "SCORE: " + str(new_point)
