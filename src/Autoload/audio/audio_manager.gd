class_name AudioManagerSingleton extends Node

enum Tracks {
}

const TRACKS_PATH = "res://assets/sound/music/"
const track_paths: Dictionary = {

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
