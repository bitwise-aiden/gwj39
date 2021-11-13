class_name Square extends Node2D


# Public variables

export(Vector2) var player_position: Vector2 setget __set_player_position, __get_player_position


# Private variables

onready var __animation: AnimationPlayer = $animation
onready var __sprite: Sprite = $sprite

var __target: Player = null
var __target_origin: Vector2 = Vector2.ZERO

var __previous_color: Color = Color.white
var __current_color: Color = Color.white


# Public methods

func complete() -> void:
	if self.__target == null:
		return

	self.__target.initiate_move()
	self.__target = null
	self.__target_origin = Vector2.ZERO


func land(player: Player) -> void:
	self.__target = player
	self.__target_origin = player.position

	self.__animation.play("square_animation")

	self.__previous_color = self.__current_color
	self.__sprite.material.set_shader_param("previous_color", self.__previous_color)

	self.__current_color = player.color
	self.__sprite.material.set_shader_param("current_color", self.__current_color)

	self.__sprite.material.set_shader_param("start_time", OS.get_ticks_msec() / 1000.0)


# Private methods

func __get_player_position() -> Vector2:
	return player_position


func __set_player_position(incoming: Vector2) -> void:
	player_position = incoming

	if self.__target != null:
		self.__target.position = self.__target_origin + incoming
