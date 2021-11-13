extends Node


# Time globals

# Current rate of time passing.
#	1.0 is default
#	< 1.0 is slowed down
#	> 1.0 is speed up
var time_modifier: float = 1.0


const SQUARE_SIZE: Vector2 = Vector2(64.0, 66.0)
const SCREEN_SIZE: Vector2 = Vector2(1280.0, 720.0)
const PLAYER_OFFSET: Vector2 = Vector2(32.0, 26.0)
