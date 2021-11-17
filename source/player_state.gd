class_name PlayerState

# Private variables

var instance: Player = null
var ui: PlayerScore = null

var score: int = 0


# Lifecycle methods

func _init(player: Player, ui: PlayerScore) -> void:
	self.instance = player
	self.ui = ui

	self.score = 0
