extends Node
class_name Selectable

@export var outline_texture : Texture
@export var outline_mask_texture : Texture
@onready var selection_ring : MeshInstance3D = $SelectionRing

var footprint : Footprint
func _ready() -> void:
	self.selection_ring.hide()
	self.footprint = $"../Footprint"
	if self.footprint == null:
		push_warning("Could not find footprint, selection ring will not work")
	else:
		self.selection_ring.mesh.size = self.footprint.get_size()
		
func select() -> void:
	self.selection_ring.show()

func deselect() -> void:
	self.selection_ring.hide()
