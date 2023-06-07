extends BaseEnemy

@onready var shoot_timer = $ShootTimer
@onready var default_wait_time = shoot_timer.wait_time
@onready var sprite_height = $CollisionShape2D.shape.radius
@onready var sprite_width = $CollisionShape2D.shape.height

const drake_bullet = preload("res://enemies/drake_bullet_enemy.tscn")
var head_down = true

func _physics_process(delta: float) -> void:
	super(delta)
	moving()

func moving() -> void:
	var new_wait_time = default_wait_time * (default_speed / speed )
	if new_wait_time != shoot_timer.wait_time:
		shoot_timer.stop()
	shoot_timer.wait_time = new_wait_time
	
	if head_down:
		velocity = Vector2(0, +speed)
	else:
		velocity = Vector2(0, -speed)
		
	if _bottom_raycast.is_colliding():
		head_down = false
	elif _top_raycast.is_colliding() or global_position.y <= sprite_height:
		head_down = true	

func attack_player():
	if shoot_timer.is_stopped():
		shoot_timer.start()
	
func _on_shoot_timer_timeout() -> void:
	if is_attacking:
		var inst = drake_bullet.instantiate()
		inst.position = Vector2(position.x - sprite_width/1.9, position.y + 20)
		get_parent().add_child(inst)
