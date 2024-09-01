class_name ConfigScene extends Node2D

const GROUP := 'autoload_config'

static var viewport_width : int = ProjectSettings.get_setting('display/window/size/viewport_width', 1366)
static var viewport_height : int = ProjectSettings.get_setting('display/window/size/viewport_height', 768)

static func tree() -> SceneTree: return Engine.get_main_loop()
static func first() -> ConfigScene: return tree().get_first_node_in_group(GROUP)
static func all() -> Array: return tree().get_nodes_in_group(GROUP)

static var settings : ConfigFile = ConfigFile.new()

static func _static_init() -> void:
	SmartConfig.load_config(settings)
	print_verbose('loading config:\n%s' % settings.encode_to_text())

static func save_settings() -> void:
	print_verbose('saving config:\n%s' % settings.encode_to_text())
	SmartConfig.save_config(settings)

static func get_player_name() -> String:
	return settings.get_value('player', 'name', '')

static func set_player_name(player_name:String) -> String:
	if not player_name or player_name.is_empty(): return player_name
	settings.set_value('player', 'name', player_name)
	save_settings()
	return player_name

static func get_last_victory_time() -> float:
	return settings.get_value('player', 'last_victory_time', -1.0)

static func set_last_victory_time(time:float) -> float:
	if time < 10: return time
	settings.set_value('player', 'last_victory_time', time)
	save_settings()
	return time

static func get_last_victory_score() -> int:
	return settings.get_value('player', 'last_victory_score', -1)

static func set_last_victory_score(score:float) -> int:
	if score < 1: return score
	settings.set_value('player', 'last_victory_score', score)
	save_settings()
	return score

static func get_player_has_victory() -> bool:
	return settings.get_value('player', 'has_victory', false)

static func set_player_has_victory(has_victory:bool) -> bool:
	settings.set_value('player', 'has_victory', has_victory)
	save_settings()
	return has_victory
