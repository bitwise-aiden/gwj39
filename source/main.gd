extends Node2D


# Export variables

export(int) var size: int = 9


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
	instance.position = self.__initial_position + Vector2(0.0, 4.0) * Globals.SQUARE_SIZE + Globals.PLAYER_OFFSET
	instance.set_direction(Vector2.RIGHT)
	instance.set_can_move_callback(funcref(self, "__can_move"))

	self.call_deferred("add_child", instance)

	Event.connect("player_landed", self, "__player_landed")


# Private methods

func __can_move(origin, destination) -> bool:
	var index_origin: Vector2 = self.__position_to_index_position(origin)
	var index_destination: Vector2 = self.__position_to_index_position(destination)

	if index_destination.x < 0.0 || index_destination.x >= size || \
		index_destination.y < 0.0 || index_destination.y >= size:
			return false

	var delta = (index_destination - index_origin).snapped(Vector2(0.1, 0.1))
	return [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN].find(delta) != -1


func __player_landed(player: Player) -> void:
	var index: int = self.__position_to_index(player.position)
	self.__squares[index].land(player)


func __position_to_index_position(incoming: Vector2) -> Vector2:
	var relative_position: Vector2 = incoming - self.__initial_position - Globals.PLAYER_OFFSET
	return relative_position / Globals.SQUARE_SIZE


func __position_to_index(incoming: Vector2) -> int:
	var indexed_position: Vector2 = self.__position_to_index_position(incoming)
	return int(indexed_position.y * self.size + indexed_position.x)
