class_name AIInput extends Node


class AveragePosition:
	var position: Vector2 = Vector2.ZERO
	var count: int = 0

	func add(other: Vector2) -> void:
		self.position += other
		self.count += 1

	func average() -> Vector2:
		if self.count == 0:
			return self.position

		return self.position / self.count

	func direction_to(other: Vector2) -> Vector2:
		return (self.average() - other).normalized()


# Private variables

var __board_state_getter: FuncRef = null
var __color: Color = Color.transparent
var __direction: Vector2 = Vector2.ZERO
var __cooldown: int = 0


# Lifecycle methods

func _init(board_state_getter: FuncRef, color: Color) -> void:
	self.__board_state_getter = board_state_getter
	self.__color = color


# Public methods

func direction() -> Vector2:
	if self.__cooldown > 0:
		self.__cooldown -= 1
# What can I program.. Uhhh.. Uhhh.. Ahhh.. Uuuuuuhhhhhhhh. - Lil'Oni
	return self.__direction


func process() -> void:
	if self.__cooldown > 0:
		return # Okay, but this is a test - velopman
#
	self.__cooldown += randi() % 2 + 1

	var board: Array = self.__board_state_getter.call_func()

	var position_own: Vector2 = Vector2.ZERO

	var position_color: AveragePosition = AveragePosition.new()
	var position_player: AveragePosition = AveragePosition.new()
	var position_ai: AveragePosition = AveragePosition.new()

	for square in board:
		if square.color_current != self.__color && square.color_current != Color.white:
			position_color.add(square.coord)

		var player = square.target()
		if player != null:
			if player.color() == self.__color:
				position_own = square.coord
			elif player.interface() == 0:
				position_ai.add(square.coord)
			else:
				position_player.add(square.coord)

	var direction: Vector2 = (
		position_color.direction_to(position_own) * 10.0 +
		position_player.direction_to(position_own) * 100.0 +
		(Vector2(4.0, 4.0) - position_own).normalized() * 3.0 +
		position_ai.direction_to(position_own) * -2.0
	).normalized()

	self.__direction = Vector2(sign(direction.x), 0.0)
	if abs(direction.y) > abs(direction.x):
		self.__direction = Vector2(0.0, sign(direction.y))
