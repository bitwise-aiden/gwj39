extends Control


# Private variables

onready var __animation: AnimationPlayer = $animation
onready var __player_panes: Array = [
	$player_1_pane,
	$player_2_pane,
	$player_3_pane,
	$player_4_pane,
]

onready var __button_back: Button = $back
onready var __button_start: Button = $start


var __control_interfaces: Array = [
	ControlInterface.new(ControlInterface.KEYBOARD_1),
	ControlInterface.new(ControlInterface.KEYBOARD_2),
	ControlInterface.new(ControlInterface.TOUCH),
	ControlInterface.new(ControlInterface.CONTROLLER_1),
	ControlInterface.new(ControlInterface.CONTROLLER_2),
	ControlInterface.new(ControlInterface.CONTROLLER_3),
	ControlInterface.new(ControlInterface.CONTROLLER_4),
]


# Lifecylce methods

func _ready()-> void:
	self.__button_start.connect("pressed", self, "__start_pressed")
	self.__button_back.connect("pressed", self, "__back_pressed")

	GlobalState.connected_interfaces.clear()

	self.__animation.play("load")


func _process(_delta: float) -> void:
	var player_count = GlobalState.connected_interfaces.size()
	if player_count == 4:
		return

	for interface in self.__control_interfaces:
		interface.process()

		if interface.is_active() && !interface.is_assigned():
			interface.assign()

			# Give interface to the current pane
			self.__player_panes[player_count].activate(interface.interface())

			GlobalState.connected_interfaces.append(interface.interface())

			if GlobalState.connected_interfaces.size() == 1:
				self.__button_start.disabled = false
				self.__button_start.grab_focus()


# Private methods

func __start_pressed() -> void:
	self.__animation.play("start_game")
	yield(self.__animation, "animation_finished")

	SceneManager.load_scene("main")


func __back_pressed() -> void:
	self.__animation.play_backwards("load")
	yield(self.__animation, "animation_finished")

	SceneManager.load_scene("menu_start")
