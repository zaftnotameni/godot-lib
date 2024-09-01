class_name TreeUtil extends RefCounted

static func scene_tree() -> SceneTree: return Engine.get_main_loop()
static func current_scene() -> Node: return Engine.get_main_loop().current_scene

static func first_in_group(group:='group_name', ignore_missing:=false) -> Node:
	var node := scene_tree().get_first_node_in_group(group)
	if not node and not ignore_missing: push_error('missing node with group %s' % group)
	return node

static func all_in_group(group:='group_name', ignore_missing:=false) -> Array:
	var nodes := scene_tree().get_nodes_in_group(group)
	if (not nodes or nodes.is_empty()) and not ignore_missing: push_error('missing nodes with group %s' % group)
	return nodes

static func tree_wait_for_ready(node:Node) -> Node:
	if node.is_node_ready(): return node
	await node.ready
	return node

static func tree_node_at_root(node:Node) -> Node:
	var scn : Node = scene_tree().root
	if node.is_inside_tree(): return node
	if node.has_meta('singleton_instance_setup') and node.get_meta('singleton_instance_setup'): return node
	node.set_meta('singleton_instance_setup', true)
	var script:Script = node.get_script()
	if script and script.get_global_name(): node.name = script.get_global_name()
	scn.add_child.call_deferred(node)
	return node

static func singleton(TypeScript:Script) -> Node:
	var existing = TypeScript['_instance']; if existing: return existing
	var instance = TypeScript.new(); TypeScript['_instance'] = instance
	return tree_node_at_root(instance)
