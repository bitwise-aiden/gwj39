class_name TutorialPlayer1Input


# Private variables

var __direction: Vector2 = Vector2.ZERO


# Lifecycle methods
func _init() -> void:
	print("Hello")
	yield(Event, "tutorial_player_move")

	print("world")
	self.__direction = Vector2.LEFT

	yield(
		self.__queue_movement([
			Vector2.LEFT,
			Vector2.RIGHT,
			Vector2.RIGHT,
			Vector2.LEFT,
			Vector2.UP,
			Vector2.DOWN,
			Vector2.DOWN,
			Vector2.DOWN
		]),
		"completed"
	)

	Event.emit_signal("tutorial_player_moved")



# Public methods

func direction(asethetic: bool = true) -> Vector2:
	return self.__direction


func is_active() -> bool:
	return true


func process() -> void:
	pass

 # let me help you with this - TheYagich

# Private methods

func __queue_movement(moves: Array) -> void:
	for move in moves:
		self.__direction = move

		yield(Event, "player_landed")
