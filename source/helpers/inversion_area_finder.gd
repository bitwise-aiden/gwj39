class_name InversionAreaFinder


# Private variables

var __play_area: PlayArea = null


# Lifecycle methods

func _init(play_area: PlayArea) -> void:
	self.__play_area = play_area

# Static methods

func find(player: Player) -> Array:
	var inversion_areas: Array = []

	var check_area_size: int = self.__play_area.size - (Globals.INVERSION_AREA_SIZE_MIN - 1)
	for y in check_area_size:
		for x in check_area_size:
			var origin: Vector2 = Vector2(x, y)

			inversion_areas.append_array(
				self.__find_inversion_areas_at_position(origin, player)
			)

	inversion_areas = self.__filter_containing_inversion_areas(inversion_areas)

	return inversion_areas


# Private methods

#
# Although this code is no longer used, I am keeping it here as memory for the first time
# I unleashed havoc on myself by letting my chat comment my codes as a channel point redemption...
# - velopman
#

#func __detect_corners(origin: Vector2, direction: Vector2, turn: Vector2, color: Color) -> Array:
#	var corners: Array = []  # Yikes LMAO - MartyrPher # I like turtles - velopman
#
#	var current: Vector2 = origin + direction * 2.0
#	while self.__detect_color(current, color): # BOOOO BORING, we don't want gamedev, we want editor plugin dev and shitposts! - totally_not_a_spambot # omg put a f*cking comma there already - TheYagich
#		if self.__detect_color(current + turn, color):
#			corners.append(current) # i think the most annoying thing with the comments is that it will scroll tothe cursor when commenting  - TheYagich
## STETCH goal, SRETCH goal... what is it velop?? - TheYagich
#		current += direction
#
#	corners.invert() # Lil'Oni was here - Lil'Oni
#	# oh and i guess erasing the code can be pretty annoying too - TheYagich # no - TheYagich
#	return corners


func __is_color(origin:Vector2, color: Color) -> bool: # This one is for my homies - Lumikkode
	var square: Square = self.__play_area.square_at_area_position(origin)
	return square != null && square.color_current == color


func __is_corner(origin: Vector2, side_a: Vector2, side_b: Vector2, color: Color) -> bool:
	if !self.__is_color(origin, color):
		return false

	for i in range(1, Globals.INVERSION_AREA_SIZE_MIN):
		for side in [side_a, side_b]:
			if !self.__is_color(origin + side * i, color):
				return false

	return true


func __is_side_of_length(origin: Vector2, direction: Vector2, length: int, color: Color) -> bool:
	for i in length:
		if !self.__is_color(origin + direction * i, color):
			return false

	return true


func __filter_containing_inversion_areas(inversion_areas: Array) -> Array:
	var remaining_inversion_areas: Array = []
	var reverse_contained: Array = []

	for i in inversion_areas.size():
		if reverse_contained.find(i) != -1:
			continue

		var area_a: InversionArea = inversion_areas[i]
		var valid: bool = true

		for j in range(i + 1, inversion_areas.size()):
			var area_b: InversionArea = inversion_areas[j]

			valid = valid && !area_b.contains_area(area_a)

			if area_a.contains_area(area_b):
				reverse_contained.append(j)

		if valid:
			remaining_inversion_areas.append(area_a)

	return remaining_inversion_areas


func __find_corners_in_direction(origin: Vector2, direction: Vector2, turn: Vector2, color: Color) -> Array:
	var corners: Array = []

	var current: Vector2 = origin
	while self.__is_color(current, color):
		if self.__is_corner(current, -direction, turn, color):
			corners.append(current)

		current += direction

	corners.invert()

	return corners


func __find_inversion_areas_at_position(origin: Vector2, player: Player) -> Array:
	var color: Color = player.color()
	var area_position: Vector2 = self.__play_area.world_postition_to_area_position(player.position)

	if !self.__is_corner(origin, Vector2.DOWN, Vector2.RIGHT, color):
		return []

	var next_corner_distance_min: int = Globals.INVERSION_AREA_SIZE_MIN - 1

	var first_corners: Array = self.__find_corners_in_direction(
		origin + Vector2.RIGHT * next_corner_distance_min,
		Vector2.RIGHT,
		Vector2.DOWN,
		color
	)

	var second_corners: Array = []
	for first_corner in first_corners:
		var corners: Array = self.__find_corners_in_direction(
			first_corner + Vector2.DOWN * next_corner_distance_min,
			Vector2.DOWN,
			Vector2.LEFT,
			color
		)

		second_corners.append_array(corners)

	var inversion_areas: Array = []
	for second_corner in second_corners:
		var delta: Vector2 = second_corner - origin

		if !self.__is_side_of_length(second_corner, Vector2.LEFT, delta.x, color):
			continue

		var third_corner: Vector2 = second_corner + Vector2.LEFT * delta.x
		if !self.__is_side_of_length(third_corner, Vector2.UP, delta.y, color):
			continue

		var inversion_area: InversionArea = InversionArea.new(origin, second_corner)

		if !inversion_area.contains_position_border(area_position):
			continue

		inversion_areas.append(InversionArea.new(origin, second_corner))

	return self.__filter_containing_inversion_areas(inversion_areas)
