extends HSlider


export (String) var display_name = "Volume"
export (String) var controlled_bus = null

export (Array, Texture) var sliders: Array = []

onready var label = $label


# Lifecycle methods
func _ready() -> void:
	if !self.controlled_bus:
		Logger.warn("Volume slider '%s' does not have a controlled bus." % self.display_name)

	self.value = AudioManager.get_volume(self.controlled_bus)

	self.label.text = self.display_name

	self.connect("value_changed", self, "__value_changed")
	self.connect("focus_entered", self, "__focus_entered")


# Private methods
func __value_changed(value: float) -> void:
	AudioManager.set_volume(self.controlled_bus, value)
