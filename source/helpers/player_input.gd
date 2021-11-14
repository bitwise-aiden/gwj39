class_name PlayerInput


# Const variables

const PLAYER_INPUT: Dictionary = {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT,
}


# Priate variables

var __input_queue: CurrentQueue = CurrentQueue.new(Vector2.ZERO)
var __inputs: Dictionary = {}

# Lifecycle method

func _init(identifier: String = "") -> void:
	for input in self.PLAYER_INPUT:
		var input_key: String = input

		if identifier:
			input_key = "%s_%s" % [identifier, input]

		self.__inputs[input_key] = PLAYER_INPUT[input]


# Public methods

func current() -> Vector2:
	return self.__input_queue.current()


func update() -> void:
	for input in self.__inputs:
		if Input.is_action_just_pressed(input):
			self.__input_queue.add(self.__inputs[input])
		elif Input.is_action_just_released(input):
			self.__input_queue.remove(self.__inputs[input])
