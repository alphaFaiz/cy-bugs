class_name BasePickup
extends Area2D

@onready var _animated_sprite := $AnimatedSprite2D
@onready var _audio_player := $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play("idle")
	self.connect("body_entered", _on_body_entered)

func play(animation: String, fliph = false, flipv= false) -> void:
	_animated_sprite.set_flip_h(fliph)
	_animated_sprite.set_flip_v(flipv)
	_animated_sprite.play(animation)

func _on_body_entered(node: Node) -> void:
	if node is Player:
		_audio_player.play()
		play("picked")
		apply_effect(node)
		await _animated_sprite.animation_finished
		queue_free()

#func _physics_process(delta: float) -> void:
#	position.x -= 200 * delta

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Virtual function. Applies this pickup's effect on the body node.
func apply_effect(_player: Player) -> void:
	pass

