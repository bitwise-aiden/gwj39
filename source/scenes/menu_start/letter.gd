extends TextureRect



# Private variables

var __color_current: Color = Color.white
var __color_previous: Color = Color.white

var __shader__offset: float = 0.4
var __shader_tween: Tween = null

# Lifecycle methods

func _ready() -> void:
	self.__color_current = Color.white
	self.__color_previous = Color.white

	self.__shader_tween = Tween.new()
	self.add_child(self.__shader_tween)

	self.start_change()

# Public methods

func set_color(color: Color) -> void:
	self.__color_previous = self.__color_current
	self.__color_current = color


func start_change() -> void:
	self.material.set_shader_param("previous_color", self.__color_previous)
	self.material.set_shader_param("current_color", self.__color_current)

	self.__shader_tween.interpolate_method(
		self,
		"__set_shader_delta",
		0.0,
		10.0,
		0.1
	)
	self.__shader_tween.start()


func __set_shader_delta(incoming: float) -> void:
	self.material.set_shader_param("delta", incoming)
