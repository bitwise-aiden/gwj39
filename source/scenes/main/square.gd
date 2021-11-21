class_name Square extends Node2D


# Public variables

export(Vector2) var player_position: Vector2 setget __set_player_position, __get_player_position

var color_previous: Color = Color.white
var color_current: Color = Color.white
var coord: Vector2 = Vector2.ZERO

# Private variables

onready var __animation: AnimationPlayer = $animation
onready var __default_playback_speed: float = self.__animation.playback_speed
onready var __sprite: Sprite = $sprite


var __origin: Vector2 = Vector2.ZERO
var __start_offset: Vector2 = Vector2.ZERO
var __speed: float = 1.0
var __live: bool = false

var __target: Player = null
var __target_origin: Vector2 = Vector2.ZERO

var __untraversable_timer: Timer = null

var __shader_offset: float = 0.8
var __shader_time_elapsed: float = 0.0
var __shader_tween: Tween = null

var __pick_up: PickUp = null

var __time_since_occupied: float = 0.0



# Lifecycle methods

func _ready() -> void: # Velop is a bad influence, we are now all awake at 3AM.  - Lil'Oni
	self.__untraversable_timer = Timer.new()
	self.__untraversable_timer.one_shot = true
	self.__untraversable_timer.wait_time = 1.0
	self.call_deferred("add_child", self.__untraversable_timer)

	self.__shader_tween = Tween.new()
	self.call_deferred("add_child", self.__shader_tween)

	Event.connect("wait_times_up", self, "set", ["__live", false])

	if OS.has_feature('JavaScript'):
		self.__shader_offset = 15

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

	self.__time_since_occupied += delta
	if self.__time_since_occupied > 1.0:
		self.complete()
		self.__time_since_occupied = 0.0


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

	self.__animation.playback_speed = self.__default_playback_speed

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

	self.__shader_tween.interpolate_method(
		self,
		"__set_shader_delta",
		0.0,
		5.0,
		0.2
	)
	self.__shader_tween.start()

#	self.__sprite.material.set_shader_param("delta", 0.0 - 10.0)

#	self.__sprite.material.set_shader_param("start_time", OS.get_ticks_msec() / 1000.0 - self.__shader_offset)


func has_target() -> bool:
	return self.__target != null


func land(player: Player) -> void:
	self.__target = player
	self.__target_origin = player.position

	self.__animation.playback_speed = self.__default_playback_speed * self.__target.speed

	self.__animation.play("square_animation")

	if self.__pick_up != null:
		self.__pick_up.collect(self.__target)
		self.__pick_up = null

	self.__time_since_occupied = 0.0

	self.invert(player.color())


func is_occupied_by(color: Color) -> bool:
	return self.has_target() && self.__target.color() == color


func reserve(player: Player) -> void:
	self.__target = player


func set_pick_up(pick_up: PickUp) -> void:
	self.__pick_up = pick_up


func target() -> Player:
	return self.__target


# Private methods

func __get_player_position() -> Vector2:
	return player_position


func __set_player_position(incoming: Vector2) -> void:
	player_position = incoming

	if self.__target != null:
		self.__target.position = self.__target_origin + incoming


func __set_shader_delta(incoming: float) -> void:
	self.__sprite.material.set_shader_param("delta", incoming)
