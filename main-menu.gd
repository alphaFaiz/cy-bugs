extends Control

@onready var play_button = $PlayButton
@onready var setting_button = $SettingButton
@onready var about_button = $AboutButton
@onready var characterAnimation = $CharacterAnimatedSprite2D
@onready var about_popup = $AboutPopupPanel
@onready var setting_popup = $SettingPopupPanel

@onready var score_label = $HighScoreLabel
var save_file_path = "user://save/"
var save_file_name = "PlayerScore.tres"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ResourceLoader.exists(save_file_path + save_file_name):
		var playerData = ResourceLoader.load(save_file_path + save_file_name)
		score_label.text = "HIGHEST SCORE: " + str(playerData.high_score)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not characterAnimation.is_playing():
		characterAnimation.play("walk")

func _on_play_button_pressed() -> void:
	Loading.load_scene(self, "res://game.tscn")
#	get_tree().change_scene_to_file("res://game.tscn")


func _on_about_button_pressed() -> void:
	about_popup.show()

func _on_setting_button_pressed() -> void:
	setting_popup.show()
