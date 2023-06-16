extends BaseEnemy

const JUMP_VELOCITY = 300.0
var jumping = false
var jump_heigh = 200
@onready var start_attack_position = position

func _physics_process(delta: float) -> void:
	_target = find_target()
	hopper_move(delta)
	if not is_attacking or not _target:
		animation_name = "idle"
		_animated_sprite.play(animation_name)
	elif is_attacking and grounded and not jumping:
		jumping = true
		start_attack_position = position
		attack_player(delta)
	if position.y <= start_attack_position.y - jump_heigh and jumping:
		jumping = false
		velocity.y = 0
	if jumping:
		velocity.y -= speed/2
		velocity.x = -80
	if not grounded and not jumping:
		velocity.y += gravity * delta
	_animated_sprite.speed_scale = animation_speed
	move_and_collide(velocity * delta)

func hopper_move(delta: float) -> void:
	if _bottom_raycast.is_colliding() and not _bottom_raycast.get_collider() is Player:
		var orig = _bottom_raycast.global_transform.origin
		var coll = _bottom_raycast.get_collision_point()
		var dist = abs(orig.y - coll.y)
		var depth = abs(_bottom_raycast.target_position.y - dist)
		position.y -= depth - 1
		grounded = true
		velocity = Vector2.ZERO
	else:
		grounded = false

func attack_player(_delta = null):
	_animated_sprite.speed_scale = animation_speed
	_animated_sprite.play("attack")
	if gravity < default_gravity:
		velocity.y -= gravity
	else:
		velocity.y -= abs(_bottom_raycast.position.y - _bottom_raycast.target_position.y)
