class_name LayersScene extends Node2D

static func layer_game() -> CanvasLayer: return tree().get_first_node_in_group('game_layer')
static func layer_background() -> CanvasLayer: return tree().get_first_node_in_group('background_layer')
static func layer_hud() -> CanvasLayer: return tree().get_first_node_in_group('hud_layer')
static func layer_menu() -> CanvasLayer: return tree().get_first_node_in_group('menu_layer')
static func layer_popup() -> CanvasLayer: return tree().get_first_node_in_group('popup_layer')
static func layer_overlay() -> CanvasLayer: return tree().get_first_node_in_group('overlay_layer')

static func clear_game(exceptions:Array[Node]=[]): clear_layer(layer_game(), exceptions)
static func clear_background(exceptions:Array[Node]=[]): clear_layer(layer_background(), exceptions)
static func clear_hud(exceptions:Array[Node]=[]): clear_layer(layer_hud(), exceptions)
static func clear_menu(exceptions:Array[Node]=[]): clear_layer(layer_menu(), exceptions)
static func clear_popup(exceptions:Array[Node]=[]): clear_layer(layer_popup(), exceptions)
static func clear_overlay(exceptions:Array[Node]=[]): clear_layer(layer_overlay(), exceptions)

static func all_layers() -> Array[CanvasLayer]: return [
	layer_hud(),
	layer_popup(),
	layer_game(),
	layer_menu(),
	layer_overlay(),
	layer_background()
]

static func clear_layer(layer:CanvasLayer, exceptions:Array[Node]=[]):
	if layer and not layer.is_queued_for_deletion():
		for child in layer.get_children():
			if child and not child.is_queued_for_deletion() and (not exceptions or not exceptions.has(child)):
				child.queue_free()

static func clear_all_layers(exceptions:Array[Node]=[]):
	for layer:CanvasLayer in all_layers():
		clear_layer(layer, exceptions)

func _enter_tree() -> void:
	add_to_group(GROUP)
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS

const GROUP := 'layers_autoload'

static func tree() -> SceneTree: return Engine.get_main_loop()
static func first() -> LayersScene: return tree().get_first_node_in_group(GROUP)
static func all() -> Array: return tree().get_nodes_in_group(GROUP)
