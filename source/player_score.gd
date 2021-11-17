class_name PlayerScore extends Control


# Public variables

export(Resource) var player_data: Resource


# Private vairables

onready var __animation: AnimationPlayer = $animation
onready var __sprite_left: TextureRect = $sprite_left
onready var __sprite_right: TextureRect = $sprite_right
onready var __text: Label = $text

var __animation_method: String = "play"


# Lifecylce methods

func _ready() -> void:
	self.__sprite_left.visible = self.player_data.left
	self.__sprite_right.visible = !self.player_data.left

	self.__sprite_left.texture = player_data.player
	self.__sprite_right.texture = player_data.player

	if self.player_data.left:
		self.__animation_method = "play_backwards"


# Public methods

func set_score(score: int) -> void:
	self.__text.text = "%03d" % score
	self.__animation.call(self.__animation_method, "changed")
