extends Control


# Private variables

onready var __player_panes: Array = [
	$player_1_pane,
	$player_2_pane,
	$player_3_pane,
	$player_4_pane,
]


var __control_interfaces: Array = [
	ControlInterface.new(ControlInterface.TOUCH),
	ControlInterface.new(ControlInterface.KEYBOARD_1),
	ControlInterface.new(ControlInterface.KEYBOARD_2),
]
var __active_interfaces: Array = []


# Lifecylce methods

func _process(delta: float) -> void:
	var player_count = self.__active_interfaces.size()
	if player_count == 4:
		return

	for interface in self.__control_interfaces:
		interface.process()

		if interface.is_active() && !interface.is_assigned():
			interface.assign()

			# Give interface to the current pane
			self.__player_panes[player_count].activate(interface.interface())

			self.__active_interfaces.append(interface.interface())


