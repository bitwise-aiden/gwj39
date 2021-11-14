extends Node2D


# Export variables

export(int) var size: int = 9


# Private variables

var __initial_position: Vector2 = Vector2.ZERO
var __squares: Array = []


var __player_data = [
	[preload("res://assets/art/player_1.png"), Vector2(0.0, 4.0), Color("8be866"), Vector2.ZERO],
	[preload("res://assets/art/player_2.png"), Vector2(8.0, 4.0), Color("979bcc"), Vector2.ZERO],
]


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

	for data in self.__player_data:
		var instance: Player = player_reference.instance()

		instance.set_texture(data[0])
		instance.position = self.__initial_position + data[1] * Globals.SQUARE_SIZE + Globals.PLAYER_OFFSET
		instance.color = data[2]
		instance.set_direction(data[3])

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
	if [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN].find(delta) == -1:
		return false

	var index: int = self.__position_to_index(destination)
	return self.__squares[index].can_traverse()


func __player_landed(player: Player) -> void:
	var index: int = self.__position_to_index(player.position)
	self.__squares[index].land(player)


func __position_to_index_position(incoming: Vector2) -> Vector2:
	var relative_position: Vector2 = incoming - self.__initial_position - Globals.PLAYER_OFFSET
	return relative_position / Globals.SQUARE_SIZE


func __position_to_index(incoming: Vector2) -> int:
	var indexed_position: Vector2 = self.__position_to_index_position(incoming)
	return int(indexed_position.y * self.size + indexed_position.x)
