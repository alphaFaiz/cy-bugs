extends Area2D

@onready var animation_sprites = $AnimatedSprite2D
const explosion_scn = preload("res://effects/explosion.tscn")

func _on_body_entered(enemy_node: BaseEnemy) -> void:
	enemy_node.destroy()
	
