class_name PlayArea


# Const variables

var SQUARE_REFERENCE: Resource = preload("res://source/scenes/main/square.tscn")

# Public variables

var size: int = 0


# Private variables

var __owner: Node = null

var __initial_position: Vector2 = Vector2.ZERO
var __squares: Array = []


# Lifecycle methods

func _init(owner: Node, size: int) -> void:
	self.__owner = owner
	self.size = size

	Event.connect("player_landed", self, "__player_landed")


# Public methods


func area_position_to_world_position(position: Vector2) -> Vector2:
	return (position * Globals.SQUARE_SIZE) + self.__initial_position + Globals.PLAYER_OFFSET


func can_move(player: Player, origin: Vector2, destination: Vector2) -> bool:
	var area_origin: Vector2 = self.world_postition_to_area_position(origin)
	var area_destination: Vector2 = self.world_postition_to_area_position(destination)


	var delta = (area_destination - area_origin).snapped(Vector2(0.1, 0.1))
	if [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN].find(delta) == -1:
		return false

	var square: Square = self.square_at_world_position(destination)
	if square == null || !square.can_traverse(): # i will never add a comment fu - TheYagich
		return false

	square.reserve(player)

	return true


func initialize(wait_event_callback: FuncRef) -> void:
	var total_size: Vector2 = Globals.SQUARE_SIZE * self.size
	self.__initial_position = Globals.SCREEN_SIZE / 2.0 - total_size / 2.0

	for y in self.size:
		for x in self.size:
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
	if position.x < 0.0 || position.x >= self.size || position.y < 0.0 || position.y >= self.size:
		return -1

	return int(position.y * self.size + position.x)


func __player_landed(player: Player) -> void:
	var square: Square = self.square_at_world_position(player.position)
	if square == null:
		return

	square.land(player)

	player.set_coord(self.world_postition_to_area_position(player.position))

	if !GlobalState.playing:
		return

	Event.emit_signal("calculate_points", square, player)


func __world_position_to_index(position: Vector2) -> int:
	var index_position: Vector2 = self.world_postition_to_area_position(position)
	return self.__area_position_to_index(position)

