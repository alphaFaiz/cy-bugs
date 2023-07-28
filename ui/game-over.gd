extends Control
@onready var admob = $AdMob
@onready var score_label = $ScoreLabel
var save_file_path = "user://save/"
var save_file_name = "PlayerScore.tres"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	admob.load_banner()
	admob.show_banner()
	var playerData = ResourceLoader.load(save_file_path + save_file_name)
	score_label.text = "YOUR SCORE: " + str(playerData.latest_score) + "\nHIGHEST SCORE: " + str(playerData.high_score)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func display_scores(current_score, high_score):
	score_label.text = "YOUR SCORE:" + current_score + "\nHIGHEST SCORE: " + high_score

func _on_replay_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main-menu.tscn")
