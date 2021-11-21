extends Control


# Private variables

onready var __animation: AnimationPlayer = $animation
onready var __back: Button = $back

# Lifecylce methods

func _ready() -> void:
	self.__animation.play("load")
	self.__back.connect("pressed", self, "__back_pressed")


# Private methods

func __back_pressed() -> void:
	AudioManager.play_sound_effect("select")

	self.__animation.play("leave")
	yield(self.__animation, "animation_finished")

	SceneManager.load_scene("menu_start")
