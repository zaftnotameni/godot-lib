class_name Resolve extends RefCounted

const DEFAULT_COMPONENT_LOCATION := ^'Components'

static func matches_type(node:Node,typ:Script) -> bool:
	var s := node.get_script() as Script
	if not s: return false
	return s == typ

static func resolve_from(node:Node,typ:Script,selector:NodePath=DEFAULT_COMPONENT_LOCATION,ignore_missing:=false) -> Node:
	assert(node, 'must provide a node')
	assert(node.is_inside_tree(), 'node must be in the tree')
	assert(node.has_node(selector), '%s must have a %s node' % [node.get_path(), selector])
	return resolve_at(node.get_node(selector), typ, ignore_missing)

static func resolve_meta_from(node:Node,meta_key:String,meta_value:Variant,selector:NodePath=DEFAULT_COMPONENT_LOCATION,ignore_missing:=false) -> Node:
	assert(node, 'must provide a node')
	assert(node.is_inside_tree(), 'node must be in the tree')
	assert(node.has_node(selector), '%s must have a %s node' % [node.get_path(), selector])
	return resolve_meta_at(node.get_node(selector), meta_key, meta_value, ignore_missing)

static func resolve_all_at(node:Node,typ:Script,ignore_missing:=false) -> Array[Node]:
	assert(node, 'must provide a node')
	assert(node.is_inside_tree(), 'node must be in the tree')
	var res : Array[Node] = []
	for c in node.get_children():
		if matches_type(c,typ): res.push_back(c)
	if ignore_missing or not res.is_empty():
		return res
	else:
		push_warning('tried to resolve missing component %s at %s' % [typ, node.get_path()])
		return res

static func resolve_meta_at(node:Node,meta_key:String,meta_value:Variant,ignore_missing:=false) -> Node:
	assert(node, 'must provide a node')
	assert(node.is_inside_tree(), 'node must be in the tree')
	for c in node.get_children():
		if c.has_meta(meta_key) and c.get_meta(meta_key) == meta_value: return c
	if ignore_missing:
		return null
	else:
		push_warning('tried to resolve missing component %s:%s at %s' % [meta_key, meta_value, node.get_path()])
		return null

static func resolve_at(node:Node,typ:Script,ignore_missing:=false) -> Node:
	assert(node, 'must provide a node')
	assert(node.is_inside_tree(), 'node must be in the tree')
	for c in node.get_children():
		if matches_type(c,typ): return c
	if ignore_missing:
		return null
	else:
		push_warning('tried to resolve missing component %s at %s' % [typ, node.get_path()])
		return null

