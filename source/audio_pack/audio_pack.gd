class_name AudioPack extends Resource

export(Array, AudioStream) var music_tracks: Array = []
export(Array, AudioStream) var sound_effects: Array = []


func get_track(name: String) -> AudioStream:
	for track in self.music_tracks:
		var track_name: String = Array(track.resource_path.split("/")).pop_back().split(".")[0]
		if track_name == name:
			return track

	return null


func get_sound_effect(name: String)-> AudioStream:
	for effect in self.sound_effects:
		var effect_name: String = Array(effect.resource_path.split("/")).pop_back().split(".")[0]
		if effect_name == name:
			return effect

	return null
