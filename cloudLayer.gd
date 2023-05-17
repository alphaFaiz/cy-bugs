extends ParallaxLayer

@export var SPEED = -105

func _process(delta):
	motion_offset.x += SPEED * delta
