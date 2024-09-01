class_name InGameState extends Node

@export_enum('INITIAL', 'LOADING', 'TITLE', 'MENU', 'CUTSCENE', 'GAME', 'PAUSED', 'VICTORY', 'DEFEAT') var state : String
@export var wipe_state_stack : bool = false
@export var pops_on_exit : bool = false

func target_state() -> StateScene.GameState: return StateScene.GameState[state]

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS

func _exit_tree() -> void:
	if pops_on_exit:
		StateScene.pop_as(target_state())

func _ready() -> void:
	if wipe_state_stack:
		StateScene.mark_as(target_state())
	else:
		StateScene.push_as(target_state())
