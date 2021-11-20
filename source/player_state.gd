class_name PlayerState

# Private variables

var instance: Player = null
var ui: PlayerScore = null

var score: int = 0 setget __set_score, __get_score
var score_time: int = 0


# Lifecycle methods

func _init(player: Player, ui: PlayerScore) -> void:
	self.instance = player
	self.ui = ui

	self.score = 0


# Private methods

func __set_score(incoming: int) -> void:
	score = incoming
	score_time = OS.get_ticks_msec()


func __get_score() -> int:
	return score
