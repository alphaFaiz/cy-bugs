extends Node2D

@onready var ray = $RayCast2D

var grounded = false
var jumping = false

var gravity = 15
var jump_speed = -500

var max_y_vel = 300
var y_vel = 0

func _physics_process(delta):
	if not grounded:
		y_vel = min(max_y_vel, y_vel+gravity)
	else:
		y_vel = 0
	grounded = false
	
	var jump = Input.is_action_just_pressed("jump") and not jumping
	
	if jump:
		jumping = true
		y_vel = jump_speed
	
	position.y += y_vel * delta
	
	if not jump:
		if ray.is_colliding():
			var orig = ray.global_transform.origin
			var coll = ray.get_collision_point()
			var dist = abs(orig.y - coll.y)
			var depth = abs(ray.target_position.y - dist)
			
			grounded = true
			jumping = false
			
			position.y -= depth

func _on_hit_box_body_entered(body):
	queue_free()

func _on_head_box_body_entered(body):
	y_vel = max(y_vel, 0)
