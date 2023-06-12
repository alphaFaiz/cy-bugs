extends Control

@onready var play_button = $PlayButton
@onready var setting_button = $SettingButton
@onready var highscore_button = $HighScoreButton
@onready var characterAnimation = $CharacterAnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not characterAnimation.is_playing():
		characterAnimation.play("walk")

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")
