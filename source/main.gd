extends Node2D


# Const variables

const PLAYER_POSITIONS: Array = [
	Vector2(0, 4),
	Vector2(8, 4),
	Vector2(4, 0),
	Vector2(4, 8),
]
const SQUARE_REFERENCE: Resource = preload("res://source/square.tscn")


# Export variables

export(int) var size: int = 9
export(Array) var player_data: Array = []


# Private variables

onready var __animation: AnimationPlayer = $animation
onready var __players: Array = [
	$player_1,
	$player_2,
	$player_3,
	$player_4,
]

var __initial_position: Vector2 = Vector2.ZERO
var __interfaces: Array = []
var __squares: Array = []


# Lifecycle methods

func _ready() -> void:
	randomize()

	self.__initialize_squares()
	self.__initialize_players()

	self.__animation.play("spawn")


# Private methods

func __can_move(player: Player, origin: Vector2, destination: Vector2) -> bool:
	var index_origin: Vector2 = self.__position_to_index_position(origin)
	var index_destination: Vector2 = self.__position_to_index_position(destination)

	if index_destination.x < 0.0 || index_destination.x >= size || \
		index_destination.y < 0.0 || index_destination.y >= size:
			return false

	var delta = (index_destination - index_origin).snapped(Vector2(0.1, 0.1))
	if [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN].find(delta) == -1:
		return false

	var index: int = self.__position_to_index(destination)
	var square: Square = self.__squares[index]
	if !square.can_traverse():
		return false

	square.reserve(player)

	return true


func __emit_signal(name: String) -> void:
	Event.emit_signal(name)


func __initialize_players() -> void:
	for i in self.__players.size():
		self.__players[i].initialize(ControlInterface.new(ControlInterface.KEYBOARD_1), funcref(self, "__can_move"))

	Event.connect("player_landed", self, "__player_landed")


func __initialize_squares() -> void:
	var total_size: Vector2 = Globals.SQUARE_SIZE * self.size
	self.__initial_position = Globals.SCREEN_SIZE / 2.0 - total_size / 2.0

	for y in self.size:
		for x in self.size:
			var instance: Square = SQUARE_REFERENCE.instance()
			var index_position = Vector2(x, y)

			var speed = randf() * 3.0 + 2.0
			var wait_event: String = "wait_spawn_world"
			if PLAYER_POSITIONS.find(index_position) != -1:
				speed = randf() + 4.0
				wait_event = "wait_spawn_player"

			instance.initialize(
				self.__initial_position + index_position * Globals.SQUARE_SIZE,
				Vector2(0.0, 1000.0),
				speed,
				wait_event
			)

			self.call_deferred("add_child", instance)

			self.__squares.append(instance)


func __player_landed(player: Player) -> void:
	var index: int = self.__position_to_index(player.position)

	if index < 0 || index > self.__squares.size():
		return

	self.__squares[index].land(player)


func __position_to_index_position(incoming: Vector2) -> Vector2:
	var relative_position: Vector2 = incoming - self.__initial_position - Globals.PLAYER_OFFSET
	return relative_position / Globals.SQUARE_SIZE


func __position_to_index(incoming: Vector2) -> int:
	var indexed_position: Vector2 = self.__position_to_index_position(incoming)
	return int(indexed_position.y * self.size + indexed_position.x)
