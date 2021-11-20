extends Node2D


# Const variables

const PLAYER_POSITIONS: Array = [
	Vector2(0, 4),
	Vector2(8, 4),
	Vector2(4, 0),
	Vector2(4, 8),
]
const SQUARE_REFERENCE: Resource = preload("res://source/scenes/main/square.tscn")
const AUDIO_PACK_REFERENCE: Resource = preload("res://source/audio_pack/game.tres")
const INVERSION_AREA_SIZE_MIN: int = 3
const WIN_POSITION_UI: Vector2 = Vector2(1280.0/2.0 - 100.0, 720.0/2.0)



# Publuc variables

export(int) var size: int = 9
export(Array) var player_data: Array = []
export(float) var winner_tween: float = 0.0 setget __set_winner_tween, __get_winner_tween


# Private variables

onready var __animation: AnimationPlayer = $animation
onready var __players: Array = [
	PlayerState.new($player_1, $ui/player_score_1),
	PlayerState.new($player_2, $ui/player_score_2),
	PlayerState.new($player_3, $ui/player_score_3),
	PlayerState.new($player_4, $ui/player_score_4),
]
onready var __hour_glass: HourGlass = $ui/hour_glass
onready var __winner_text: Label = $ui/winner

var __initial_position: Vector2 = Vector2.ZERO
var __interfaces: Array = []
var __squares: Array = []

var __playing: bool = false

var __winner: PlayerState = null
var __winner_position_player: Vector2 = Vector2.ZERO
var __winner_position_ui: Vector2 = Vector2.ZERO


# Lifecycle methods

func _ready() -> void:
	randomize()

	AudioManager.set_audio_pack(self.AUDIO_PACK_REFERENCE)
	AudioManager.play_music("banger", true)

	self.__initialize_squares()
	self.__initialize_players()

	self.__animation.play("spawn")
	yield(self.__animation, "animation_finished")
	self.__animation.play("countdown")

	yield(Event, "wait_game_start")
	self.__playing = true
	self.__hour_glass.set_time_remaining(10) # #Why are you setting origin? - MartyrPher

	yield(Event, "wait_times_up")

	AudioManager.play_sound_effect("finish")

	var highest_score: int = 0
	var highest_score_time: int = 0
	var highest_score_player: PlayerState = null

	for player in self.__players:
		if player.score > highest_score || (player.score == highest_score && player.score < highest_score_time):
			highest_score = player.score
			highest_score_time = player.score_time
			highest_score_player = player

	self.__winner = highest_score_player
	self.__winner_position_ui = self.__winner.ui.rect_position
	self.__winner_text.text = "%s wins!" % self.__winner.instance.data.name

	self.__animation.play("winner")

	Event.emit_signal("wait_end_game")


# Private methods

#
# Although this code is no longer used, I am keeping it here as memory for the first time
# I unleashed havoc on myself by letting my chat comment my codes as a channel point redemption...
# - velopman
#

#func __detect_corners(origin: Vector2, direction: Vector2, turn: Vector2, color: Color) -> Array:
#	var corners: Array = []  # Yikes LMAO - MartyrPher # I like turtles - velopman
#
#	var current: Vector2 = origin + direction * 2.0
#	while self.__detect_color(current, color): # BOOOO BORING, we don't want gamedev, we want editor plugin dev and shitposts! - totally_not_a_spambot # omg put a f*cking comma there already - TheYagich
#		if self.__detect_color(current + turn, color):
#			corners.append(current) # i think the most annoying thing with the comments is that it will scroll tothe cursor when commenting  - TheYagich
## STETCH goal, SRETCH goal... what is it velop?? - TheYagich
#		current += direction
#
#	corners.invert() # Lil'Oni was here - Lil'Oni
#	# oh and i guess erasing the code can be pretty annoying too - TheYagich # no - TheYagich
#	return corners


func __is_color(origin:Vector2, color: Color) -> bool:
	var index: int = self.__index_position_to_index(origin)
	if index == -1:
		return false

	return self.__squares[index].color_current == color


func __is_corner(origin: Vector2, side_a: Vector2, side_b: Vector2, color: Color) -> bool:
	if !self.__is_color(origin, color):
		return false

	for i in range(1, INVERSION_AREA_SIZE_MIN):
		for side in [side_a, side_b]:
			if !self.__is_color(origin + side * i, color):
				return false

	return true


func __is_side_of_length(origin: Vector2, direction: Vector2, length: int, color: Color) -> bool:
	for i in length:
		if !self.__is_color(origin + direction * i, color):
			return false

	return true


func __filter_containing_inversion_areas(inversion_areas: Array) -> Array:
	var remaining_inversion_areas: Array = []
	var reverse_contained: Array = []

	for i in inversion_areas.size():
		if reverse_contained.find(i) != -1:
			continue

		var area_a: InversionArea = inversion_areas[i]
		var valid: bool = true

		for j in range(i + 1, inversion_areas.size()):
			var area_b: InversionArea = inversion_areas[j]

			valid = valid && !area_b.contains_area(area_a)

			if area_a.contains_area(area_b):
				reverse_contained.append(j)

		if valid:
			remaining_inversion_areas.append(area_a)

	return remaining_inversion_areas


