class_name Pool extends Node

@export var target_scene : PackedScene
@export var spawn_count_initial : int = 200
@export var spawn_count_maximum : int = 400
@export var ignore_process_mode : bool = false
@export var spawn_where : NodePath
@export var pool_name : String = 'Pool'
@export var manual_spawn : bool = false

@export_category('internals')
@export var pool_available : Array = []
@export var pool_used : Dictionary = {}
@export var pool_total : int = 0
@export var pool_container : Node

func _ready() -> void:
	if Engine.is_editor_hint(): return

	var where : Node
	if spawn_where and not spawn_where.is_empty():
		where = get_tree().current_scene.get_node(spawn_where)
	if not where:
		where = get_tree().get_first_node_in_group('game_layer')
	if not where:
		push_error('invalid selector (spawn_where) for where to spawn the pool')
		return

	pool_container = Node.new()
	pool_container.name = pool_name
	where.add_child.call_deferred(pool_container)

	if not manual_spawn:
		spawn_fill_initial_count()

func spawn_fill_initial_count() -> void:
	for i in spawn_count_initial:
		spawn_pooled_node_in_pool(str(i))

func _exit_tree() -> void:
	if pool_container and not pool_container.is_queued_for_deletion():
		pool_container.queue_free()
		pool_container = null

func spawn_pooled_node_in_pool(key:String) -> Node:
	if not target_scene:
		push_error('missing target scene for pool')
		return null

	var node := target_scene.instantiate()
	key_to_meta(node, key)

	if node and node.has_method('set_pool'):
		node.set_pool(self)
	elif node and 'pool' in node:
		node.pool = self

	return_to_pool(node)
	return node

func take_from_pool() -> Node:
	if not pool_available or pool_available.is_empty():
		if pool_total < spawn_count_maximum:
			pass
		else:
			push_error('pool has no more elements')
			return null

	var value = pool_available.pop_back()

	if value:
		pool_used[key_from_meta(value)] = value

		if value.has_method('on_before_take_from_pool'):
			value.on_before_take_from_pool()

		if not ignore_process_mode:
			value.process_mode = PROCESS_MODE_PAUSABLE

		if value.has_method('on_after_take_from_pool'):
			value.on_after_take_from_pool()

	return value

func return_to_pool(pooled_node:Node, ignore_used:bool=false):
	if not pooled_node:
		push_error('pooled_node is invalid')
		return

	if pooled_node.has_method('on_before_return_to_pool'):
		pooled_node.on_before_return_to_pool()

	pooled_node.process_mode = PROCESS_MODE_DISABLED
	pooled_node.hide()

	var key = key_from_meta(pooled_node)
	if not ignore_used:
		var value = pool_used[key]
		if not value:
			push_error('trying to return invalid node to the pool')
		pool_used[key] = null

	if pooled_node.has_method('on_after_return_to_pool'):
		pooled_node.on_after_return_to_pool()

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

const POOLED_NODE_META_KEY : String = 'pooled_node_meta_key'
