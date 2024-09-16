class_name ErrorUtil extends RefCounted

static func all_required(source:Object, property_names:Array[String]=[]) -> bool:
	if not source:
		push_error('missing source')
		return false
	var errors_found := false
	for property_name:String in property_names:
		if not source.get(property_name):
			push_error('missing %s at %s' % [property_name, source.get_path()])
			errors_found = true
	return not errors_found
