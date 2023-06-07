extends BaseEnemy

func _physics_process(delta: float) -> void:
	_animated_sprite.speed_scale = animation_speed
	velocity = Vector2(-speed * 2, 0)
	move_and_collide(velocity * delta)
