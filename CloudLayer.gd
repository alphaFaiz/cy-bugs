extends ParallaxLayer

@export var CLOUD_SPEED = -50

func _process(delta):
	motion_offset.x += CLOUD_SPEED * delta
