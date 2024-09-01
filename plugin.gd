@tool
extends EditorPlugin

func _enter_tree() -> void:
	print_verbose('=> activating lib')

func _exit_tree() -> void:
	print_verbose('=> deactivating lib')
