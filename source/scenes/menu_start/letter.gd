extends TextureRect



# Private variables

var __color_current: Color = Color.white
var __color_previous: Color = Color.white

var __shader__offset: float = 0.4

# Lifecycle methods

func _ready() -> void:
	self.__color_current = Color.white
	self.__color_previous = Color.white

	if OS.get_name() == "HTML5":
		self.__shader_offset = 1.0

	self.start_change()

# Public methods

func set_color(color: Color) -> void:
	self.__color_previous = self.__color_current
	self.__color_current = color


func start_change() -> void:
	self.material.set_shader_param("previous_color", self.__color_previous)
	self.material.set_shader_param("current_color", self.__color_current)

	self.material.set_shader_param("start_time", OS.get_ticks_msec() / 1000.0 - self.__shader__offset)

