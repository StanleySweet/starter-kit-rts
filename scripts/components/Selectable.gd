extends Node
class_name Selectable

## The texture to use for the outline.
@export var outline_texture : Texture
## The texture to use as a mask for the outline.
@export var outline_mask_texture : Texture
## The offset for the selection ring.
@export var ring_offset : float = -0.3

@onready var selection_ring : MeshInstance3D
@onready var entity : CmpEntity = $".."
var cmp_footprint : CmpFootprint
var cmp_ownership : CmpOwnership
var cmp_sound : CmpSound

func _ready() -> void:
	selection_ring = MeshInstance3D.new()
	selection_ring.name = "SelectionRing"
	var quad := QuadMesh.new()
	selection_ring.mesh = quad
	quad.orientation = PlaneMesh.FACE_Y
	selection_ring.material_override = ShaderMaterial.new()
	selection_ring.material_override.shader = preload("res://shaders/selection.gdshader")
	
	self.cmp_footprint = entity.query_component("Footprint")
	if self.cmp_footprint == null:
		push_warning("Could not find footprint, selection ring will not work")
	else:
		self.selection_ring.mesh.size = self.cmp_footprint.get_size()
	
	self.cmp_ownership = entity.query_component("Ownership")
	if self.cmp_ownership == null:
		push_warning("Could not find footprint, selection ring will have wrong color")
	else:
		var player_color := self.cmp_ownership.get_player_color()
		selection_ring.material_override.set_shader_parameter("albedo", outline_texture)
		selection_ring.material_override.set_shader_parameter("mask", outline_mask_texture)
		self.selection_ring.material_override.set_shader_parameter("color", player_color)
	
	self.cmp_sound = self.entity.query_component("Sound")
	if self.cmp_sound == null:
		push_warning("Could not find sound component, selection will have no sound")
		
	self.selection_ring.hide()
	self.selection_ring.position.y = ring_offset
	self.entity.add_child.call_deferred(self.selection_ring)
	
func select() -> void:
	self.selection_ring.show()
	if self.cmp_sound != null:
		self.cmp_sound.play_positioned_sound("select")

func deselect() -> void:
	self.selection_ring.hide()
