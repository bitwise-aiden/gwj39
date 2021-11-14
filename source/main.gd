extends Node2D


# Const variables

const PLAYER_REFERENCE: Resource = preload("res://source/player.tscn")
const SQUARE_REFERENCE: Resource = preload("res://source/square.tscn")


# Export variables

export(int) var size: int = 9


# Private variables

var __initial_position: Vector2 = Vector2.ZERO
var __squares: Array = []

var __player_count: int = 0
var __player_data: Array = [
	[Vector2(0.0, 4.0), Color("8be866"), preload("res://assets/art/player_1.png")],
	[Vector2(8.0, 4.0), Color("979bcc"), preload("res://assets/art/player_2.png")],
]

var __interfaces: Array = [
	ControlInterface.new(ControlInterface.KEYBOARD_1 | ControlInterface.TOUCH),
	ControlInterface.new(ControlInterface.KEYBOARD_2),
]


# Lifecycle methods

func _ready() -> void:
	var total_size: Vector2 = Globals.SQUARE_SIZE * self.size
	self.__initial_position = Globals.SCREEN_SIZE / 2.0 - total_size / 2.0

	self.__create_squares()

#	for data in self.__player_data:
#		self.__add_player(data[0], data[1], data[2], data[3])

	Event.connect("player_landed", self, "__player_landed")


func _process(delta: float) -> void:
	for interface in self.__interfaces:
		interface.process()

		if interface.is_active() && !interface.is_assigned():
			var data: Array = self.__player_data[self.__player_count]

			self.__add_player(
				data[0],
				data[1],
				data[2],
				interface
			)

			interface.assign()
			self.__player_count += 1


# Private methods

func __add_player(
	position: Vector2,
	color: Color,
	texture: Texture,
	interface: ControlInterface,
	direction: Vector2 = Vector2.ZERO
) -> void:
	var instance: Player = PLAYER_REFERENCE.instance()

	instance.initialize(
		self.__initial_position + position * Globals.SQUARE_SIZE + Globals.PLAYER_OFFSET,
		color,
		texture,
		interface,
		funcref(self, "__can_move"),
		direction
	)

	self.call_deferred("add_child", instance)


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


func __create_squares() -> void:
	for y in self.size:
		for x in self.size:
			var instance: Square = SQUARE_REFERENCE.instance()
			instance.position = self.__initial_position + Vector2(x, y) * Globals.SQUARE_SIZE

			self.call_deferred("add_child", instance)

			self.__squares.append(instance)


func __player_landed(player: Player) -> void:
	var index: int = self.__position_to_index(player.position)
	self.__squares[index].land(player)


func __position_to_index_position(incoming: Vector2) -> Vector2:
	var relative_position: Vector2 = incoming - self.__initial_position - Globals.PLAYER_OFFSET
	return relative_position / Globals.SQUARE_SIZE


func __position_to_index(incoming: Vector2) -> int:
	var indexed_position: Vector2 = self.__position_to_index_position(incoming)
	return int(indexed_position.y * self.size + indexed_position.x)
