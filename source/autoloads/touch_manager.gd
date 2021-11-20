extends Node

# Public variables

var event: InputEventScreenDrag = null


# Private variables

var __just_handled: bool = false


# Lifecylce methods

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag && event.relative.length() > 10.0:
		self.event = event
		self.__just_handled = true


func _process(delta: float) -> void:
	if self.__just_handled:
		self.__just_handled = false

		return

	self.event = null
