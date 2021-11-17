class_name CompleteSquare


# Private variables

var top_left: Vector2 = Vector2.ZERO
var bottom_right: Vector2 = Vector2.ZERO

var internal_positions: Array = []


# Lifecycle methods

func _init(top_left: Vector2, bottom_right: Vector2) -> void:
	self.top_left = top_left
	self.bottom_right = bottom_right

	var delta: Vector2 = self.bottom_right - self.top_left

	for y in range(1.0, delta.y):
		for x in range(1.0, delta.x):
			self.internal_positions.append(self.top_left + Vector2(x, y))