func __find_corners_in_direction(origin: Vector2, direction: Vector2, turn: Vector2, color: Color) -> Array:
	var corners: Array = []

	var current: Vector2 = origin
	while self.__is_color(current, color):
		if self.__is_corner(current, -direction, turn, color):
			corners.append(current)

		current += direction

	corners.invert()

	return corners


func __find_inversion_areas(player: Player) -> Array:
	var inversion_areas: Array = []

	var check_area_size: int = size - (INVERSION_AREA_SIZE_MIN - 1)
	for y in check_area_size:
		for x in check_area_size:
			var origin: Vector2 = Vector2(x, y)

			inversion_areas.append_array(self.__find_inversion_areas_at_position(origin, player))

	inversion_areas = self.__filter_containing_inversion_areas(inversion_areas)

	return inversion_areas


func __find_inversion_areas_at_position(origin: Vector2, player: Player) -> Array:
	var color: Color = player.color()
	var index_position: Vector2 = self.__position_to_index_position(player.position)

	if !self.__is_corner(origin, Vector2.DOWN, Vector2.RIGHT, color):
		return []

	var next_corner_distance_min: int = INVERSION_AREA_SIZE_MIN - 1

	var first_corners: Array = self.__find_corners_in_direction(
		origin + Vector2.RIGHT * next_corner_distance_min,
		Vector2.RIGHT,
		Vector2.DOWN,
		color
	)

	var second_corners: Array = []
	for first_corner in first_corners:
		var corners: Array = self.__find_corners_in_direction(
			first_corner + Vector2.DOWN * next_corner_distance_min,
			Vector2.DOWN,
			Vector2.LEFT,
			color
		)

		second_corners.append_array(corners)

	var inversion_areas: Array = []
	for second_corner in second_corners:
		var delta: Vector2 = second_corner - origin

		if !self.__is_side_of_length(second_corner, Vector2.LEFT, delta.x, color):
			continue

		var third_corner: Vector2 = second_corner + Vector2.LEFT * delta.x
		if !self.__is_side_of_length(third_corner, Vector2.UP, delta.y, color):
			continue

		var inversion_area: InversionArea = InversionArea.new(origin, second_corner)

		if !inversion_area.contains_position_border(index_position):
			continue

		inversion_areas.append(InversionArea.new(origin, second_corner))

	return self.__filter_containing_inversion_areas(inversion_areas)


func __calculate_points(square: Square, player: Player) -> int:
	var points: int = 1

	if square.color_previous == square.color_current:
		return 0

	if square.color_previous != Color.white:
		points += 1


	for inversion_area in self.__find_inversion_areas(player):

		for internal_positions in inversion_area.internal_positions:
			var index: int = self.__index_position_to_index(internal_positions)

			var current_square: Square = self.__squares[index]
			if current_square.has_target():
				continue

			var color = current_square.color_current

			if color != player.color():
				AudioManager.play_sound_effect("select")

				if color == Color.white:
					points += 1
				else:
					points += 2

				current_square.invert(player.color())

	return points


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
		var interface: ControlInterface = ControlInterface.new(
			ControlInterface.NONE,
			AIInput.new(
				funcref(self, "__board_state_getter"),
				funcref(self, "__player_state_getter"),
				self.__players[i].instance.color()
			)
		)

		if i < GlobalState.connected_interfaces.size():
			interface = ControlInterface.new(GlobalState.connected_interfaces[i])

		self.__players[i].instance.initialize(
			interface,
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
				index_position,
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

	player.set_coord(self.__position_to_index_position(player.position))

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
	if incoming.x < 0.0 || incoming.x >= self.size || incoming.y < 0.0 || incoming.y >= self.size:
		return -1

	return int(incoming.y * self.size + incoming.x)


func __position_to_index(incoming: Vector2) -> int:
	var index_position: Vector2 = self.__position_to_index_position(incoming)
	return self.__index_position_to_index(index_position)


func __set_winner_tween(incoming: float) -> void:
	winner_tween = incoming

	if self.__winner == null:
		return


	for player in self.__players:
		if self.__winner == player:
			continue # You can't report me, I'm too awesome. - Lil'Oni

		player.ui.rect_scale = lerp(
			Vector2(1.0, 1.0),
			Vector2(0.5, 0.5),
			incoming
		)

	self.__winner.ui.rect_position = lerp(
		self.__winner_position_ui,
		WIN_POSITION_UI,
		incoming
	)
	var scale: float = 1.0 + incoming
	self.__winner.ui.rect_scale = Vector2(scale, scale)


func __get_winner_tween() -> float:
	return winner_tween


func __return_to_main() -> void:
	SceneManager.load_scene("menu_start")

func __hide_children() -> void:
	for child in self.get_children():
		if child is AnimationPlayer:
			continue

		child.visible = false


func __board_state_getter() -> Array:
	return self.__squares

func __player_state_getter() -> Array:
	var players: Array = []

	for player in self.__players:
		players.append(player.instance)

	return players


func __play_sound_effect(name: String) -> void:
	AudioManager.play_sound_effect(name)
