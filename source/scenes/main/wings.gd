class_name Wings extends PickUp


# Private variables

onready var __animation: AnimationPlayer = $animation
onready var __sprite: Sprite = $sprite

var __timer: Timer = null


# Lifecycle methods

func _ready() -> void:
	self.__timer = Timer.new()
	self.__timer.one_shot = true
	self.__timer.wait_time = 10.0

	self.__sprite.position.y = 1038

	self.call_deferred("add_child", self.__timer)


# Public methods

func collect(player: Player) -> void:
	player.speed = 2.0

	AudioManager.play_sound_effect("collect")

	self.fly()

	self.__timer.start()
	yield(self.__timer, "timeout")

	player.speed = 1.0

	self._active = false


func fly() -> void:
	if self.__sprite.y < -1000.0:
		return

	self.__animation.play("fly")


func land(coord: Vector2, position: Vector2) -> void:
	self.coord = coord
	self._active = true

	self.position = position
	self.__animation.play_backwards("fly")

	yield(self.__animation, "animation_finished")

	self.__animation.play("idle")
