class_name KeyAdaptatvieLabel extends Label

@onready var key_search_re:RegEx = RegEx.create_from_string(r"\$.*?\$")
var untransformed_text:String

func transform_text(_text:String) -> String:
	for match_re in key_search_re.search_all(_text):
		var match_str:String = match_re.get_string()
		var new_val:String = GlobalVars.get_action_controls(match_str.replace("$", ""))
		_text = _text.replace(match_str, new_val)
	return _text

func _set(property: StringName, value: Variant) -> bool:
	if property == "text":
		untransformed_text = value
		text = transform_text(value)
	return true

func _ready() -> void:
	set("text", text)
	GlobalVars.action_changed.connect(on_action_updated)

func on_action_updated(action:String) -> void:
	if "$%s$" % [action] in untransformed_text:
		set("text", untransformed_text)
