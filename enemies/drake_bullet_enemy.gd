extends BaseEnemy

func _physics_process(delta: float) -> void:
	velocity = Vector2(-speed * 2, 0)
	move_and_collide(velocity * delta)
