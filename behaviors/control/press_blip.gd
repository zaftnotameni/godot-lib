class_name BehaviorPressBlip extends Node

@export_group('optional')
@export var control : Control

func on_press():
	var audio := AudioScene.first()
	if not audio: return
	AudioScene.play_ui(audio.ui_focus, false)

func _enter_tree() -> void:
	process_mode = ProcessMode.PROCESS_MODE_INHERIT if Engine.is_editor_hint() else ProcessMode.PROCESS_MODE_ALWAYS
	if not control and get_parent() is Control: control = get_parent()
	if not control and owner is Control: control = owner
	if not control: push_error('missing control on %s' % get_path()); return
	if not control.has_signal('pressed'): push_error('missing control with signal pressed on %s' % get_path())

func _ready() -> void:
	if control and control.has_signal('pressed'):
		control.pressed.connect(on_press)
