class_name BaseEnemy
extends CharacterBody2D

const explosion_scn = preload("res://effects/explosion.tscn")
@onready var _animated_sprite = $AnimatedSprite2D
@onready var _detection_area: Area2D = $DetectionArea
@onready var _attack_area: Area2D = $AttackArea
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

const SPEED = 80.0
var _velocity := Vector2.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var _target: Player

var animation_name = "fly"
var is_attacking = false

func _ready() -> void:
	_attack_area.connect("body_entered", _on_attack_area_body_entered)
#	.connect("body_entered", _on_body_entered)

func _physics_process(delta: float) -> void:
	_target = find_target()
	if is_attacking:
		animation_name = "attack"
	elif _target:
		animation_name = "approach"
		orbit_target()
	else:
		animation_name = "idle"
	_animated_sprite.play(animation_name)
	move_and_collide(velocity * delta)
#	move_and_slide()delta

func find_target() -> Player:
	var overlapping_bodies := _detection_area.get_overlapping_bodies()
	if not overlapping_bodies.is_empty():
		var playerArray = overlapping_bodies.filter(func(body): return body is Player)
		return playerArray.front()
	return null

func _on_attack_area_body_entered(player: Player) -> void:
	pass

func destroy() -> void:
	var enemy_collision = get_child(1)
	remove_child(enemy_collision)
	var explosion_inst = explosion_scn.instantiate()
	add_child(explosion_inst)
	await explosion_inst.animation_finished
	queue_free()

# Orbit around the target if there is one.
func orbit_target() -> void:
	pass
