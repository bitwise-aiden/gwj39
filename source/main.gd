extends Node2D


# Export variables

export(int) var size: int = 10


# Private variables

var __initial_position: Vector2 = Vector2.ZERO
var __squares: Array = []


# Lifecycle methods

func _ready() -> void:
	var total_size: Vector2 = Globals.SQUARE_SIZE * self.size
	self.__initial_position = Globals.SCREEN_SIZE / 2.0 - total_size / 2.0

	var square_reference: Resource = preload("res://source/square.tscn")

	for y in self.size:
		for x in self.size:
			var instance: Square = square_reference.instance()
			instance.position = self.__initial_position + Vector2(x, y) * Globals.SQUARE_SIZE

			self.call_deferred("add_child", instance)

			self.__squares.append(instance)


	var player_reference: Resource = preload("res://source/player.tscn")

	var instance: Player = player_reference.instance()
	instance.position = self.__initial_position + Globals.PLAYER_OFFSET

	self.call_deferred("add_child", instance)

	Event.connect("player_landed", self, "__player_landed")


#var test_time_elapsed: float = 0.5
#
#func _process(delta: float) -> void:
#	test_time_elapsed = max(0.0, test_time_elapsed - delta)
#
#	if test_time_elapsed == 0.0:
#		test_time_elapsed = 0.5
#
#		var index: int = randi() % 100
#
#		self.__squares[index].land()


# Private methods

func __player_landed(player: Player) -> void:
	var relative_position: Vector2 = player.position - self.__initial_position - Globals.PLAYER_OFFSET
	var indexed_position: Vector2 = relative_position / Globals.SQUARE_SIZE
	var index: int = indexed_position.y * self.size + indexed_position.x

	self.__squares[index].land(player)
