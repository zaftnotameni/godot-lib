class_name Pool extends Node

signal sig_taken_from_pool(node:Node)
signal sig_returned_to_pool(node:Node)

@export var target_scene : PackedScene
@export var spawn_count_initial : int = 10
@export var spawn_count_maximum : int = 20
@export var ignore_process_mode : bool = false
## where (in the tree) the bullets will spawn, defaults to the game_layer group
@export var spawn_container_path : NodePath
## where (in global position) the bullets will spawn, defaults to the pool owner
@export var spawn_position_path : NodePath
@export var pool_name : String = 'Pool'
@export var manual_spawn : bool = false
@export var auto_show_on_take : bool = false

@export_category('internals')
@export var pool_available : Array = []
@export var pool_used : Dictionary = {}
@export var pool_total : int = 0
@export var pool_container : Node2D
@export var pool_origin : Node2D

func _ready() -> void:
	if Engine.is_editor_hint(): return

	var where : Node
	if spawn_container_path and not spawn_container_path.is_empty():
		if spawn_container_path.is_absolute():
			where = get_tree().current_scene.get_node(spawn_container_path)
		else:
			where = get_node(spawn_container_path)
	if not where:
		where = get_tree().get_first_node_in_group('game_layer')
	if not where:
		push_error('invalid selector (spawn_where) for where to spawn the pool')
		return

	var origin : Node2D
	if spawn_position_path and not spawn_position_path.is_empty():
		if spawn_position_path.is_absolute():
			origin = get_tree().current_scene.get_node(spawn_position_path)
		else:
			origin = get_node(spawn_position_path)
	if not origin:
		origin = owner
	if not origin:
		push_error('invalid selector (spawn_where) for where to spawn the pool')
		return

	pool_origin = origin
	pool_container = Node2D.new()
	pool_container.name = pool_name
	where.add_child.call_deferred(pool_container)

	if not manual_spawn:
		spawn_fill_initial_count()

func spawn_fill_initial_count() -> void:
	for i in spawn_count_initial:
		spawn_pooled_node_in_pool(str(i), true)

func _exit_tree() -> void:
	if pool_container and not pool_container.is_queued_for_deletion():
		pool_container.queue_free()
		pool_container = null

func spawn_pooled_node_in_pool(key:String, ignore_used:bool=false) -> Node:
	if not target_scene:
		push_error('missing target scene for pool')
		return null

	var node := target_scene.instantiate()
	key_to_meta(node, key)

	if node and node.has_method('set_pool'):
		node.set_pool(self)
	elif node and 'pool' in node:
		node.pool = self

	pool_container.add_child(node)
	pool_total += 1

	node.global_position = Vector2.ZERO if not pool_origin else pool_origin.global_position

	if pool_total > spawn_count_maximum:
		push_error('pool has no too many elements total=%s, max=%s' % [pool_total, spawn_count_maximum])

	return_to_pool(node, ignore_used)
	return node

func take_from_pool() -> Node:
	if not pool_available or pool_available.is_empty():
		if pool_total < spawn_count_maximum:
			spawn_pooled_node_in_pool(str(pool_total), true)
		else:
			push_error('pool has no more elements total=%s, max=%s' % [pool_total, spawn_count_maximum])
			return null

	var node_from_pool = pool_available.pop_back()
	if not node_from_pool:
		push_warning('could not get a node from pool')

	if node_from_pool:
		pool_used[key_from_meta(node_from_pool)] = node_from_pool

		if node_from_pool.has_method('on_before_take_from_pool'):
			node_from_pool.on_before_take_from_pool()

		node_from_pool.global_position = Vector2.ZERO if not pool_origin else pool_origin.global_position

		if not ignore_process_mode:
			node_from_pool.set('process_mode', PROCESS_MODE_PAUSABLE)

		if node_from_pool.has_method('on_after_take_from_pool'):
			node_from_pool.on_after_take_from_pool()

		if auto_show_on_take:
			# get_tree().create_timer(0.1).timeout.connect(node_from_pool.show, CONNECT_ONE_SHOT)
			await get_tree().physics_frame
			node_from_pool.show()

		sig_taken_from_pool.emit(node_from_pool)

	return node_from_pool

func return_to_pool(pooled_node:Node, ignore_used:bool=false):
	if not pooled_node:
		push_error('pooled_node is invalid')
		return

	if pooled_node.has_method('on_before_return_to_pool'):
		pooled_node.on_before_return_to_pool()

	pooled_node.hide()
	pooled_node.process_mode = PROCESS_MODE_DISABLED

	var key = key_from_meta(pooled_node)
	if not ignore_used:
		var value = pool_used[key]
		if not value:
			push_error('trying to return invalid node to the pool')
		pool_used[key] = null

	if pooled_node.has_method('on_after_return_to_pool'):
		pooled_node.on_after_return_to_pool()

	pool_available.push_back(pooled_node)

	sig_returned_to_pool.emit(pooled_node)

func key_from_meta(pooled_node:Node) -> String:
	if not pooled_node:
		push_error('pooled_node is invalid')
		return 'INVALID'
	return pooled_node.get_meta(POOLED_NODE_META_KEY, 'MISSING')

func key_to_meta(pooled_node:Node, key:String):
	if not pooled_node:
		push_error('pooled_node is invalid')
		return
	if not key or key.is_empty():
		push_error('key is invalid')
		return

	pooled_node.set_meta(POOLED_NODE_META_KEY, key)

static func from(target_owner:Node) -> Pool:
	return MetaComponentBehavior.resolve_via_component_meta(target_owner, Pool)

const POOLED_NODE_META_KEY : String = 'pooled_node_meta_key'
