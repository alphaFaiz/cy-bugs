extends Resource

const SAVE_FILE_PATH = "user://save_game.save"

@export var high_score = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#func save_score():
#	ResourceSaver.save(SAVE_FILE_PATH, self)
#
#var save_path = "user://save_game.tres"
#
#func save_score():
#	var file = FileAccess.open(save_path, FileAccess.WRITE)
#	file.store_var(highscore)
