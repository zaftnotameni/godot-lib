class_name SignalUtil extends RefCounted

static func signal_connect_whitelist(subscriber:Node, publisher:Node, whitelist:Array=[], add_prefix:='sig_'):
	for published_signal in publisher.get_signal_list():
		var signal_name : String = published_signal.name
		if not whitelist.has(signal_name): continue
		var clean_name : String = signal_name
		var target_method_name := 'on_' + add_prefix + clean_name
		signal_smart_connect(subscriber, publisher, signal_name, target_method_name)

static func signal_connect_prefix(subscriber:Node, publisher:Node, prefix:String='sig_', add_prefix:='sig_'):
	for published_signal in publisher.get_signal_list():
		var signal_name : String = published_signal.name
		if not signal_name.begins_with(prefix): continue
		var clean_name : String = signal_name.trim_prefix(prefix)
		var target_method_name := 'on_' + add_prefix + clean_name
		signal_smart_connect(subscriber, publisher, signal_name, target_method_name)

static func signal_smart_connect(subscriber:Node, publisher:Node, signal_name: String, method_name: String):
	if not subscriber.has_method(method_name):
		push_error('missing method %s' % method_name)
		return false
	if not publisher.has_signal(signal_name):
		push_error('missing signal %s' % signal_name)
		return false
	var target_method : Callable = subscriber.get(method_name)
	if publisher.is_connected(signal_name, target_method): return false
	publisher.connect(signal_name, target_method)
	return true
