extends BaseEnemy

func orbit_target() -> void:
	var direction := _target.global_position.direction_to(global_position)
	follow(_target.global_position)
	
# Steers towards the target position.
func follow(target_global_position: Vector2) -> void:
	var desired_velocity: Vector2= global_position.direction_to(target_global_position) * SPEED
	var steering := desired_velocity - _velocity
	velocity += steering / 3.0

func _on_attack_area_body_entered(player: Player) -> void:
	is_attacking = true
	velocity += Vector2(-300, 0)
#	move_and_collide(velocity)
