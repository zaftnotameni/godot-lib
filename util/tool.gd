@tool
class_name ToolUtil extends Node

@export var tooled : bool = true : set = setter_for_tooled
@export var target : Node

func setter_for_tooled(v:bool):
	if not Engine.is_editor_hint(): return
	if v: return
	if not v and target.has_method('on_tooled'):
		target.on_tooled()
	tooled = true

func _enter_tree() -> void:
	if not Engine.is_editor_hint(): return
	if not target: target = get_parent()

static func set_tooled(node:Node, v):
	if v: return
	if not v and node.has_method('on_tooled'):
		node.on_tooled()
	node.set('tooled', true)

static func is_owned_by_edited_scene(node:Node) -> bool:
	if not Engine.is_editor_hint(): return false
	if not node: return false
	if not node.get_tree(): return false
	if not node.get_tree().edited_scene_root: return false
	if not node.owner: return false
	if node.get_tree().edited_scene_root == node.owner: return true
	return false

static func is_root_of_edited_scene(node:Node) -> bool:
	if not Engine.is_editor_hint(): return false
	if not node: return false
	if not node.get_tree(): return false
	if not node.get_tree().edited_scene_root: return false
	if not node.owner: return false
	if node.get_tree().edited_scene_root == node: return true
	return false

static func tool_add_child(parent:Node, child:Node):
	if not Engine.is_editor_hint(): return false
	parent.add_child.call_deferred(child)
	await child.ready
	child.set_meta('created_via_tool_script', true)
	child.owner = parent.get_tree().edited_scene_root

static func remove_all_children_created_via_tool_from(node:Node):
	if not Engine.is_editor_hint(): return false
	for child:Node in node.get_children():
		if not child.get_meta('created_via_tool_script', false): continue
		printt('tool removing child', child, child.name)
		child.queue_free()
		await child.tree_exited

static func remove_all_children_dangerously_from(node:Node):
	if not Engine.is_editor_hint(): return false
	for child:Node in node.get_children():
		child.queue_free()
		await child.tree_exited
