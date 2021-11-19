extends Control


# Private methods

onready var __animation: AnimationPlayer = $animation


# Lifecylce methods

func _ready() -> void:
	self.__animation.play("load")
	yield(self.__animation, "animation_finished")

	self.__animation.play("change")
