extends Area2D

@onready var _animated_sprite := $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play("idle")
	self.connect("area_entered", _on_area_entered)

func play(animation: String, fliph = false, flipv= false) -> void:
	_animated_sprite.set_flip_h(fliph)
	_animated_sprite.set_flip_v(flipv)
	_animated_sprite.play(animation)

func _on_area_entered(body: Node) -> void:
	play("picked")
	await _animated_sprite.animation_finished
	queue_free()
	apply_effect(body)

#func _physics_process(delta: float) -> void:
#	position.x -= 200 * delta

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Virtual function. Applies this pickup's effect on the body node.
func apply_effect(body: Node) -> void:
	pass

