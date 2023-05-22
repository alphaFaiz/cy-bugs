class_name BaseEnemy
extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _detection_area: Area2D = $DetectionArea

const SPEED = 300.0
var _velocity := Vector2.ZERO
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var _target: Player

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	_target = find_target()
	_animated_sprite.play("walk")
	move_and_slide()

func find_target() -> Player:
	var overlapping_bodies := _detection_area.get_overlapping_bodies()
	if not overlapping_bodies.is_empty():
		var playerArray = overlapping_bodies.filter(func(body): return body is Player)
		return playerArray.front()
	return null

# Steers towards the target position.
func follow(target_global_position: Vector2) -> void:
	var desired_velocity := global_position.direction_to(target_global_position) * SPEED
	var steering := desired_velocity - _velocity
	velocity += steering / 6.0
	move_and_slide()
	#move_and_slide(_velocity, Vector2.ZERO)

# Orbit around the target if there is one.
func orbit_target() -> void:
	var target_distance := 200.0
	var direction := _target.global_position.direction_to(global_position)
	var offset_from_target := direction.rotated(PI / 6.0) * target_distance
	follow(_target.global_position + offset_from_target)
