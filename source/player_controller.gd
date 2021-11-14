class_name PlayerController

# Know about which input to use
# Able to query for current direction


# Private variables

var __interface: ControlInterface = null


# Lifecycle methods

func _init(interface: ControlInterface) -> void:
	self.__interface = interface


# Public method

func direction() -> Vector2:
	if self.__interface == null:
		return Vector2.ZERO

	return self.__interface.direction()

