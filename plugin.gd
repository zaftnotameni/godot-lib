@tool
extends EditorPlugin

var globals : Dictionary = {
	'__config': './config/autoload.tscn',
	'__state': './state/autoload.tscn',
	'__audio': './audio/autoload.tscn',
	'__layers': './layers/autoload.tscn',
}

func _enter_tree() -> void:
	print_verbose('=> activating lib')
	for key in globals.keys():
		add_autoload_singleton(key, globals[key])

func _exit_tree() -> void:
	print_verbose('=> deactivating lib')
	for key in globals.keys():
		remove_autoload_singleton(key)
