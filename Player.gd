extends Node2D

@onready var rayCastBottom = $RayCast2DBottom
@onready var rayCastPrepareLanding = $RayCast2DPrepareLanding
@onready var _animated_sprite = $AnimatedSprite2D

var grounded = false

var gravity = 15
var jump_speed = -500

var max_y_vel = 300
var y_vel = 0

func play(animation: String) -> void:
	_animated_sprite.play(animation)

func _physics_process(delta):
	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")
	
	if rayCastPrepareLanding.is_colliding():
		grounded = false
		play("prepare_landing")
	elif up:
		grounded = false
		play("fly_up")
		position.y += jump_speed * delta
	elif down:
		play("fly_down")
		position.y -= jump_speed * delta
	elif grounded:
		play("walk")
	else: 
		play("fly_forward")

	position.y += y_vel * delta

	if rayCastBottom.is_colliding():
		var orig = rayCastBottom.global_transform.origin
		var coll = rayCastBottom.get_collision_point()
		var dist = abs(orig.y - coll.y)
		var depth = abs(rayCastBottom.target_position.y - dist)
		grounded = true
		position.y -= depth
	else:
		grounded = false
		
#func _on_hit_box_body_entered(body):
#	queue_free()

func _on_head_box_body_entered(body):
	y_vel = max(y_vel, 0)
