extends Node
class_name Selectable

@export var outline_texture : Texture
@export var outline_mask_texture : Texture
@onready var selection_ring : MeshInstance3D
@onready var entity : CmpEntity = $".."
@export var ring_offset : float = -0.3
var cmp_footprint : CmpFootprint
var cmp_ownership : CmpOwnership

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
		var player_color := await self.cmp_ownership.get_player_color()
		selection_ring.material_override.set_shader_parameter("albedo", outline_texture)
		selection_ring.material_override.set_shader_parameter("mask", outline_mask_texture)
		self.selection_ring.material_override.set_shader_parameter("color", player_color)
	
	self.selection_ring.hide()
	self.selection_ring.position.y = ring_offset
	self.entity.add_child.call_deferred(self.selection_ring)
	
func select() -> void:
	self.selection_ring.show()

func deselect() -> void:
	self.selection_ring.hide()
