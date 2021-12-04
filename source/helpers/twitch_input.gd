class_name TwitchInput extends Node


# Const variables

const COMMANDS = {
	'!up': Vector2.UP,
	'!u': Vector2.UP,
	'!down': Vector2.DOWN,
	'!d': Vector2.DOWN,
	'!left': Vector2.LEFT,
	'!l': Vector2.LEFT,
	'!right': Vector2.RIGHT,
	'!r': Vector2.RIGHT,
}


# Public variables

var username: String = ""


# Private variables

var __identifier: String = ""
var __direction: Vector2 = Vector2.ZERO


# Lifecycle methods

func _init(identifier: String = "") -> void:
	self.__identifier = identifier

	Event.connect("twitch_input", self, "__process_chat")
	Event.connect("twitch_join", self, "__player_joined")


# Public methods

func direction(asethetic: bool = true) -> Vector2:
	return self.__direction


func is_active() -> bool:
	return self.username != ""


func process() -> void:
	pass


# Private methods

func __process_chat(identifier: String, command: String) -> void:
	if self.__identifier != identifier:
		return

	if command in self.COMMANDS:
		self.__direction = self.COMMANDS[command]


func __player_joined(identifier: String, username: String) -> void:
	if self.__identifier != identifier:
		return

	self.username = username


