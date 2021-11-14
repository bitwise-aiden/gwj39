class_name Player extends Node2D


# Public variables

export(float) var move_delta: float = 0.0 setget __set_move_delta, __get_move_delta
export(Color) var color: Color = Color("8be866")


# Private variables

onready var __animation: AnimationPlayer = $animation
onready var __sprite: Sprite = $sprite

var __destination: Vector2 = Vector2.ZERO
var __origin: Vector2 = Vector2.ZERO
var __should_move: bool = false

var __interface: ControlInterface = null
var __direction: Vector2 = Vector2.ZERO
var __can_move_callback: FuncRef = null

var __texture: Texture = null


# Lifecylce method

func _ready() -> void:
	self.initiate_move()

	self.__sprite.texture = self.__texture


# Public methods
func initialize(
	position: Vector2,
	color: Color,
	texture: Texture,
	interface: ControlInterface,
	can_move_callback: FuncRef,
	direction: Vector2 = Vector2.ZERO
) -> void:
	self.color = color
	self.position = position

	self.__can_move_callback = can_move_callback
	self.__direction = direction
	self.__interface = interface
	self.__texture = texture


func initiate_move() -> void:
	self.__animation.play("jump")


func land() -> void:
	Event.emit_signal("player_landed", self)


func move() -> void:
	if self.__interface.direction() != Vector2.ZERO:
		self.__direction =  self.__interface.direction()

	self.__origin = self.position

	if self.__can_move_callback == null:
		self.__destination = self.__origin
		return

	self.__destination = self.global_position + self.__direction * Globals.SQUARE_SIZE

	if !self.__can_move_callback.call_func(self, self.__origin, self.__destination):
		self.__destination = self.__origin

	self.__should_move = true


# Private methods

func __get_move_delta() -> float:
	return move_delta


func __set_move_delta(incoming: float) -> void:
	move_delta = incoming

	if !self.__should_move:
		return

	self.position = lerp(self.__origin, self.__destination, move_delta)

	self.__should_move = self.position != self.__destination

