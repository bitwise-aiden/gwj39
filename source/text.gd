extends Label


var __swipe_start: Vector2 = Vector2.INF


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if self.__swipe_start == Vector2.INF:
				self.__swipe_start = event.get_position()
		else:
			var direction = event.get_position() - self.__swipe_start

			if abs(direction.x) > abs(direction.y):
				self.text = "left" if direction.x < 0.0 else "right"
			else:
				self.text = "up" if direction.y < 0.0 else "down"

			self.__swipe_start = Vector2.INF
