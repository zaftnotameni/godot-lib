class_name StateScene extends Node

const GROUP := 'autoload_state'

signal sig_game_state_changed(new_state:GameState, prev_state:GameState)
signal sig_game_state_game()
signal sig_game_state_victory()
signal sig_game_state_initial()
signal sig_transition_finished()
signal sig_transition_started()
signal sig_score_changed()
signal sig_player_ready()
signal sig_player_enter()
signal sig_player_exit()

enum GameState { INITIAL = 0, LOADING, TITLE, MENU, CUTSCENE, GAME, PAUSED, VICTORY, DEFEAT }

static var current_time : float = -1.0
static var victory_time : float = -1.0
static var current_score : int = -1
static var victory_score : int = -1
static var game_state : GameState = GameState.INITIAL
static var game_state_stack : Array[GameState] = [GameState.INITIAL]
static var transition : bool = false

static func is_initial() -> bool: return game_state == GameState.INITIAL
static func is_loading() -> bool: return game_state == GameState.LOADING
static func is_title() -> bool: return game_state == GameState.TITLE
static func is_menu() -> bool: return game_state == GameState.MENU
static func is_cutscene() -> bool: return game_state == GameState.CUTSCENE
static func is_game() -> bool: return game_state == GameState.GAME
static func is_paused() -> bool: return game_state == GameState.PAUSED
static func is_victory() -> bool: return game_state == GameState.VICTORY
static func is_defeat() -> bool: return game_state == GameState.DEFEAT

static func transition_start():
	print_verbose('started transition')
	transition = true
	var state := StateScene.first()
	if state:
		state.sig_transition_started.emit()

static func transition_finish():
	print_verbose('finished transition')
	transition = false
	var state := StateScene.first()
	if state:
		state.sig_transition_finished.emit()

static func mark_as_initial(): mark_as(GameState.INITIAL)
static func mark_as_loading(): mark_as(GameState.LOADING)
static func mark_as_title(): mark_as(GameState.TITLE)
static func mark_as_game(): mark_as(GameState.GAME)
static func mark_as_paused(): mark_as(GameState.PAUSED)
static func mark_as_cutscene(): mark_as(GameState.CUTSCENE)
static func mark_as_victory(): mark_as(GameState.VICTORY)
static func mark_as_defeat(): mark_as(GameState.DEFEAT)
static func mark_as_menu(): mark_as(GameState.MENU)

static func push_initial(): push_as(GameState.INITIAL)
static func push_loading(): push_as(GameState.LOADING)
static func push_title(): push_as(GameState.TITLE)
static func push_game(): push_as(GameState.GAME)
static func push_paused(): push_as(GameState.PAUSED)
static func push_cutscene(): push_as(GameState.CUTSCENE)
static func push_victory(): push_as(GameState.VICTORY)
static func push_defeat(): push_as(GameState.DEFEAT)
static func push_menu(): push_as(GameState.MENU)

static func pop_initial(): pop_as(GameState.INITIAL)
static func pop_loading(): pop_as(GameState.LOADING)
static func pop_title(): pop_as(GameState.TITLE)
static func pop_game(): pop_as(GameState.GAME)
static func pop_paused(): pop_as(GameState.PAUSED)
static func pop_cutscene(): pop_as(GameState.CUTSCENE)
static func pop_victory(): pop_as(GameState.VICTORY)
static func pop_defeat(): pop_as(GameState.DEFEAT)
static func pop_menu(): pop_as(GameState.MENU)

static func pop_as(expected_current_state:GameState):
	if expected_current_state != game_state: return
	var prev_state := game_state
	game_state_stack.pop_back()
	if game_state_stack.is_empty(): game_state_stack.push_back(GameState.INITIAL)
	game_state = game_state_stack[-1]
	react_to_game_state_changed(prev_state)

static func push_as(new_state:GameState):
	if new_state == game_state: return
	var prev_state := game_state
	game_state = new_state
	game_state_stack.push_back(new_state)
	react_to_game_state_changed(prev_state)

static func mark_as(new_state:GameState):
	if new_state == game_state: return
	var prev_state := game_state
	game_state = new_state
	game_state_stack = [new_state]
	react_to_game_state_changed(prev_state)

static func react_to_game_state_changed(prev_state:GameState):
	print_verbose('game_state: %s' % str(game_state_stack.map(name_of)))
	var state := StateScene.first()
	if state:
		state.sig_game_state_changed.emit(game_state, prev_state)
		if game_state == GameState.INITIAL: state.sig_game_state_initial.emit()
		if game_state == GameState.VICTORY: state.sig_game_state_victory.emit()
		if game_state == GameState.GAME: state.sig_game_state_game.emit()
	if game_state == GameState.GAME: soft_reset_time()
	if game_state == GameState.TITLE: reset_victory_time()
	if game_state == GameState.GAME: soft_reset_score()
	if game_state == GameState.TITLE: reset_victory_score()
	if game_state == GameState.VICTORY: promote_current_time_to_victory_time()
	if game_state == GameState.VICTORY: promote_current_score_to_victory_score()

static func name_of(state_id:GameState) -> String:
	return GameState.find_key(state_id)

func _enter_tree() -> void:
	add_to_group(GROUP)
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if game_state == GameState.GAME: current_time += delta

static func promote_current_score_to_victory_score():
	victory_score = current_score if current_score > 1 else victory_score
	if victory_score > 1:
		ConfigScene.set_last_victory_score(victory_score)

static func promote_current_time_to_victory_time():
	victory_time = current_time if current_time > 10 else victory_time
	if victory_time > 10:
		ConfigScene.set_last_victory_time(victory_time)

static func reset_victory_score():
	victory_score = -1

static func reset_victory_time():
	victory_time = -1.0

static func soft_reset_time():
	current_time = current_time if current_time >= 0.0 else 0.0

static func soft_reset_score():
	current_score = current_score if current_score >= 0 else 0

static func reset_time():
	current_time = -1.0

static func reset_score():
	current_score = -1

static func update_score(score:int=0):
	current_score = score
	var state := StateScene.first()
	if state:
		state.sig_score_changed.emit()

static func add_score(score:int=0):
	current_score += score
	var state := StateScene.first()
	if state:
		state.sig_score_changed.emit()

static func remove_score(score:int=0):
	current_score -= score
	var state := StateScene.first()
	if state:
		state.sig_score_changed.emit()

static func tree() -> SceneTree: return Engine.get_main_loop()
static func first() -> StateScene: return tree().get_first_node_in_group(GROUP)
static func all() -> Array: return tree().get_nodes_in_group(GROUP)
