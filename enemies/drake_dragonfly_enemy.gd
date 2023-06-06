extends BaseEnemy

@onready var shoot_timer = $ShootTimer
const drake_bullet = preload("res://enemies/drake_bullet_enemy.tscn")

var head_down = true

func orbit_target() -> void:
	var direction := _target.global_position.direction_to(global_position)
	follow(_target.global_position)
	
# Steers towards the target position.
func follow(target_global_position: Vector2) -> void:
#	print(global_position.y, " - ", get_node("CollisionShape2D").shape.height)	
	if head_down:
		velocity = Vector2(0, +speed)
	else:
		velocity = Vector2(0, -speed)
		
	if _bottom_raycast.is_colliding():
		head_down = false
	elif _top_raycast.is_colliding() or global_position.y <= get_node("CollisionShape2D").shape.radius:
		head_down = true
		
func _on_attack_area_body_entered(player: Player) -> void:
	is_attacking = true

func attack_player():
	if _target:
		follow(_target.global_position)
	if shoot_timer.is_stopped():
		shoot_timer.start()
	
func _on_shoot_timer_timeout() -> void:
	if _target:
		follow(_target.global_position)
	if is_attacking:
		var inst = drake_bullet.instantiate()
		print("shoot!")
		inst.position = Vector2(-get_node("CollisionShape2D").shape.height/1.8, 0)
		add_child(inst)
