extends PanelContainer
@onready var entity_icon : TextureRect = $HSplitContainer/MarginContainer/VSplitContainer/HSplitContainer/EntityIcon
@onready var entity_generic_name : Label = $HSplitContainer/MarginContainer/VSplitContainer/HSplitContainer/EntityGenericName
@onready var health_block : PanelContainer = $HSplitContainer/MarginContainer/VSplitContainer/PanelContainer
@onready var health_bar : ProgressBar = $HSplitContainer/MarginContainer/VSplitContainer/PanelContainer/ProgressBar


var _entities : Array[CmpEntity]

func _on_camera_3d_entities_selected_changed(entities: Array[CmpEntity]) -> void:
	if len(entities) == 0:
		self.hide()
		return
	
	_entities = entities
	self.show()
	
	# TODO: Handle multiple entities.
	var entity := entities[0]
	var cmpIdentity : CmpIdentity = entity.query_component("Identity")
	if cmpIdentity != null:
		entity_icon.texture = cmpIdentity.icon
		entity_generic_name.text = cmpIdentity.generic_name
		
	var cmpHealth : CmpHealth = entity.query_component("Health")
	if cmpHealth != null:
		if not cmpHealth.is_connected("health_changed", _on_health_changed):
			cmpHealth.connect("health_changed", _on_health_changed)
		health_block.show()
		health_bar.value = cmpHealth.get_health_percentage()
	else:
		health_block.hide()
		for e in _entities:
			var cmp_health : CmpHealth = e.query_component("Health")
			if cmp_health != null and cmp_health.is_connected("health_changed", _on_health_changed):
				cmp_health.disconnect("health_changed", _on_health_changed)
		_entities = []
		
func _on_health_changed(data : HealthChangedMessage) -> void:
	if not len(_entities) > 0:
		return
		
	health_bar.value = data.new_percent
