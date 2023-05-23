extends BaseEnemy

func orbit_target() -> void:
	var target_distance := 40.0
	var direction := _target.global_position.direction_to(global_position)
	var offset_from_target := direction.rotated(PI / 6.0) * target_distance
	follow(_target.global_position + offset_from_target)
	
# Steers towards the target position.
func follow(target_global_position: Vector2) -> void:
	var desired_velocity := global_position.direction_to(target_global_position) * SPEED
	var steering := desired_velocity - _velocity
	velocity += steering / 6.0
	move_and_slide()
