extends Node


var __volume_max: Dictionary = {
	# key: bus name
	# value: starting volume
}
var __volume_min: float = -40.0

onready var __music: AudioStreamPlayer = $music
onready var __sound_effect: AudioStreamPlayer = $sound_effect

var __audio_pack: AudioPack = null

var __music_fade_tween: Tween = null


# Lifecylce methods
func _ready() -> void:
	var levels = SettingsManager.get_setting("volume", {})
	for key in levels.keys():
		var index = self.__get_bus_index(key)
		self.__volume_max[key] = AudioServer.get_bus_volume_db(index)
		var value: float = linear2db( levels[key]) #lerp(self.__volume_min, self.__volume_max[key], levels[key])
		AudioServer.set_bus_volume_db(index, value)

	self.__music_fade_tween = Tween.new()
	self.call_deferred("add_child", self.__music_fade_tween)


# Public methods
func get_volume(name: String) -> float:
	return SettingsManager.get_setting("volume/%s" % name, 1.0)


func get_volume_db(name: String) -> float:
	var volume: float = self.get_volume(name)
	return lerp(self.__volume_min, self.__volume_max[name], volume)


func set_volume(name: String, value: float) -> void:
	var index: int = self.__get_bus_index(name)

	var volume_db: float = -INF
	if value > 0.0:

		volume_db = linear2db(value)# lerp(self.__volume_min, self.__volume_max[name], value)
	AudioServer.set_bus_volume_db(index, volume_db)

	SettingsManager.set_setting("volume/%s" % name, value, true)


func set_audio_pack(pack: AudioPack) -> void:
	self.__audio_pack = pack


func play_music(name: String, fade: bool = true) -> void:
	if self.__audio_pack == null:
		return

	var track: AudioStream = self.__audio_pack.get_track(name)
	if track == null:
		return

	if self.__music.stream == track:
		return

	if fade && self.__music.stream:
		self.__music_fade_tween.interpolate_property(
			self.__music,
			"volume_db",
			0.0,
			-80.0,
			0.5,
			Tween.TRANS_LINEAR
		)
		self.__music_fade_tween.start()

		yield(self.__music_fade_tween, "tween_all_completed")


	self.__music.stream = track
	self.__music.play()
	self.__music.volume_db = 0.0


func play_sound_effect(name: String) -> void:
	if self.__audio_pack == null:
		return

	var effect: AudioStream = self.__audio_pack.get_sound_effect(name)
	if effect == null:
		return

	if self.__sound_effect == effect:
		return

	self.__sound_effect.stream = effect
	self.__sound_effect.play()


# Private methods

func __get_bus_index(name: String) -> int:
	return AudioServer.get_bus_index(name)
