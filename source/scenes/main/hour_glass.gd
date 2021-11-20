class_name HourGlass extends Control


# Private variables

onready var __animation: AnimationPlayer = $animation
onready var __dust: TextureRect = $dust
onready var __time_output: Label = $time

var __time_remaining: float = 0.0
var __time_total: float = 0.0

var __shake_time_remaining: float = 0.0
var __shake_origin: Vector2 = Vector2.ZERO


# Lifecylce methods

func _process(delta: float) -> void:
	if self.__time_remaining > 0.0:
		if int(self.__time_remaining * 2.0) > int(self.__time_remaining * 2.0 - delta):
			self.__dust.rect_scale.x *= -1

		if self.__time_remaining / self.__time_total < 0.1:
			delta *= 0.75
			self.__animation.playback_speed = 10.0 / self.__time_total * 0.75

		self.__time_remaining = max(0.0, self.__time_remaining - delta)

		var time_output: int = ceil(self.__time_remaining)
		self.__time_output.text = "%03d" % time_output

		if self.__time_remaining == 0.0:
			Event.emit_signal("wait_times_up")
			self.__shake_time_remaining = 1.0
			self.__shake_origin = self.rect_position

	if self.__shake_time_remaining > 0.0:
		self.__shake_time_remaining = max(0.0, self.__shake_time_remaining - delta)

		self.rect_position = self.__shake_origin + Vector2(10.0, 0.0).rotated(randf() * PI * 2.0)

		if self.__shake_time_remaining == 0.0:  # #Why are you setting origin? - MartyrPher
			self.rect_position = self.__shake_origin



# Public functions

func set_time_remaining(time: float) -> void:
	self.__animation.playback_speed = 10.0 / time

	self.__time_remaining = time
	self.__time_total = time


func turn() -> void:
	self.__animation.play("turn")


func drain() -> void:
	self.__animation.play("drain")
