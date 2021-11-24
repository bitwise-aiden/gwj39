class_name ControlInterface

# Const variables

const NONE = 0 # AI
const KEYBOARD_1 = 1 << 0 # Default: WASD
const KEYBOARD_2 = 1 << 1 # Default: Arrow keys
const TOUCH = 1 << 2 # Default: Touch input
const CONTROLLER_1 = 1 << 3 # Default: Controller, slot 1
const CONTROLLER_2 = 1 << 4 # Default: Controller, slot 2
const CONTROLLER_3 = 1 << 5 # Default: Controller, slot 3
const CONTROLLER_4 = 1 << 6 # Default: Controller, slot 4
const TUTORIAL_PLAYER_1 = 1 << 7 # Tutorial purposes
const TUTORIAL_PLAYER_2 = 1 << 8 # Tutorial purposes

const KEYBOARD = KEYBOARD_1 | KEYBOARD_2
const CONTROLLER = CONTROLLER_1 | CONTROLLER_2 | CONTROLLER_3 | CONTROLLER_4


# Private variables

var __active: bool = false
var __assigned: bool = false
var __direction: Vector2 = Vector2.ZERO
var __interface: int = 0
var __interfaces: Array = []


# Lifecycle methods

func _init(interface: int, ai: AIInput = null) -> void:
	self.__interface = interface

	if self.__interface == 0 && ai:
		self.__interfaces.append(ai)

	if self.__interface & KEYBOARD_1:
		self.__interfaces.append(PlayerInput.new("keyboard_1"))

	if self.__interface & KEYBOARD_2:
		self.__interfaces.append(PlayerInput.new("keyboard_2"))

	if self.__interface & TOUCH:
		self.__interfaces.append(TouchInput.new())

	if self.__interface & CONTROLLER_1:
		self.__interfaces.append(ControllerInput.new(0))

	if self.__interface & CONTROLLER_2:
		self.__interfaces.append(ControllerInput.new(1))

	if self.__interface & CONTROLLER_3:
		self.__interfaces.append(ControllerInput.new(2))

	if self.__interface & CONTROLLER_4:
		self.__interfaces.append(ControllerInput.new(3))

	if self.__interface & TUTORIAL_PLAYER_1:
		self.__interfaces.append(TutorialPlayer1Input.new())

	if self.__interface & TUTORIAL_PLAYER_2:
		self.__interfaces.append(TutorialPlayer2Input.new()) # i'll get you next time, gadget, next time... - TheYagich


# Public methods

func assign() -> void:
	self.__assigned = true


func interface() -> int:
	return self.__interface


func is_active() -> bool:
	return self.__active


func is_assigned() -> bool:
	return self.__assigned


func direction(asethetic: bool = true) -> Vector2:
	var direction: Vector2 = Vector2.ZERO

	for interface in self.__interfaces:
		var direction_new: Vector2 = interface.direction(asethetic)
		if direction_new != Vector2.ZERO:
			direction = direction_new
			break

	if direction != Vector2.ZERO:
		self.__direction = direction

	return self.__direction


func process() -> void:
	for interface in self.__interfaces:
		interface.process()

		self.__active = self.__active || interface.is_active()
