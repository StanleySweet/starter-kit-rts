extends Camera3D

@export var polygon_plane : Plane = Plane(Vector3.UP, 0)
@export var interrupt_on_hitting_screen_margin : bool = true
@export var screen_margin : int = 1
@export var changed_signal_interval_lower_bound : float = 1.0 / 60.0 * 5.0  # s
@onready var ray_length: float = 1000.0  # Max ray distance

var _rect_on_screen := Rect2()
var _time_since_last_update := 0.0  # s
var _selecting := false
var _selected_entities: Array[CmpEntity] = []

signal entities_selected_changed(entities : Array[CmpEntity])

func get_ray_intersect_object() -> Variant:
	var space_state := get_world_3d().direct_space_state
	var mouse_pos := get_viewport().get_mouse_position()

	# Ray from the camera
	var from := project_ray_origin(mouse_pos)
	var to := from + project_ray_normal(mouse_pos) * 1000.0

	# Raycast to find the ground
	var query := PhysicsRayQueryParameters3D.create(from, to)

	return space_state.intersect_ray(query)

func get_ray_intersect_position() -> Variant:
	var result : Variant = get_ray_intersect_object()
	return result["position"] if result.has("position") else null

func get_nav_target() -> Variant:
	var hit_position : Vector3 = get_ray_intersect_position()
	if hit_position != null:
		# Find the closest valid point in the navigation mesh
		var nav_map := get_world_3d().navigation_map
		var target_position := NavigationServer3D.map_get_closest_point(nav_map, hit_position)

		return target_position

	print("No valid position found")
	return null

func get_ray_intersection_with_plane(screen_position : Vector2, plane : Plane) -> Vector3:
	var from := project_ray_origin(screen_position)
	var to := from + project_ray_normal(screen_position) * 1000.0  # Ray length

	var intersection : Vector3 = plane.intersects_ray(from, (to - from).normalized())
	if intersection:
		return intersection
	else:
		return Vector3() # Or handle no intersection as needed

func select_object() -> void:
	var result : Variant = get_ray_intersect_object()
	if result.has("collider"):
		var target : Variant = result["collider"].get_parent()

		if len(self._selected_entities) == 1 and target == self._selected_entities[0]:
			return

		if self._selected_entities != null and len(self._selected_entities) > 0:
			for selected_object in self._selected_entities:
				selected_object.query_component("Selectable").deselect()
				self._selected_entities = [] as Array[CmpEntity]
				entities_selected_changed.emit([] as Array[CmpEntity])

		if target is not CmpEntity:
			return

		var cmpSelectable : Selectable = target.query_component("Selectable")
		if cmpSelectable != null:
			self._selected_entities = [target]
			entities_selected_changed.emit(self._selected_entities)
			cmpSelectable.select()
	else:
		if self._selected_entities != null and len(self._selected_entities) > 0:
			for selected_object in self._selected_entities:
				selected_object.query_component("Selectable").deselect()
				selected_object = null
				entities_selected_changed.emit([] as Array[CmpEntity])
			self._selected_entities = [] as Array[CmpEntity]
		else:
			print("No object selected.")

func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			select_object()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if self._selected_entities != null and len(self._selected_entities) > 0:
				for selected_object in self._selected_entities:
					if selected_object != null and selected_object is CmpEntity:
						var cmpMotion : CmpMotion = selected_object.query_component("Motion")
						if cmpMotion != null:
							cmpMotion.move_to(get_nav_target())

func _physics_process(delta: float) -> void:
	_throttle_update(delta)
	if _screen_margin_hit():
		_clear()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_start()
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and not event.pressed
	):
		_finish()

func _screen_margin_hit() -> bool:
	var viewport_size : Vector2i = get_viewport().size
	var mouse_pos := get_viewport().get_mouse_position()
	return (
		mouse_pos.x <= screen_margin
		or mouse_pos.x >= viewport_size.x - screen_margin
		or mouse_pos.y <= screen_margin
		or mouse_pos.y >= viewport_size.y - screen_margin
	)

func _start() -> void:
	var mouse_pos := get_viewport().get_mouse_position()
	_rect_on_screen = Rect2(0, 0, 0, 0)
	_rect_on_screen.position = mouse_pos
	_selecting = true

func _clear() -> void:
	if not _selecting:
		return
	_selecting = false
	_rect_on_screen = Rect2()

func _finish() -> void:
	if not _selecting:
		return

	_rect_on_screen.end = get_viewport().get_mouse_position()
	var polygon_2d := _screen_rect_2d_to_topdown_polygon_2d(_rect_on_screen.abs())
	if len(polygon_2d) == 0:
		return
	
	_rect_on_screen = Rect2()

	var selected_entities := _entities_in_polygon(polygon_2d as Array[Vector2])
	for entity in selected_entities:
		var cmpSelectable : Selectable = entity.query_component("Selectable")
		if cmpSelectable:
			cmpSelectable.select()

	# Deselect previously selected object if using multi-selection
	for selected_object in self._selected_entities:
		if selected_object != null and not selected_entities.has(selected_object):
			selected_object.query_component("Selectable").deselect()
			selected_object = null

	self._selected_entities = selected_entities
	entities_selected_changed.emit(selected_entities)

func _throttle_update(delta : float) -> void:
	if _selecting:
		_time_since_last_update = 0.0
		return
	_time_since_last_update += delta
	if _time_since_last_update >= changed_signal_interval_lower_bound:
		_time_since_last_update = 0.0
		_update()


func _update() -> void:
	if _selecting:
		return
	_rect_on_screen.end = get_viewport().get_mouse_position()

func _screen_rect_2d_to_topdown_polygon_2d(rect_2d : Rect2) -> Array[Vector2]:
	if rect_2d == null:
		return [] as Array[Vector2]

	var min_size := 8  # pixels; tweak this as needed
	if rect_2d.size.length() < min_size:
		return [] as Array[Vector2]  # Too small, treat as a click

	var rect_points_2d : Array[Vector2] = [
		rect_2d.position,
		Vector2(rect_2d.position.x, rect_2d.end.y),
		rect_2d.end,
		Vector2(rect_2d.end.x, rect_2d.position.y),
	]

	var polygon_points_2d : Array[Vector2] = []
	for rect_point_2d in rect_points_2d:
		var polygon_point_3d := get_ray_intersection_with_plane(rect_point_2d, polygon_plane)
		polygon_points_2d.append(Vector2(polygon_point_3d.x, polygon_point_3d.z))

	return polygon_points_2d

func _entities_in_polygon(polygon_2d : Array[Vector2]) -> Array[CmpEntity]:
	var selected_entities: Array[CmpEntity] = []
	
	var all_entities := get_tree().get_nodes_in_group("CmpEntities")
	for entity in all_entities:
		if entity is CmpEntity:
			var pos : Vector3 = entity.global_transform.origin
			var pos_2d := Vector2(pos.x, pos.z)  # Top-down projection
			if Geometry2D.is_point_in_polygon(pos_2d, polygon_2d):
				selected_entities.append(entity)
	return selected_entities
