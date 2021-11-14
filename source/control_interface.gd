class_name ControlInterface

# Const variables

const KEYBOARD_1 = 1 << 0 # Default: WASD
const KEYBOARD_2 = 1 << 1 # Default: Arrow keys
const TOUCH = 1 << 2 # Default: Touch input


# Private variables

var __assigned: bool = false
var __direction: Vector2 = Vector2.ZERO
var __interface: int = 0

var __keyboard_1: PlayerInput = null setget , __get_keyboard_1
var __keyboard_2: PlayerInput = null setget , __get_keyboard_2


# Lifecycle methods

func _init(interface: int) -> void:
	self.__interface = interface


# Public methods

func assign() -> void:
	self.__assigned = true


func is_active() -> bool:
	return self.__direction != Vector2.ZERO


func is_assigned() -> bool:
	return self.__assigned


func direction() -> Vector2:
	return self.__direction


func process() -> void:
	if self.__interface & KEYBOARD_1:
		self.__keyboard_1.update()

		var direction: Vector2 = self.__keyboard_1.current()
		if direction != Vector2.ZERO:
			self.__direction = direction

	if self.__interface & KEYBOARD_2:
		self.__keyboard_2.update()

		var direction: Vector2 = self.__keyboard_2.current()
		if direction != Vector2.ZERO:
			self.__direction = direction

	if self.__interface & TOUCH:
		if TouchInput.direction != Vector2.ZERO:
			self.__direction = TouchInput.direction


# Private methods

func __get_keyboard_1() -> PlayerInput:
	if __keyboard_1 == null:
		__keyboard_1 = PlayerInput.new("keyboard_1")

	return __keyboard_1


func __get_keyboard_2() -> PlayerInput:
	if __keyboard_2 == null:
		__keyboard_2 = PlayerInput.new("keyboard_2")

	return __keyboard_2