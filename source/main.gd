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
	PlayerState.new($player_1, $ui/player_score_1),
	PlayerState.new($player_2, $ui/player_score_2),
	PlayerState.new($player_3, $ui/player_score_3),
	PlayerState.new($player_4, $ui/player_score_4),
]

var __initial_position: Vector2 = Vector2.ZERO
var __interfaces: Array = []
var __squares: Array = []

var __playing: bool = false


# Lifecycle methods

func _ready() -> void:
	randomize()

	self.__initialize_squares()
	self.__initialize_players()

	self.__animation.play("spawn")
	yield(self.__animation, "animation_finished")
	self.__animation.play("countdown")

	yield(Event, "wait_game_start")
	self.__playing = true


# Private methods

#func __detect_color(index_position: Vector2, color: Color) -> bool:
#	return self.__squares[self.__index_position_to_index(index_position)].color != color
#
#func __detect_corner(index_position: Vector2, color: Color) -> bool:
#	if self.__detect_color(:
#		return false
#
#	for i in 2:
#		var horizontal: Vector2 = index_position + Vector2(i + 1, 0)




func __find_squares(player: Player) -> int:
	var active_squares: Array = []

	# for each square in 0,0 7,7:
		# if x, y + 1 and x + 1, y + 1 == color:
			# add active squares

#	for y in size - 2:
#		for x in size - 2:
#			if




	return 0


func __calculate_points(square: Square, player: Player) -> int:
	if square.color_previous == square.color_current:
		return 0

	if square.color_previous != Color.white:
		return 2

	return 1


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
		var interface: int = ControlInterface.NONE
		if i < GlobalState.connected_interfaces.size():
			interface = GlobalState.connected_interfaces[i]
		self.__players[i].instance.initialize(
			ControlInterface.new(interface),
			funcref(self, "__can_move")
		)

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

	var square = self.__squares[index]
	square.land(player)

	if !self.__playing:
		return

	for state in self.__players:
		if state.instance == player:
			var points: int = self.__calculate_points(square, player)
			if points == 0:
				break


			state.score += points
			state.ui.set_score(state.score)

			break


func __position_to_index_position(incoming: Vector2) -> Vector2:
	var relative_position: Vector2 = incoming - self.__initial_position - Globals.PLAYER_OFFSET
	return relative_position / Globals.SQUARE_SIZE


func __index_position_to_index(incoming: Vector2) -> int:
	return int(incoming.y * self.size + incoming.x)


func __position_to_index(incoming: Vector2) -> int:
	var index_position: Vector2 = self.__position_to_index_position(incoming)
	return self.__index_position_to_index(index_position)
