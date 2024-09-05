class_name AtLayer extends Node2D

@export var scene : PackedScene
@export var named : String
@export_enum('game_layer', 'background_layer', 'hud_layer', 'menu_layer', 'popup_layer', 'overlay_layer') var layer : String

func _enter_tree() -> void:
	if Engine.is_editor_hint(): return
	if not scene: push_error('must provide a scene'); return

	var node := scene.instantiate()
	node.set('global_position', global_position)
	if named and not named.is_empty():
		node.name = named
	else:
		node.name = ('at_layer_%s_%s' % [layer, node.name]).to_pascal_case()
	at_layer.call_deferred(node, layer)

static func at_layer(node:Node, layer_name:String='game') -> Node:
	if Engine.is_editor_hint(): return node

	if not node: push_error('must provide a node'); return
	if not layer_name or layer_name.is_empty(): push_error('must provide a layer'); return node

	var layer_container := tree().get_first_node_in_group(layer_name)
	if not layer_container: push_error('no layer with group %s' % layer_name); return node

	layer_container.add_child(node)
	return node

static func at_background(node:Node): at_layer(node, 'background_layer')
static func at_game(node:Node): at_layer(node, 'game_layer')
static func at_menu(node:Node): at_layer(node, 'menu_layer')
static func at_popup(node:Node): at_layer(node, 'popup_layer')
static func at_overlay(node:Node): at_layer(node, 'overlay_layer')
static func at_hud(node:Node): at_layer(node, 'hud_layer')

static func tree() -> SceneTree: return Engine.get_main_loop()
