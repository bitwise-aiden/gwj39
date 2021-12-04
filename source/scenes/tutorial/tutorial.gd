class_name Tutorial extends Node2D


# Const variables

const TUTORIAL_SIZE: int = 7
const TUTORIAL_TEXT_START: Vector2 = Vector2(0.0, 750.0)
const TUTORIAL_TEXT_FINISH: Vector2 = Vector2(0.0, 650.0)


# Private variables

onready var __player_1: Player = $player_1
onready var __player_2: Player = $player_2
onready var __text: Label = $text

var __play_area: PlayArea = null
var __timer: Timer = null
var __tween: Tween = null


# Lifecycle methods

func _ready() -> void:
	self.__play_area = PlayArea.new(self, TUTORIAL_SIZE)
	self.__play_area.initialize(funcref(self, "__wait_event_callback"))

	self.__timer = Timer.new()
	self.__timer.one_shot = true
	self.add_child(self.__timer)

	self.__tween = Tween.new()
	self.add_child(self.__tween)

	self.__player_1.initialize(
		ControlInterface.new(ControlInterface.TUTORIAL_PLAYER_1),
		funcref(self.__play_area, "can_move")
	)

	self.__player_2.initialize(
		ControlInterface.new(ControlInterface.TUTORIAL_PLAYER_2),
		funcref(self.__play_area, "can_move")
	)

	self.__timer.start(3.0)

	Event.emit_signal("tutorial_squares_1")


	var middle_position: Vector2 = self.__play_area.area_position_to_world_position(
		Vector2(3.0, 3.0)
	)

	self.__tween.interpolate_property(
		self.__player_1,
		"position",
		middle_position - Vector2(0.0, 1000.0),
		middle_position,
		0.5
	)
	self.__tween.start()
	yield(self.__tween, "tween_completed")

	self.__player_1.land()

	yield(self.__show_text("You are a slime!"), "completed")

	Event.emit_signal("tutorial_squares_2")

	yield(self.__show_text("Use directions to move, invert squares, and collect points", false), "completed")

	Event.emit_signal("wait_game_start")
	Event.emit_signal("tutorial_player_move")

	yield(Event, "tutorial_player_moved")

	yield(self.__hide_text(), "completed")
	Event.emit_signal("clear_board")

	yield(self.__show_text("Forming rectangles will cause inside squares to invert", false), "completed")

	Event.emit_signal("tutorial_player_move")

	yield(self.__show_text(""), "completed")


# Private methods

func __wait_event_callback(position: Vector2) -> String:
	var middle_delta: Vector2 = position - Vector2(3.0, 3.0)

	var max_delta: float = max(abs(middle_delta.x), abs(middle_delta.y))

	return "tutorial_squares_%d" % int(max_delta + 1.0)


func __hide_text() -> void:
	self.__tween.interpolate_property(
		self.__text,
		"rect_position",
		TUTORIAL_TEXT_FINISH,
		TUTORIAL_TEXT_START,
		0.5, # Velop is awesome - Lil'Oni
		Tween.TRANS_BOUNCE
	)
	self.__tween.start()
	yield(self.__tween, "tween_completed")


func __show_text(text: String, clear: bool = true) -> void:
	self.__text.text = text
	self.__tween.interpolate_property(
		self.__text,
		"rect_position",
		TUTORIAL_TEXT_START,
		TUTORIAL_TEXT_FINISH,
		0.5,
		Tween.TRANS_BOUNCE
	)
	self.__tween.start()
	yield(self.__tween, "tween_completed")

	if clear:
		self.__timer.start(2.0)
		yield(self.__timer, "timeout")
		yield(self.__hide_text(), "completed")
