@tool

class_name CmpMinimap extends Node

enum EType {
	Unit,
	Structure
}

@export var type : EType
@export var default_color : Color
@export var size : Vector2 = Vector2(1.0, 1.0)

@onready var _entity : CmpEntity = $".."

var _icon : MeshInstance3D

var _color : Color

func _ready() -> void:
	if default_color.r == 0 and default_color.r == default_color.g and default_color.r == default_color.b and not Engine.is_editor_hint():
		var cmp_ownership : CmpOwnership = self._entity.query_component("Ownership")
		if cmp_ownership != null:
			self._color = cmp_ownership.get_player_color()
	else:
		self._color = default_color
	var quad := QuadMesh.new()
	quad.size = size
	_icon = MeshInstance3D.new()
	_icon.layers = 2
	_icon.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_icon.mesh = quad
	quad.orientation = PlaneMesh.FACE_Y
	var material := StandardMaterial3D.new()
	material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = self._color
	_icon.material_override = material
	_icon.position.y = 30.0
	self._entity.add_child.call_deferred(self._icon)
