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
var __player_state_getter: FuncRef = null

var __color: Color = Color.transparent
var __direction: Vector2 = Vector2.ZERO
var __direction_previous: Vector2 = Vector2.ZERO
var __cooldown: int = 0


# Lifecycle methods

func _init(board_state_getter: FuncRef, player_state_getter: FuncRef, color: Color) -> void:
	self.__board_state_getter = board_state_getter
	self.__player_state_getter = player_state_getter
	self.__color = color


# Public methods

func direction(asethetic: bool = true) -> Vector2:
	if self.__cooldown > 0 && !asethetic:
		self.__cooldown -= 1
# What can I program.. Uhhh.. Uhhh.. Ahhh.. Uuuuuuhhhhhhhh. - Lil'Oni
	return self.__direction


func process() -> void:
	if self.__cooldown > 0:
		return # Okay, but this is a test - velopman
#
	self.__cooldown += randi() % 2 + 1

	self.__calculate_direction()


func __calculate_direction() -> void:
	var position_own: Vector2 = Vector2.ZERO
	var position_own_color: Array = []
	var position_other_color: Array = []
	var position_player: Array = []
	var position_ai: Array = []

	 # dont look here - jk you can look here - deschainxiv
	var board: Array = self.__board_state_getter.call_func()
	for square in board:
		var square_color: Color = square.color_current
		if square_color != Color.white:
			if square_color == self.__color:
				position_own_color.append(square.coord)
			else:
				position_other_color.append(square.coord)


	var players: Array = self.__player_state_getter.call_func() # This is so great it looks like Ian wrote it - deschainxiv
	for player in players:
		if player.color() == self.__color:
			position_own = player.coord
		elif player.interface() == 0: # ControlInterface.AI - Using number to avoid circular dependency issue
			position_ai.append(player.coord)
		else:
			position_player.append(player.coord)

	var direction: Vector2 = Vector2.ZERO

	for position in position_ai:
		var delta: Vector2 = position - position_own
		if delta.length() < 3.0:
			direction += -delta * 2.0

	for position in position_player:
		var delta: Vector2 = position - position_own
		if delta.length() < 3.0:
			direction += -delta * 2.0
		elif delta.length() > 7.0:
			direction += delta * 1.0

	if !position_other_color.empty():
		var sum_position_color: Vector2 = Vector2.ZERO
		for position in position_other_color:
			sum_position_color += position

		var average_position_color: Vector2 = sum_position_color / position_other_color.size()

		var delta: Vector2 = average_position_color - position_own
		if delta.length() > 5.0:
			direction = delta * 2.0

	if !position_own_color.empty():
		var sum_position_color: Vector2 = Vector2.ZERO
		for position in position_own_color:
			sum_position_color += position

		var average_position_color: Vector2 = sum_position_color / position_own_color.size()

		var delta: Vector2 = average_position_color - position_own
		if delta.length() < 3.0:
			direction = -delta * 2.0


	direction = direction.normalized()

	if randi() % 2 == 0:
		direction = Vector2(sign(direction.x), 0.0)
	else:
		direction = Vector2(0.0, sign(direction.y))

	if direction.length() == 0.0:
		direction = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT][randi() % 4] # Did I hear chaos? - Lil'Oni

	var position_next: Vector2 = position_own + direction
	if position_next.x < 0.0 || position_next.y < 0.0 || position_next.x >= 9 || position_next.y >= 9:
		direction = -direction

	self.__direction = direction

