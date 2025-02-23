class_name AudioManagerSingleton extends Node

enum Tracks {
}

const TRACKS_PATH = "res://assets/sound/music/"
var track_paths: Dictionary = {

}
var tracks: Dictionary = {}

const SFX_PATH = "res://assets/sound/sfx/"
var sfx_paths: Dictionary = {
}
var sound_effects: Dictionary = {}


@onready var bg_player: AudioStreamPlayer = $background_music
@onready var sfx_bank: Node = $sfx_bank

var sfx_players: Array[AudioStreamPlayer] = []

var replay_track: bool = false


func _init():
	var dir = DirAccess.open(TRACKS_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var extension = file_name.get_extension().to_lower()
				assert(extension in ["mp3", "wav", "ogg"], "Invalid audio file extension for " + file_name)
				var track_name = file_name.get_basename()
				track_paths[track_name] = TRACKS_PATH + file_name
			file_name = dir.get_next()
	
	dir = DirAccess.open(SFX_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var extension = file_name.get_extension().to_lower()
				assert(extension in ["mp3", "wav", "ogg"], "Invalid audio file extension for" + file_name)
				var sfx_name = file_name.get_basename()
				sfx_paths[sfx_name] = SFX_PATH + file_name
			file_name = dir.get_next()


func _ready():
	for track in track_paths:
		tracks[track] = load(track_paths[track])
	for sfx in sfx_paths:
		sound_effects[sfx] = load(sfx_paths[sfx])

	for child in sfx_bank.get_children():
		if child is AudioStreamPlayer:
			sfx_players.append(child)


func play_track(track: Tracks, replay: bool = false):
	if bg_player.playing:
		bg_player.stop()
	
	bg_player.stream = tracks[track]
	replay_track = replay
	bg_player.play()


func _on_background_music_finished():
	if replay_track:
		bg_player.play()

func play_sfx(sound: String):
	for player in sfx_players:
		if not player.playing:
			player.stream = sound_effects[sound]
			player.play()
			break
