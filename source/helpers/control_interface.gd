class_name ControlInterface

# Const variables

const KEYBOARD_1 = 1 << 0 # Default: WASD
const KEYBOARD_2 = 1 << 1 # Default: Arrow keys
const TOUCH = 1 << 2 # Default: Touch input
const CONTROLLER_1 = 1 << 4 # Default: Controller, slot 1
const CONTROLLER_2 = 1 << 5 # Default: Controller, slot 2
const CONTROLLER_3 = 1 << 6 # Default: Controller, slot 3
const CONTROLLER_4 = 1 << 7 # Default: Controller, slot 4

const KEYBOARD = KEYBOARD_1 | KEYBOARD_2
const CONTROLLER = CONTROLLER_1 | CONTROLLER_2 | CONTROLLER_3 | CONTROLLER_4


# Private variables

var __assigned: bool = false
var __direction: Vector2 = Vector2.ZERO
var __interface: int = 0

var __keyboard_1: PlayerInput = null setget , __get_keyboard_1
var __keyboard_2: PlayerInput = null setget , __get_keyboard_2

var __controller_1: ControllerInput = null setget , __get_controller_1
var __controller_2: ControllerInput = null setget , __get_controller_2
var __controller_3: ControllerInput = null setget , __get_controller_3
var __controller_4: ControllerInput = null setget , __get_controller_4


# Lifecycle methods

func _init(interface: int) -> void:
	self.__interface = interface


# Public methods

func assign() -> void:
	self.__assigned = true


func interface() -> int:
	return self.__interface


func is_active() -> bool:
	return self.__direction != Vector2.ZERO


func is_assigned() -> bool:
	return self.__assigned


func direction() -> Vector2:
	return self.__direction


func process() -> void:
	if self.__interface & KEYBOARD_1:
		self.__keyboard_1.process()

		var direction: Vector2 = self.__keyboard_1.direction()
		if direction != Vector2.ZERO:
			self.__direction = direction

	if self.__interface & KEYBOARD_2:
		self.__keyboard_2.process()

		var direction: Vector2 = self.__keyboard_2.direction()
		if direction != Vector2.ZERO:
			self.__direction = direction

	if self.__interface & CONTROLLER_1:
		self.__controller_1.process()

		var direction: Vector2 = self.__controller_1.direction()
		if direction != Vector2.ZERO:
			self.__direction = direction

	if self.__interface & CONTROLLER_2:
		self.__controller_2.process()

		var direction: Vector2 = self.__controller_2.direction()
		if direction != Vector2.ZERO:
			self.__direction = direction

	if self.__interface & CONTROLLER_3:
		self.__controller_3.process()

		var direction: Vector2 = self.__controller_3.direction()
		if direction != Vector2.ZERO:
			self.__direction = direction

	if self.__interface & CONTROLLER_4:
		self.__controller_4.process()

		var direction: Vector2 = self.__controller_4.direction()
		if direction != Vector2.ZERO:
			self.__direction = direction

	if self.__interface & TOUCH:
		if TouchInput.direction != Vector2.ZERO:
			self.__direction = TouchInput.direction


# Private methods


func __get_controller_1() -> ControllerInput:
	if __controller_1 == null:
		__controller_1 = ControllerInput.new(0)

	return __controller_1


func __get_controller_2() -> ControllerInput:
	if __controller_2 == null:
		__controller_2 = ControllerInput.new(1)

	return __controller_2


func __get_controller_3() -> ControllerInput:
	if __controller_3 == null:
		__controller_3 = ControllerInput.new(2)

	return __controller_3


func __get_controller_4() -> ControllerInput:
	if __controller_4 == null:
		__controller_4 = ControllerInput.new(3)

	return __controller_4


func __get_keyboard_1() -> PlayerInput:
	if __keyboard_1 == null:
		__keyboard_1 = PlayerInput.new("keyboard_1")

	return __keyboard_1


func __get_keyboard_2() -> PlayerInput:
	if __keyboard_2 == null:
		__keyboard_2 = PlayerInput.new("keyboard_2")

	return __keyboard_2
