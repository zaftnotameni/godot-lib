class_name AudioScene extends Node2D

const GROUP := 'autoload_audio'

enum AudioBus { Any = -1, Master = 0, BGM = 1, SFX = 2, UI = 3 }

signal sig_named_song_start_requested(named_song:String)
signal sig_named_song_stop_requested(named_song:String)
signal sig_volume_changed(which_bus:AudioBus, volume_linear_0_100:float)

@onready var master_test : AudioStreamPlayer = $Master/Test
@onready var bgm_test : AudioStreamPlayer = $BGM/Test
@onready var sfx_test : AudioStreamPlayer = $SFX/Test
@onready var ui_test : AudioStreamPlayer = $UI/Test
@onready var ui_focus : AudioStreamPlayer = $UI/Focus
@onready var ui_press : AudioStreamPlayer = $UI/Press

static var ignore = {}
static var playing = {}

static func play_master(player:AudioStreamPlayer, only_if_not_playing:bool=true): return play_stream(player, AudioBus.Master, only_if_not_playing)
static func play_bgm(player:AudioStreamPlayer, only_if_not_playing:bool=true): return play_stream(player, AudioBus.BGM, only_if_not_playing)
static func play_sfx(player:AudioStreamPlayer, only_if_not_playing:bool=true): return play_stream(player, AudioBus.SFX, only_if_not_playing)
static func play_ui(player:AudioStreamPlayer, only_if_not_playing:bool=true): return play_stream(player, AudioBus.UI, only_if_not_playing)

static func play_stream(player:AudioStreamPlayer, bus:AudioBus=AudioBus.Any, only_if_not_playing:bool=true):
	if not player: return
	if not player.stream: return
	if player.playing and only_if_not_playing: return

	var id := id_of(player)
	if ignore.get_or_add(id, 0) < 0: ignore[id] = 0
	if ignore.get_or_add(id, 0) > 0: ignore[id] = ignore.get_or_add(id, 0) - 1
	if ignore.get_or_add(id, 0) > 0: print_verbose('ignored: ' + id); return
	
	if bus != AudioBus.Any: player.bus = AudioBus.find_key(bus)

	if player.bus == AudioBus.find_key(AudioBus.BGM):
		if player.name != 'TestSound':
			player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
			player.set('parameters/looping', true)

	print_verbose('play [%s] (%s)' % [player.name, id])
	player.play()

func ignore_next(player:AudioStreamPlayer, how_many:int=1):
	if not player: return
	if not player.stream: return

	var id := id_of(player)
	ignore[id] = ignore.get_or_add(id, 0) + how_many

static func id_of(player:AudioStreamPlayer) -> String: return '%s__%s' % [player.bus, player.stream.resource_path]

static func from_config_to_audio_server():
	if Engine.is_editor_hint(): return
	set_volume_linear_0_100(AudioBus.Master, ConfigScene.settings.get_value('audio', 'audio_master_volume_linear_0_100', 50.0), null, null, true)
	set_volume_linear_0_100(AudioBus.BGM, ConfigScene.settings.get_value('audio', 'audio_bgm_volume_linear_0_100', 50.0), null, null, true)
	set_volume_linear_0_100(AudioBus.SFX, ConfigScene.settings.get_value('audio', 'audio_sfx_volume_linear_0_100', 50.0), null, null, true)
	set_volume_linear_0_100(AudioBus.UI, ConfigScene.settings.get_value('audio', 'audio_ui_volume_linear_0_100', 50.0), null, null, true)

static func from_audio_server_to_config():
	if Engine.is_editor_hint(): return
	ConfigScene.settings.set_value('audio', 'audio_master_volume_linear_0_100', get_volume_linear_0_100(AudioBus.Master))
	ConfigScene.settings.set_value('audio', 'audio_bgm_volume_linear_0_100', get_volume_linear_0_100(AudioBus.BGM))
	ConfigScene.settings.set_value('audio', 'audio_sfx_volume_linear_0_100', get_volume_linear_0_100(AudioBus.SFX))
	ConfigScene.settings.set_value('audio', 'audio_ui_volume_linear_0_100', get_volume_linear_0_100(AudioBus.UI))
	ConfigScene.save_settings()

func _enter_tree() -> void:
	add_to_group(GROUP)
	from_config_to_audio_server()

static func update_ui(volume_linear_0_100:float, slider:Slider=null, label:Label=null):
	if slider: slider.value = volume_linear_0_100
	if label: label.text = str(roundi(volume_linear_0_100)) + '%'

static func set_volume_linear_0_100(which_bus:AudioBus, volume_linear_0_100:float, slider:Slider=null, label:Label=null, skip_update_from_audio_server:=false):
	AudioServer.set_bus_volume_db(which_bus, linear_to_db(volume_linear_0_100 / 100.0))
	update_ui(volume_linear_0_100, slider, label)
	if not skip_update_from_audio_server: from_audio_server_to_config()
	var audio := AudioScene.first()
	if audio: audio.sig_volume_changed.emit(which_bus, volume_linear_0_100)

static func get_volume_linear_0_100(which_bus:AudioBus, slider:Slider=null, label:Label=null) -> float:
	var volume_db := AudioServer.get_bus_volume_db(which_bus)
	var volume_linear_0_100 : float = db_to_linear(volume_db) * 100.0
	update_ui(volume_linear_0_100, slider, label)
	return volume_linear_0_100

static func play_volume_tick_sound(which_bus:AudioBus):
	var audio := AudioScene.first()
	if not audio: return
	match which_bus:
		AudioBus.Master: play_master(audio.ui_test_sound)
		AudioBus.BGM: play_bgm(audio.bgm_test_sound)
		AudioBus.SFX: play_sfx(audio.sfx_test_sound)
		AudioBus.UI: play_ui(audio.ui_test_sound)

static func tree() -> SceneTree: return Engine.get_main_loop()
static func first() -> AudioScene: return tree().get_first_node_in_group(GROUP)
static func all() -> Array: return tree().get_nodes_in_group(GROUP)
