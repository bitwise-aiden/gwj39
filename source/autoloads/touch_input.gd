extends Node


# Public variables

var direction: Vector2 = Vector2.ZERO setget , __get_direction


# Private variables

var __swipe_start: Vector2 = Vector2.INF


# Lifecycle methods

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if self.__swipe_start == Vector2.INF:
				self.__swipe_start = event.get_position()
		else:
			var delta = event.get_position() - self.__swipe_start

			if abs(delta.x) > abs(delta.y):
				direction = Vector2(sign(delta.x), 0.0)
			else:
				direction = Vector2(0.0, sign(delta.y))

			self.__swipe_start = Vector2.INF


# Private methods

func __get_direction() -> Vector2:
	return direction
