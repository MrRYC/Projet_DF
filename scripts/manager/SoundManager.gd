extends Node

#variables du script
var bg_music_dir: String = "res://assets/audio/background/" # dossier des background soundtracks
var allowed_extensions: PackedStringArray = ["ogg", "wav", "mp3"] #formats audio autorisés
var gap_seconds: float = 1.0 #intervalle d'attente entre les chansons
var audio_bus: StringName = &"Music" #nom de référence du bus à utiliser
var bg_music_player: AudioStreamPlayer #nom du background music player
var tracks: Array[String] = []          # tableau des background soundtracks
var playlist: Array[String] = []        # copie shuffle
var last_played: String = ""
var is_playlist_ended: bool = false

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	bg_music_player = AudioStreamPlayer.new()
	bg_music_player.bus = audio_bus
	add_child(bg_music_player)

	bg_music_player.finished.connect(_on_track_finished)

	load_and_start()

func reloadtracks() -> void:
	tracks.clear()

	var dir := DirAccess.open(bg_music_dir)
	if dir == null:
		push_warning("MusicManager: Dossier introuvable: %s" % bg_music_dir)
		return

	dir.list_dir_begin()
	while true:
		var file := dir.get_next()
		if file == "":
			break
		if dir.current_is_dir():
			continue

		var ext := file.get_extension().to_lower()
		if allowed_extensions.has(ext):
			tracks.append(bg_music_dir.path_join(file))
	dir.list_dir_end()

	if tracks.is_empty():
		push_warning("MusicManager: aucune track trouvée dans %s" % bg_music_dir)
		return

	buildplaylist()

func buildplaylist() -> void:
	is_playlist_ended = false
	playlist = tracks.duplicate()
	playlist.shuffle()

	# Évite que la 1ère de la nouvelle playlist soit identique à la dernière jouée
	if playlist.size() >= 2 and playlist[0] == last_played:
		var tmp := playlist[0]
		playlist[0] = playlist[1]
		playlist[1] = tmp

func play_random() -> void:
	# Si playlist vide -> on reshuffle
	if playlist.is_empty():
		buildplaylist()

	if playlist.size() == 1:
		is_playlist_ended = true
		

	var next_path: String = playlist.pop_front()
	play_path(next_path)

func play_path(path: String):
	var stream := ResourceLoader.load(path)
	if stream == null:
		push_warning("MusicManager: impossible de charger: %s" % path)
		play_random()
		return

	var audio_stream := stream as AudioStream
	if audio_stream == null:
		push_warning("MusicManager: ressource pas un AudioStream: %s" % path)
		play_random()
		return

	last_played = path
	bg_music_player.stream = stream
	bg_music_player.play()
	
	EventBus.track_played.emit(track_name(path))

func track_name(path: String) -> String:
	var file := path.get_file()
	return file.get_basename()  

func stop() -> void:
	bg_music_player.stop()

func load_and_start() -> void:
	reloadtracks()
	stop()
	play_random()

#
#func set_volume_db(db: float) -> void:
	#bg_music_player.volume_db = db

###########################################################################
#                          SIGNALS INTERCEPTION                           #
###########################################################################

func _on_track_finished() -> void:
	if gap_seconds > 0.0:
		await get_tree().create_timer(gap_seconds).timeout
	
	if is_playlist_ended :
		load_and_start()
	else:
		play_random()
