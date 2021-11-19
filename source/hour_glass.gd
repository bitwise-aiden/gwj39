extends Control


# Private variables

onready var __animation: AnimationPlayer = $animation


# Public functions

func turn() -> void:
	self.__animation.play("turn")


func drain() -> void:
	self.__animation.play("drain")
