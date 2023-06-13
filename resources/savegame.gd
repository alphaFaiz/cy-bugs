extends Resource

class_name PlayerData

@export var latest_score = 0

@export var high_score = 0

func change_latest_score(value: int):
	latest_score = value
	
func change_high_score(value: int):
	high_score = value
