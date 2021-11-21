class_name PickUp extends Node2D


# Protected variables

var _active: bool = false


# Public methods

func collect(player: Player) -> void:
	pass

func is_active() -> bool:
	return self._active
