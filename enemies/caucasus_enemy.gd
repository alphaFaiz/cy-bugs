extends BaseEnemy

func orbit_target() -> void:
#	var direction := _target.global_position.direction_to(global_position)
	follow(_target.global_position)
	
# Steers towards the target position.
func follow(target_global_position: Vector2) -> void:
	var desired_velocity: Vector2= global_position.direction_to(target_global_position) * speed
	var steering := desired_velocity - _velocity
	velocity += steering / 3.0

func attack_player(delta = null) -> void:
	velocity += Vector2(-speed * 6, 0) * delta
