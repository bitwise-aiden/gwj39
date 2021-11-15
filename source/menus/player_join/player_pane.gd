extends TextureRect

# Export variables

export(Resource) var inactive_data: Resource
export(Resource) var active_data: Resource

export(bool) var active: bool = false setget __set_active, __get_active

# Private variables

onready var __animation: AnimationPlayer = $animation
onready var __name: Label = $name
onready var __player: TextureRect = $player
onready var __keys: Array = [
	$key_1,
	$key_2,
	$key_3,
	$key_4,
]
onready var __controller: TextureRect = $controller
onready var __hand: TextureRect = $hand


# Lifecyle methods

func _ready() -> void:
	if self.active_data:
		self.__name.text = self.active_data.name
	self.active = self.active

	self.__animation.play("life")


# Public methods

func activate(interface: int) -> void:
	self.active = true


func __get_active() -> bool:
	return active


func __set_active(incoming: bool) -> void:
	active = incoming

	var data: PlayerData = self.inactive_data
	if active:
		data = self.active_data

	if data == null:
		return

	self.texture = data.pane
	self.__player.texture = data.player
	self.__controller.texture = data.controller
	for key in self.__keys:
		key.texture = data.key
	self.__hand.texture = data.touch
