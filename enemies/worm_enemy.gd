extends BaseEnemy

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	position.x -= SPEED * delta
	_animated_sprite.play("walk")
	move_and_slide()
