class_name Square extends Node2D


# Public variables

export(Vector2) var player_position: Vector2 setget __set_player_position, __get_player_position

var color_previous: Color = Color.white
var color_current: Color = Color.white
var coord: Vector2 = Vector2.ZERO

# Private variables

onready var __animation: AnimationPlayer = $animation
onready var __sprite: Sprite = $sprite


var __origin: Vector2 = Vector2.ZERO
var __start_offset: Vector2 = Vector2.ZERO
var __speed: float = 1.0
var __live: bool = false

var __target: Player = null
var __target_origin: Vector2 = Vector2.ZERO

var __untraversable_timer: Timer = null


# Lifecycle methods

func _ready() -> void: # Velop is a bad influence, we are now all awake at 3AM.  - Lil'Oni
	self.__untraversable_timer = Timer.new()
	self.__untraversable_timer.one_shot = true
	self.__untraversable_timer.wait_time = 1.0
	self.call_deferred("add_child", self.__untraversable_timer)

	Event.connect("wait_times_up", self, "set", ["__live", false])


func _process(delta: float) -> void:
	if !self.__live:
		return

	var distance: float = self.position.distance_to(self.__origin)

	if distance != 0.0:
		var max_distance = self.position.distance_to(self.position + self.__start_offset)
		var modifier: float = 0.25 + (distance * distance) / (max_distance * max_distance)

		self.position = self.position.move_toward(
			self.__origin,
			delta * self.__speed * 1000.0 * modifier
		)


# Public methods

func can_traverse() -> bool:
	return (
		self.__live &&
		self.position.distance_to(self.__origin) == 0.0 &&
		self.__target == null &&
		self.__untraversable_timer.is_stopped() &&
		self.position.y < 1000.0
	)


func complete() -> void:
	if self.__target == null:
		return

	self.__target.initiate_move()
	self.__target = null
	self.__target_origin = Vector2.ZERO

	self.__untraversable_timer.start()


func initialize(coord: Vector2, origin: Vector2, start_offset: Vector2, speed: float, wait_event: String) -> void:
	self.position = origin + start_offset

	self.coord = coord

	self.__origin = origin
	self.__start_offset = start_offset
	self.__speed = speed

	yield(Event, wait_event)

	self.__live = true

	yield(Event, "wait_end_game")

	if self.__target == null && self.__untraversable_timer.time_left < 0.5:
		self.__origin = self.position + self.__start_offset
		self.__live = true


func invert(color: Color) -> void:
	self.color_previous = self.color_current
	self.__sprite.material.set_shader_param("previous_color", self.color_previous)

	self.color_current = color
	self.__sprite.material.set_shader_param("current_color", self.color_current)

	self.__sprite.material.set_shader_param("start_time", OS.get_ticks_msec() / 1000.0 - 0.8)


func has_target() -> bool:
	return self.__target != null


func land(player: Player) -> void:
	self.__target = player
	self.__target_origin = player.position

	self.__animation.play("square_animation")

	self.invert(player.color())


func is_occupied_by(color: Color) -> bool:
	return self.has_target() && self.__target.color() == color


func reserve(player: Player) -> void:
	self.__target = player

func target() -> Player:
	return self.__target


# Private methods

func __get_player_position() -> Vector2:
	return player_position


func __set_player_position(incoming: Vector2) -> void:
	player_position = incoming

	if self.__target != null:
		self.__target.position = self.__target_origin + incoming
