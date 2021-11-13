class_name Player extends Node2D


# Public variables

export(float) var move_delta: float = 0.0 setget __set_move_delta, __get_move_delta


# Private variables

onready var __animation: AnimationPlayer = $animation

var __destination: Vector2 = Vector2.ZERO
var __origin: Vector2 = Vector2.ZERO
var __should_move: bool = false

var __direction: Vector2 = Vector2.ZERO
var __can_move_callback: FuncRef = null


# Lifecylce method

func _ready() -> void:
	self.initiate_move()


# Public methods

func initiate_move() -> void:
	self.__animation.play("jump")


func land() -> void:
	Event.emit_signal("player_landed", self)


func move() -> void:
	self.__origin = self.position

	if self.__can_move_callback == null:
		self.__destination = self.__origin
		return

	self.__destination = self.global_position + self.__direction * Globals.SQUARE_SIZE

	if !self.__can_move_callback.call_func(self.__origin, self.__destination):
		self.__destination = self.__origin

	self.__should_move = true


func set_can_move_callback(incoming: FuncRef) -> void:
	self.__can_move_callback = incoming


func set_direction(incoming: Vector2) -> void:
	self.__direction = incoming


# Private methods

func __get_move_delta() -> float:
	return move_delta


func __set_move_delta(incoming: float) -> void:
	move_delta = incoming

	if !self.__should_move:
		return

	self.position = lerp(self.__origin, self.__destination, move_delta)

	self.__should_move = self.position != self.__destination

