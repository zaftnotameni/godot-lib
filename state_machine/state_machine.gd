class_name StateMachine extends Node2D

signal sig_state_will_transition(next:int, curr:int, prev:int)
signal sig_state_did_transition(curr:int, prev:int)

enum MACHINE_MODE { None = 0, Physics, Normal }

@export var machine_mode: MACHINE_MODE

@export_group('internals')
## maps state id -> state name
@export var state_names: Dictionary
## maps state name -> node
@export var state_nodes: Dictionary
@export var state_curr_id: int = -1
@export var state_prev_id: int = -1
@export var state_next_id: int = -1
@export var state_curr: Node
@export var state_prev: Node
@export var state_next: Node

func current_state_name() -> String:
	return state_name_of(state_curr)

func current_state_id() -> int:
	return state_id_of(state_curr)

func previous_state_name() -> String:
	return state_name_of(state_prev)

func previous_state_id() -> int:
	return state_id_of(state_prev)

func state_name_of(n:Node) -> String:
	return n.get_meta('state_name', n.name)

func state_id_of(n:Node) -> int:
	return n.get_meta('state_id', -1000)

func setup(source_enum:Dictionary):
	state_nodes = {}
	state_names = {}
	for key:String in source_enum.keys():
		var node := get_node_or_null(key.to_pascal_case())
		if not node: push_error('missing node matching state: %s' % key)
		node.set_meta('state_id', source_enum[key])
		node.set_meta('state_name', key)
		state_nodes[key] = node
		state_names[source_enum[key]] = key

func start(initial_state_id_or_name:Variant):
	if not state_names: push_error('must provide a state_enum via setup()'); return
	if not state_nodes: push_error('must provide a state_enum via setup()'); return
	if state_names.is_empty(): push_error('must provide a state_enum via setup()'); return
	if state_nodes.is_empty(): push_error('must provide a state_enum via setup()'); return
	state_curr = resolve_state_node(initial_state_id_or_name)
	if not state_curr: push_error('invalid state %s' % initial_state_id_or_name)
	state_curr.set_meta('via_state', 'MACHINE_START')
	state_curr.set_meta('via_transition', 'machine-start')
	state_prev = state_curr
	state_next = state_curr
	enable_processing.call_deferred(state_curr)

func resolve_state_name_by_id(state_id:int) -> String:
	return state_names[state_id]

func resolve_state_name_by_name(state_name:String) -> String:
	return state_name

func resolve_state_name(state_id_or_name:Variant) -> String:
	if state_id_or_name is int:
		return resolve_state_name_by_id(state_id_or_name as int)
	else:
		return resolve_state_name_by_name(state_id_or_name)

func resolve_state_node(state_id_or_name:Variant) -> Node:
	var state_name := resolve_state_name(state_id_or_name)
	return state_nodes[state_name]

func transition(next_state_id_or_name:Variant, transition_name:String='transition-name'):
	state_next = resolve_state_node(next_state_id_or_name)

	setup_next(transition_name)
	sig_state_will_transition.emit(state_next, state_curr, state_prev)

	if state_curr.has_method('on_state_exit'):
		state_curr.on_state_exit(state_next)

	disable_processing(state_curr)
	next_curr_prev()

	if state_curr.has_method('on_state_enter'):
		state_curr.on_state_enter(state_prev)

	enable_processing(state_curr)

	sig_state_did_transition.emit(state_curr, state_prev)

func setup_next(via:='transition-name'):
	state_next.set_meta('via_state', state_curr.get_meta('state_name', state_curr.name))
	state_next.set_meta('via_transition', via)

func next_curr_prev():
	state_prev = state_curr
	state_curr = state_next

func _ready() -> void:
	for c:Node in get_children():
		c.set_meta('preferred_process_mode', c.process_mode)
		disable_processing(c)

func enable_processing(n:Node=self):
	if not n: return
	n.process_mode = n.get_meta('preferred_process_mode', Node.PROCESS_MODE_INHERIT)
	n.set_physics_process(not Engine.is_editor_hint() and machine_mode == MACHINE_MODE.Physics)
	n.set_process(not Engine.is_editor_hint() and machine_mode == MACHINE_MODE.Normal)
	n.set_process_input(true)
	n.set_process_shortcut_input(true)
	n.set_process_unhandled_input(true)
	n.set_process_unhandled_key_input(true)

func disable_processing(n:Node=self):
	if not n: return
	n.process_mode = Node.PROCESS_MODE_DISABLED
	n.set_physics_process(false)
	n.set_process(false)
	n.set_process_input(false)
	n.set_process_shortcut_input(false)
	n.set_process_unhandled_input(false)
	n.set_process_unhandled_key_input(false)
