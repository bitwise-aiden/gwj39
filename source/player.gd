class_name Player extends Node2D


# Public variables

export(float) var move_delta: float = 0.0 setget __set_move_delta, __get_move_delta
export(Resource) var data: Resource


# Private variables

onready var __animation: AnimationPlayer = $animation
onready var __sprite: Sprite = $sprite
onready var __arrows: Dictionary = {
	Vector2.LEFT: $arrow_left,
	Vector2.RIGHT: $arrow_right,
	Vector2.UP: $arrow_up,
	Vector2.DOWN: $arrow_down,
}

var __destination: Vector2 = Vector2.ZERO
var __origin: Vector2 = Vector2.ZERO

var __interface: ControlInterface = null
var __direction: Vector2 = Vector2.ZERO
var __can_move_callback: FuncRef = null

var __live: bool = false


# Lifecylce method

func _ready() -> void:
	self.__direction = self.data.start_direction


func _process(_delta: float) -> void:
	self.__interface.process()

	if self.__interface.direction() != Vector2.ZERO:
		self.__update_arrows(self.__interface.direction())


# Public methods

func color() -> Color:
	return self.data.color


func initialize(interface: ControlInterface, can_move_callback: FuncRef) -> void:
	self.__can_move_callback = can_move_callback
	self.__interface = interface

#	if self.__interface.interface() != 0:
	self.__sprite.texture = self.data.player

	yield(Event, "wait_game_start")
	self.__live = true

	self.__update_arrows(self.__direction)


func initiate_move() -> void:
	self.__animation.play("jump")


func land() -> void:
	Event.emit_signal("player_landed", self)


func move() -> void:
	if self.__interface.direction() != Vector2.ZERO:
		self.__direction =  self.__interface.direction()

	self.__origin = self.position

	if !self.__live || self.__can_move_callback == null:
		self.__destination = self.__origin
		return

	self.__destination = self.global_position + self.__direction * Globals.SQUARE_SIZE

	if !self.__can_move_callback.call_func(self, self.__origin, self.__destination):
		self.__destination = self.__origin
		return


# Private methods

func __get_move_delta() -> float:
	return move_delta


func __set_move_delta(incoming: float) -> void:
	move_delta = incoming

	if self.position == self.__destination:
		return

	self.position = lerp(self.__origin, self.__destination, move_delta)


func __update_arrows(direction: Vector2) -> void:
	for arrow in self.__arrows:
		self.__arrows[arrow].visible = arrow == direction


