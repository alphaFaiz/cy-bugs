extends BaseEnemy

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	_animated_sprite.play("walk")
	move_and_slide()

# Steers towards the target position.
func follow(target_global_position: Vector2) -> void:
	var desired_velocity: Vector2= global_position.direction_to(target_global_position) * speed
	var steering := desired_velocity - _velocity
	velocity += steering

func _on_attack_area_body_entered(player: Player) -> void:
	is_attacking = true
	velocity -= Vector2(speed, 0)
