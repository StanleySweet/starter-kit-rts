class_name CmpSoundManager extends Node

@export_range(1, 64) var max_positional_audio_sources : int
@export_range(1, 64) var max_audio_sources : int
@onready var music_player : AudioStreamPlayer2D = $MusicPlayer3D

var positional_sound_players : Array[AudioStreamPlayer3D] = []
var sound_players : Array[AudioStreamPlayer2D] = []

func _ready() -> void:
	for i in range(0, self.max_positional_audio_sources):
		var sound_player := AudioStreamPlayer3D.new()
		self.add_child(sound_player)
		self.positional_sound_players.push_back(sound_player)

	for i in range(0, self.max_audio_sources):
		var sound_player := AudioStreamPlayer2D.new()
		self.add_child(sound_player)
		self.sound_players.push_back(sound_player)
	

func play_at_position(global_position : Vector3, sound_group : SoundGroup) -> void:
	for player in positional_sound_players:
		if not player.playing:
			var stream : AudioStream = sound_group.sounds[randi_range(0, len(sound_group.sounds) - 1)]
			player.stream = stream
			player.global_position = global_position
			player.play()
			break

func play(sound_group : SoundGroup) -> void:
	for player in sound_players:
		if not player.playing:
			var stream : AudioStream = sound_group.sounds[randi_range(0, len(sound_group.sounds) - 1)]
			player.stream = stream
			player.play()
			break
	
