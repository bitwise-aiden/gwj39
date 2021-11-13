class_name Player extends Node2D


# Private variables

onready var __animation: AnimationPlayer = $animation

var __direction: Vector2 = Vector2.ZERO


# Lifecylce method

func _ready() -> void:
	self.initiate_move()


# Public methods

func initiate_move() -> void:
	self.__animation.play("jump")


func land() -> void:
	Event.emit_signal("player_landed", self)


func move() -> void:
	pass
