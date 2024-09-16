class_name MetaComponentBehavior extends Node

## leave blank unless you have multiple of the same type of component
@export var named : String = ''

@export_category('internals')
@export var component : Node
@export var target_root : Node

func _enter_tree() -> void:
	if Engine.is_editor_hint(): return
	ResolveUtil.or_owner(self, 'target_root')
	ResolveUtil.or_parent(self, 'component')
	if not ErrorUtil.all_required(self, ['target_root', 'component']): return
	setup_component_meta()

static func resolve_via_component_meta(the_target_root:Node, script:Script, named:String='') -> Variant:
	var path_to_resolve = the_target_root.get_meta(meta_name_for_script(script, named)) as String
	if path_to_resolve and not path_to_resolve.is_empty():
		var maybe_node = the_target_root.get_node_or_null(path_to_resolve)
		if maybe_node: return maybe_node
	return null

func setup_component_meta() -> void:
	target_root.set_meta(meta_name_for_script(component.get_script()), target_root.get_path_to(component))

static func meta_name_for_script(script:Script, named:String='') -> String:
	if not script: return ''
	if not named or named.is_empty():
		return 'component_%s' % resolve_global_name(script)
	return 'component_%s_%s' % [resolve_global_name(script), named]

static func resolve_global_name(script:Script) -> String:
	if not script: return ''
	return script.get_global_name()
