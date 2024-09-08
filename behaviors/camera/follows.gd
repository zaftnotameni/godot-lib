class_name CameraFollowsPlayer extends Node

## How quickly the shaking stops [0, 1].
@export var decay : float = 0.8
## Maximum hor/ver shake in pixels.
@export var max_offset := Vector2(100, 75)
## Maximum rotation in radians (use sparingly).
@export var max_roll : float = 0.1
## Current shake strength.
@export var trauma : float = 0.0
## Current constant shake strength, setting this will make the camera shake until its set back to 0.
@export var constant_trauma : float = 0.0
## Trauma exponent. Use [2, 3].
@export var trauma_power : float = 2
## Target to follow
@export var follow_target : Node2D
## Follow factor
@export var follow_factor : float = 400
@export var camera : Camera2D
## Group of the tilemap layer to use for defining camera boundaries
@export var tilemap_layer_group : StringName = 'foreground_tiles'
## Group of the floor to use for defining camera boundaries
@export var floor_group : StringName = 'floor_scene'
## Group of the player to use for resolving the player
@export var player_group: StringName = 'player_character_scene'

func trauma_request(t:float, m:float=0.3):
	trauma = m if (trauma + t >= m) else trauma + t

func trauma_relief(t:float):
	trauma = clamp(trauma - t, 0, 1.0)

func trauma_clear():
	trauma = 0

func constant_trauma_request(t:float, m:float=0.3):
	constant_trauma = m if (constant_trauma + t >= m) else constant_trauma + t

func constant_trauma_relief(t:float):
	constant_trauma = clamp(constant_trauma - t, 0, 1.0)

func constant_trauma_clear():
	constant_trauma = 0.0

func on_player_ready():
	follow_target = get_tree().get_first_node_in_group(player_group)

func on_player_exit():
	follow_target = null

func _ready() -> void:
	if Engine.is_editor_hint(): return
	var state := StateScene.first()
	if state:
		state.sig_player_ready.connect(on_player_ready)
		state.sig_player_exit.connect(on_player_exit)
	camera.make_current()
	await get_tree().create_timer(0.1).timeout
	on_player_ready()
	setup_boundaries.call_deferred()

func do_follow_target(n:Node2D,d:float) -> void:
	if not camera: return
	if not n: return
	if camera.is_queued_for_deletion(): return
	if n.is_queued_for_deletion(): return
	camera.global_position = camera.global_position.move_toward(n.global_position, d * follow_factor)

func _physics_process(delta: float) -> void: do_process(delta)

func do_process(delta:float):
	if Engine.is_editor_hint(): return
	if not camera: return
	if camera.is_queued_for_deletion(): return

	if follow_target: do_follow_target(follow_target,delta)
	if constant_trauma and not is_zero_approx(constant_trauma) and constant_trauma > 0:
		shake_pure_random(constant_trauma)
	elif trauma:
		trauma = max(trauma - decay * delta, 0)
		shake_pure_random(trauma)

func shake_pure_random(t:=trauma):
	var amount = pow(t, trauma_power)
	camera.rotation = max_roll * amount * randf_range(-1, 1)
	camera.offset.x = max_offset.x * amount * randf_range(-1, 1)
	camera.offset.y = max_offset.y * amount * randf_range(-1, 1)

const GROUP := 'camera_follows_player'

func _enter_tree() -> void:
	if Engine.is_editor_hint(): return
	add_to_group(GROUP)
	set_process(false)
	set_physics_process(true)
	if not camera and get_parent() is Camera2D: camera = get_parent()
	if not camera and owner is Camera2D: camera = owner
	if not camera and get_viewport().get_camera_2d() is Camera2D: camera = get_viewport().get_camera_2d()
	if not camera: push_error('missing camera')

static func tree() -> SceneTree: return Engine.get_main_loop()
static func first() -> CameraFollowsPlayer: return tree().get_first_node_in_group(GROUP)
static func all() -> Array: return tree().get_nodes_in_group(GROUP)

var min_x : float = 1000000
var min_y : float = 1000000
var max_x : float = -1000000
var max_y : float = -1000000

func setup_boundaries():
	setup_floor_boundaries()
	setup_tilemap_boundaries()

func setup_floor_boundaries():
	if not floor_group or floor_group.is_empty(): return

	var floor := get_tree().get_first_node_in_group(floor_group) as StaticBody2D
	if not floor: return

	for child in floor.get_children():
		var sprite := child as Sprite2D
		if not sprite: continue
		var glopos := sprite.global_position + (sprite.get_rect().size * 0.5)
		max_y = max(max_y, glopos.y)
		camera.limit_bottom = roundi(max_y)

func setup_tilemap_boundaries():
	if not tilemap_layer_group or tilemap_layer_group.is_empty(): return

	var layer := get_tree().get_first_node_in_group(tilemap_layer_group) as TileMapLayer
	if not layer: return
	for cell in layer.get_used_cells():
		var glopos := layer.to_global(layer.map_to_local(cell))
		min_x = min(min_x, glopos.x)
		min_y = min(min_y, glopos.y)
		max_x = max(max_x, glopos.x)
		max_y = max(max_y, glopos.y)
	camera.limit_left = snappedi(roundi(min_x - 16 * 0.25), 16) + 4
	camera.limit_right = snappedi(roundi(max_x + 16 * 0.25), 16) - 4
	camera.limit_top = roundi(min_y - 16 * 0.25)
	camera.limit_bottom = roundi(max_y + 16 * 0.25)
