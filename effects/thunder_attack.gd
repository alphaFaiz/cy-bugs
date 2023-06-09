extends Area2D

@onready var animation_sprites = $AnimatedSprite2D

func _on_body_entered(enemy_node: BaseEnemy) -> void:
	enemy_node.destroy()
	
