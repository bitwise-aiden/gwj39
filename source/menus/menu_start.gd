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

	self.__button_play.connect("pressed", self, "__change_scene", ["player_join"])
#	self.__button_tutorial.connect("pressed", self, "__change_scene", ["tutorial"])
#	self.__button_settings.connect("pressed", self, "__change_scene", ["menu_settings"])
	self.__button_exit.connect("pressed", self, "__exit_pressed")


# Private methods

func __change_scene(scene: String) -> void:
	self.__animation.play("change_scene")
	yield(self.__animation, "animation_finished")

	SceneManager.load_scene(scene)


func __exit_pressed() -> void:
	self.__animation.playback_speed = 2.0
	self.__animation.play_backwards("load")
	yield(self.__animation, "animation_finished")

	self.get_tree().quit()

