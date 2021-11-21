extends Node2D


# Const variables

const PLAYER_POSITIONS: Array = [
	Vector2(0, 4),
	Vector2(8, 4),
	Vector2(4, 0),
	Vector2(4, 8),
]

const AUDIO_PACK_REFERENCE: Resource = preload("res://source/audio_pack/game.tres")
const WIN_POSITION_UI: Vector2 = Vector2(1280.0/2.0 - 100.0, 720.0/2.0)
const WING_REFERENCE: Resource = preload("res://source/scenes/main/wings.tscn")


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

var __play_area: PlayArea = null
var __inversion_area_finder: InversionAreaFinder = null

var __playing: bool = false

var __winner: PlayerState = null
var __winner_position_player: Vector2 = Vector2.ZERO
var __winner_position_ui: Vector2 = Vector2.ZERO

var __wing_instance: Wings = null
var __wing_spawn_countdown: float = 0.0


# Lifecycle methods

func _ready() -> void:
	randomize()

	AudioManager.set_audio_pack(self.AUDIO_PACK_REFERENCE)
	AudioManager.play_music("banger", true)

	self.__wing_instance = WING_REFERENCE.instance()
	self.call_deferred("add_child", self.__wing_instance)

	self.__play_area = PlayArea.new(self, self.size)
	self.__play_area.initialize(funcref(self, "__wait_event_callback"))

	self.__inversion_area_finder = InversionAreaFinder.new(self.__play_area)

	self.__initialize_players()

	self.__animation.play("spawn")
	yield(self.__animation, "animation_finished")
	self.__animation.play("countdown")

	yield(Event, "wait_game_start")
	self.__playing = true
	self.__hour_glass.set_time_remaining(120) # #Why are you setting origin? - MartyrPher

	self.__wing_spawn_countdown = 2.0

	yield(Event, "wait_times_up")

	self.__wing_instance.fly()

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


func _process(delta: float) -> void:
	if self.__wing_spawn_countdown > 0.0:
		self.__wing_spawn_countdown = max(0.0, self.__wing_spawn_countdown - delta)

		if self.__wing_spawn_countdown == 0.0:
			while true:
				var area_position: Vector2 = Vector2(randi() % 4 + 2, randi() % 4 + 2)
				var square: Square = self.__play_area.square_at_area_position(area_position)

				if square != null && !square.has_target():
					var world_position: Vector2 = self.__play_area.area_position_to_world_position(
						area_position
					)

					self.__wing_instance.land(area_position, world_position)
					square.set_pick_up(self.__wing_instance)

					break

	elif !self.__wing_instance.is_active():
		self.__wing_spawn_countdown = randf() * 10.0 + 10.0


# Private methods

func __calculate_points(square: Square, player: Player) -> int:
	var points: int = 1

	if square.color_previous == square.color_current:
		return 0

	if square.color_previous != Color.white:
		points += 1

	for inversion_area in self.__inversion_area_finder.find(player):
		for internal_positions in inversion_area.internal_positions:
			var current_square: Square = self.__play_area.square_at_area_position(
				internal_positions
			) # idk what this does but if i remove it, app breaks down - Lumikkode
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
	var area_origin: Vector2 = self.__play_area.world_postition_to_area_position(origin)
	var area_destination: Vector2 = self.__play_area.world_postition_to_area_position(destination)

	var delta = (area_destination - area_origin).snapped(Vector2(0.1, 0.1))
	if [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN].find(delta) == -1:
		return false

	var square: Square = self.__play_area.square_at_world_position(destination)
	if square == null || !square.can_traverse(): # i will never add a comment fu - TheYagich
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
				funcref(self.__play_area, "state"),
				funcref(self, "__player_state_getter"),
				funcref(self, "__pick_up_state_getter"),
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


func __wait_event_callback(area_position: Vector2) -> String:
	if PLAYER_POSITIONS.find(area_position) == -1:
		return "wait_spawn_world"

	return "wait_spawn_player"


func __player_landed(player: Player) -> void:
	var square: Square = self.__play_area.square_at_world_position(player.position)
	if square == null:
		return

	square.land(player)

	player.set_coord(self.__play_area.world_postition_to_area_position(player.position))

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


func __player_state_getter() -> Array:
	var players: Array = []

	for player in self.__players:
		players.append(player.instance)

	return players


func __pick_up_state_getter() -> Array:
	return [self.__wing_instance]


func __play_sound_effect(name: String) -> void:
	AudioManager.play_sound_effect(name)
