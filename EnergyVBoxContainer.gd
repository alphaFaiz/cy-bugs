extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reverse_children()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func reverse_children():  
	for child in get_children():  
		move_child(child, 0)  
