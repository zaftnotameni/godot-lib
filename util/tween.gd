class_name TweenUtil extends RefCounted

static func scene_tree() -> SceneTree:
	return Engine.get_main_loop()

static func tween_kill(t:Tween):
	if t and t.is_running(): t.kill()

static func tween_pauseable_eased(t:Tween=scene_tree().create_tween(),always_kill:=true)->Tween:
	if always_kill: tween_kill(t)
	t = scene_tree().create_tween()
	t = tween_eased(t)
	t = tween_respects_pause(t)
	return t

static func tween_unpauseable_eased(t:Tween=scene_tree().create_tween(),always_kill:=true)->Tween:
	if always_kill: tween_kill(t)
	t = scene_tree().create_tween()
	t = tween_eased(t)
	t = tween_ignores_pause(t)
	return t

static func tween_eased(t:Tween=scene_tree().create_tween())->Tween:
	t.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	return t

static func tween_ignores_pause(t:Tween=scene_tree().create_tween())->Tween:
	t.set_pause_mode(Tween.TweenPauseMode.TWEEN_PAUSE_PROCESS)
	return t

static func tween_respects_pause(t:Tween=scene_tree().create_tween())->Tween:
	t.set_pause_mode(Tween.TweenPauseMode.TWEEN_PAUSE_STOP)
	return t

static func tween_inherit_pause(t:Tween=scene_tree().create_tween())->Tween:
	t.set_pause_mode(Tween.TweenPauseMode.TWEEN_PAUSE_BOUND)
	return t
