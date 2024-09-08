@tool
class_name PrimitiveCircle extends Node2D

signal sig_center_changed(new_center:Vector2)
signal sig_filled_changed(new_filled:bool)
signal sig_color_changed(new_color:Color)
signal sig_radius_changed(new_radius:int)

@export var radius : int = 16 : set = set_radius
@export var center : Vector2 = Vector2.ZERO : set = set_center
@export var color : Color = Color.HOT_PINK : set = set_color
@export var filled : bool = true : set = set_filled

func _draw() -> void:
	draw_circle(center, radius, color)

func set_center(v:Vector2):
	if center == v: return
	center = v
	sig_center_changed.emit(v)
	queue_redraw()

func set_filled(v:bool):
	if filled == v: return
	filled = v
	sig_filled_changed.emit(v)
	queue_redraw()

func set_color(v:Color):
	if color == v: return
	color = v
	sig_color_changed.emit(v)
	queue_redraw()

func set_radius(v:int):
	if radius == v: return
	radius = v
	sig_radius_changed.emit(v)
	queue_redraw()
