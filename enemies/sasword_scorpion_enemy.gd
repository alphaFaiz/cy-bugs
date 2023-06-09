extends BaseEnemy

var is_attacked = false

func _physics_process(delta: float) -> void:
	_target = find_target()
	if is_attacking:
		attack_player(delta)
	elif _target:
		animation_name = "approach"
		_animated_sprite.play(animation_name)
		orbit_target()
	else:
		animation_name = "idle"
		_animated_sprite.play(animation_name)
	_animated_sprite.speed_scale = animation_speed
	# Add the gravity.
	if not grounded:
		velocity.y += gravity * delta
	if _bottom_raycast.is_colliding():
		var orig = _bottom_raycast.global_transform.origin
		var coll = _bottom_raycast.get_collision_point()
		var dist = abs(orig.y - coll.y)
		var depth = abs(_bottom_raycast.target_position.y - dist)
		position.y -= depth - 1
		grounded = true
		velocity.y = 0
	else:
		grounded = false
	move_and_collide(velocity * delta)
#	move_and_slide()

func orbit_target() -> void:
	var desired_velocity: Vector2 = global_position.direction_to(_target.global_position) * speed
	desired_velocity.y = 0
	velocity += desired_velocity / 20.0

func attack_player(delta = null):
	if not is_attacked:
		is_attacked = true
		velocity *= 4
		_animated_sprite.speed_scale = animation_speed
		_animated_sprite.play("attack")
	#	await _animated_sprite.animation_finished
