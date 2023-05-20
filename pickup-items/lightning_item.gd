extends BasePickup

func apply_effect(player: Player) -> void:
	player.energy += 1
