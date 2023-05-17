extends ParallaxLayer

@export var SPEED = -100

func _process(delta):
	motion_offset.x += SPEED * delta
