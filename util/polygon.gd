class_name PolygonUtil extends Node

static func uv_for_vertexes(v0:PackedVector2Array=[]) -> PackedVector2Array:
	var x0 := INF; var y0 := INF
	var x1 := -INF; var y1 := -INF
	for v in v0:
		x0 = minf(x0, v.x); y0 = minf(y0, v.y)
		x1 = maxf(x1, v.x); y1 = maxf(y1, v.y)
	var s := maxf(x1 - x0, y1 - y0)
	var d := Vector2(s / 2.0, s / 2.0);
	var uv := []
	for v in v0: uv.append((v + d) / s)
	return PackedVector2Array(uv)
