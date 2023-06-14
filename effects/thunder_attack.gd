extends Area2D

@onready var animation_sprites = $AnimatedSprite2D

func _on_body_entered(node: Node) -> void:
	if node is BaseEnemy:
		node.destroy()
	
