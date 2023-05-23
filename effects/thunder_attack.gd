extends Area2D

@onready var animation_sprites = $AnimatedSprite2D
const explosion_scn = preload("res://effects/explosion.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.s


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(enemy_node: BaseEnemy) -> void:
	enemy_node.destroy()
	
