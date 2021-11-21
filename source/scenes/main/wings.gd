class_name Wings extends PickUp


# Private variables

onready var __animation: AnimationPlayer = $animation

var __timer: Timer = null


# Lifecycle methods

func _ready() -> void:
	self.__timer = Timer.new()
	self.__timer.one_shot = true
	self.__timer.wait_time = 5.0

	$sprite.position.y = 1038

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
	self.__animation.play("fly")


func land(position: Vector2) -> void:
	self._active = true

	self.position = position
	self.__animation.play_backwards("fly")

	yield(self.__animation, "animation_finished")

	self.__animation.play("idle")
