extends BaseEnemy

const JUMP_VELOCITY = 300.0
var jumping = false

func _physics_process(delta: float) -> void:
#	print ("jumping: ", jumping)
	_target = find_target()
	hopper_move(delta)
	if not is_attacking or not _target:
		animation_name = "idle"
		_animated_sprite.play(animation_name)
	elif is_attacking and grounded:
		jumping = true
		attack_player(delta)
	if jumping:
		velocity.y -= speed/2
	_animated_sprite.speed_scale = animation_speed
	move_and_collide(velocity * delta)

func hopper_move(delta: float) -> void:
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
	if not grounded and not jumping:
		velocity.y += gravity * delta

func attack_player(_delta = null):
	_animated_sprite.speed_scale = animation_speed
	_animated_sprite.play("attack")
	if gravity < default_gravity:
		velocity.y -= gravity/1.42
	else:
		velocity.y -= abs(_bottom_raycast.position.y - _bottom_raycast.target_position.y)
	await _animated_sprite.animation_finished
	jumping = false
