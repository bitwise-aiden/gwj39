class_name PlayArea


# Const variables

var SQUARE_REFERENCE: Resource = preload("res://source/scenes/main/square.tscn")

# Private variables

var __owner: Node = null
var __size: int = 0

var __initial_position: Vector2 = Vector2.ZERO
var __squares: Array = []


# Lifecycle methods

func _init(owner: Node, size: int) -> void:
	self.__owner = owner
	self.__size = size


# Public methods


func area_position_to_world_position(position: Vector2) -> Vector2:
	return (position * Globals.SQUARE_SIZE) + self.__initial_position + Globals.PLAYER_OFFSET


func initialize(wait_event_callback: FuncRef) -> void:
	var total_size: Vector2 = Globals.SQUARE_SIZE * self.__size
	self.__initial_position = Globals.SCREEN_SIZE / 2.0 - total_size / 2.0

	for y in self.__size:
		for x in self.__size:
			var instance: Square = SQUARE_REFERENCE.instance()
			var position = Vector2(x, y)

			instance.initialize(
				position,
				self.__initial_position + position * Globals.SQUARE_SIZE,
				Vector2(0.0, 1000.0),
				randf() * 3.0 + 2.0,
				wait_event_callback.call_func(position)
			)

			self.__owner.call_deferred("add_child", instance)

			self.__squares.append(instance)


func square_at_world_position(position: Vector2) -> Square:
	var area_position: Vector2 = self.world_postition_to_area_position(position)
	return self.square_at_area_position(area_position)


func square_at_area_position(position: Vector2) -> Square:
	var index: int = self.__area_position_to_index(position)
	if index == -1:
		return null

	return self.__squares[index]


func state() -> Array:
	return self.__squares


func world_postition_to_area_position(position: Vector2) -> Vector2:
	var relative_position: Vector2 = position - self.__initial_position - Globals.PLAYER_OFFSET
	return relative_position / Globals.SQUARE_SIZE


# Private variables


func __area_position_to_index(position: Vector2) -> int:
	if position.x < 0.0 || position.x >= self.__size || position.y < 0.0 || position.y >= self.__size:
		return -1

	return int(position.y * self.__size + position.x)


func __world_position_to_index(position: Vector2) -> int:
	var index_position: Vector2 = self.world_postition_to_area_position(position)
	return self.__area_position_to_index(position)

