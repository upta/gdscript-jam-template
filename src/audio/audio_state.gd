class_name AudioState
extends Node

signal volume_changed(bus: String, value: float)

@onready var config: Config = Provider.inject(self, Config)

var bus_values: Dictionary[String, float]

var music_player := AudioStreamPlayer.new()

var sfx_available_players: Array[AudioStreamPlayer] = []
var sfx_active_players: Array[AudioStreamPlayer] = []
var sfx_pool_size: int


@warning_ignore("shadowed_variable")
func _init(sfx_spool_size: int = 10):
	self.sfx_pool_size = sfx_spool_size
	self.bus_values = bus_values

	music_player.bus = "Music"
	
	add_child(music_player)


func _ready():
	bus_values = {
		"Master": config.get_value("AudioState", "Master", 1.0),
		"Music": config.get_value("AudioState", "Music", 1.0),
		"Sfx": config.get_value("AudioState", "Sfx", 1.0),
	}

	for bus in bus_values:
		set_volume(bus, bus_values[bus])
	
	for i in sfx_pool_size:
		var player = AudioStreamPlayer.new()
		player.bus = "Sfx"

		add_child(player)

		sfx_available_players.append(player)
		player.finished.connect(_on_audio_finished.bind(player))


func get_available_player() -> AudioStreamPlayer:
	if sfx_available_players.is_empty():
		return null

	var player = sfx_available_players.pop_back()
	sfx_active_players.append(player)
	return player


func set_volume(bus: String, value: float):
	var index = AudioServer.get_bus_index(bus)
	var volumne = linear_to_db(value)

	AudioServer.set_bus_volume_db(index, volumne)

	bus_values[bus] = value
	
	config.set_value("AudioState", bus, value)

	volume_changed.emit(bus, value)


func _on_audio_finished(player: AudioStreamPlayer):
	sfx_active_players.erase(player)
	sfx_available_players.append(player)
