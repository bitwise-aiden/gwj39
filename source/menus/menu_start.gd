extends Control


# Private methods

onready var __animation: AnimationPlayer = $animation
onready var __button_play: Button = $play
onready var __button_tutorial: Button = $tutorial
onready var __button_settings: Button = $settings
onready var __button_exit: Button = $exit



# Lifecylce methods

func _ready() -> void:
	self.__animation.play("load")
	yield(self.__animation, "animation_finished")

	self.__button_play.grab_focus()
	self.__animation.play("change")
