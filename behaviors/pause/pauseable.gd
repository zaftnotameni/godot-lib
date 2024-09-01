class_name BehaviorPauseable extends Node

## pause screen scene
@export var scene : PackedScene

@export_category('optional')
@export var target : Node
@export var menu_layer_group : StringName = 'menu_layer'

func _enter_tree() -> void:
	if Engine.is_editor_hint(): return
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS
	if not target: target = get_parent()
	target.process_mode = Node.PROCESS_MODE_PAUSABLE

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('pause'):
		get_viewport().set_input_as_handled()
		set_process_unhandled_input(false)
		on_pause()

func on_pause():
	get_tree().paused = true
	var pause_screen := scene.instantiate() if scene else null
	var menu_layer := get_tree().get_first_node_in_group(menu_layer_group) if menu_layer_group and not menu_layer_group.is_empty() else null

	var tween := TweenUtil.tween_unpauseable_eased()

	if pause_screen:
		if menu_layer:
			menu_layer.add_child(pause_screen)
		else:
			owner.add_sibling(pause_screen)

		tween.parallel().tween_property(pause_screen, ^'position:y', 0, 0.3).from(get_viewport().get_visible_rect().size.y)
		pause_screen.tree_exited.connect(on_unpaused)

func on_unpaused():
	if is_queued_for_deletion(): return
	get_tree().paused = false
	set_process_unhandled_input(true)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	if not scene: push_error('missing scene on %s' % get_path())
