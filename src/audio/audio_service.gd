class_name AudioService
extends Node

@onready var state: AudioState = Provider.inject(self, AudioState)


func play_sfx(audio_stream: AudioStream):
	var player := state.get_available_player()

	if player == null:
		push_warning("No audio player available")
		return

	player.stream = audio_stream
	player.play()


func play_music(audio_stream: AudioStream):
	state.music_player.stream = audio_stream
	state.music_player.play()


func get_volume(bus: String) -> float:
	if not state.bus_values.has(bus):
		push_error("Bus '%s' not found" % bus)
		return 0.0

	return state.bus_values[bus]


func set_volume(bus: String, value: float):
	if not state.bus_values.has(bus):
		push_error("Bus '%s' not found" % bus)
		return

	state.set_volume(bus, value)
