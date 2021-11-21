class_name TouchInput


# Private variables

var __direction: Vector2 = Vector2.ZERO

# Public methods

func direction(asethetic: bool = true) -> Vector2:
	return self.__direction


func is_active() -> bool:
	return self.__direction != Vector2.ZERO


func process() -> void:
#	self.__direction = Vector2.ZERO

	if TouchManager.event:
		var relative: Vector2 = TouchManager.event.relative
		if abs(relative.x) > abs(relative.y):
			self.__direction = Vector2(sign(relative.x), 0.0)
		else:
			self.__direction = Vector2(0.0, sign(relative.y))

