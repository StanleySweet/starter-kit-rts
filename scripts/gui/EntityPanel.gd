extends PanelContainer
@onready var entity_icon : TextureRect = $MarginContainer/VSplitContainer/HSplitContainer/EntityIcon
@onready var entity_generic_name : Label = $MarginContainer/VSplitContainer/HSplitContainer/EntityGenericName
func _on_camera_3d_entities_selected_changed(entities: Array[CmpEntity]) -> void:
	if len(entities) == 0:
		self.hide()
		return
	
	self.show()
	
	# TODO: Handle multiple entities.
	var entity := entities[0]
	var cmpIdentity : CmpIdentity = entity.query_component("Identity")
	if cmpIdentity != null:
		entity_icon.texture = cmpIdentity.icon
		entity_generic_name.text = cmpIdentity.generic_name
		
	
	
