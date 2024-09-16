class_name ConstantVelocityBehavior extends Node

signal sig_out_of_bounds()

@export var direction : Vector2
@export var speed : float
@export var bounds : Rect2

@export_category('optional')
@export var target : Node2D

func _enter_tree() -> void:
	if Engine.is_editor_hint(): return
	ResolveUtil.or_parent(self, 'target')
	set_physics_process(ErrorUtil.all_required(self, ['target']))

func _physics_process(delta: float) -> void:
	target.global_position += speed * direction * delta
	if bounds and not bounds.has_point(target.global_position):
		sig_out_of_bounds.emit()

static func from(target_owner:Node) -> ConstantVelocityBehavior:
	return MetaComponentBehavior.resolve_via_component_meta(target_owner, ConstantVelocityBehavior)
