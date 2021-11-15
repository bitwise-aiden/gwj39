class_name ControllerInput

# Constant variables

const CONTROLLER_INPUT: Dictionary = {
	JOY_DPAD_LEFT: Vector2.LEFT,
	JOY_DPAD_RIGHT: Vector2.RIGHT,
	JOY_DPAD_UP: Vector2.UP,
	JOY_DPAD_DOWN: Vector2.DOWN,
}


# Private variables

var __axis_history: Vector2 = Vector2.ZERO
var __button_history: Dictionary = {
	JOY_DPAD_LEFT: false,
	JOY_DPAD_RIGHT: false,
	JOY_DPAD_UP: false,
	JOY_DPAD_DOWN: false,
}
var __device: int = 0
var __input_queue: CurrentQueue = CurrentQueue.new(Vector2.ZERO)

# Lifecycle methods

func _init(device: int) -> void:
	self.__device = device


# Public methods

func direction() -> Vector2:
	return self.__input_queue.current()


func process() -> void:
	if !Input.is_joy_known(self.__device):
		return

	var axis: Vector2 = Vector2(
		Input.get_joy_axis(self.__device, JOY_AXIS_0),
		Input.get_joy_axis(self.__device, JOY_AXIS_1)
	)

	var axis_current = Vector2.ZERO

	if axis.length() > 0.3:
		if abs(axis.x) > abs(axis.y):
			axis_current = Vector2(sign(axis.x), 0.0)
		else:
			axis_current = Vector2(0.0, sign(axis.y))

	if axis_current != self.__axis_history:
		if axis_current != Vector2.ZERO:
			self.__input_queue.add(axis_current)
		self.__input_queue.remove(self.__axis_history)

		self.__axis_history = axis_current

	for button in CONTROLLER_INPUT:
		var current: bool = Input.is_joy_button_pressed(self.__device, button)
		var previous: bool = self.__button_history[button]

		if current && !previous:
			self.__input_queue.add(CONTROLLER_INPUT[button])

		if !current && previous:
			self.__input_queue.remove(CONTROLLER_INPUT[button])

		self.__button_history[button] = current


