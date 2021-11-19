extends Control


# Public variables

export(Array, Resource) var player_data: Array = []


# Private methods

onready var __letters: Array = [
	$letter_i,
	$letter_n,
	$letter_v_1,
	$letter_e_1,
	$letter_r_1,
	$letter_t_1,
	$letter_r_2,
	$letter_o,
	$letter_v_2,
	$letter_e_2,
	$letter_r_3,
	$letter_t_2,
]


var __current_player: int = 0


# Public methods

func change_color() -> void:
	self.__current_player = (self.__current_player + 1) % self.player_data.size()

	var color: Color = self.player_data[self.__current_player].color

	for letter in self.__letters:
		letter.set_color(color)
