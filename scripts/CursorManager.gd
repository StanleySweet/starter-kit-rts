extends Node

var hovering_selectable: bool = false
# Référence aux curseurs personnalisés de Kenney assets
@export var default_cursor: Resource
@export var gauntlet_open_cursor: Resource 
@export var ray_length: float = 1000.0  # Max ray distance

@onready var camera : Camera3D= $"../../CameraController/Camera3D"
func _process(_delta: float) -> void:
	# Vérifier constamment ce qui est sous le curseur
	check_hover()

func check_hover() -> void:
	var space_state := camera.get_world_3d().direct_space_state
	var mouse_position := camera.get_viewport().get_mouse_position()
	
	# Create a ray from the camera
	var from := camera.project_ray_origin(mouse_position)
	var to := from + camera.project_ray_normal(mouse_position) * ray_length
	
	# Perform the raycast
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := space_state.intersect_ray(query)
	
	var was_hovering := hovering_selectable
	hovering_selectable = false
	
	if result.has("collider"):
		var target: Variant = result["collider"].get_parent()
		if target is CmpEntity:
			var cmpSelectable: Selectable = target.query_component("Selectable")
			
			if cmpSelectable != null:
				hovering_selectable = true
			
	# Changer le curseur si l'état de survol a changé
	if was_hovering != hovering_selectable:
		if hovering_selectable:
			# Changer le curseur pour le gant ouvert quand on survole une unité
			Input.set_custom_mouse_cursor(gauntlet_open_cursor)
		else:
			# Revenir au curseur par défaut quand on ne survole pas d'unité
			Input.set_custom_mouse_cursor(default_cursor)
