extends NavigationAgent3D
class_name Motion
@onready var walk_speed : float = 5.0
@onready var run_multiplier : float = 1.0
@onready var acceleration : float = 5.0

func _ready() -> void:
	self.set_physics_process(false)
	self.navigation_finished.connect(on_navigation_finished)


func move_to(target: Vector3) -> void:
	self.target_position = target;
	self.set_physics_process(true)
	


func _physics_process(delta : float) -> void:
	if self.is_navigation_finished():
		return
	
	var next_position : Vector3 = self.get_next_path_position()
	
	# We have no position here:
	
	var parent :=  self.get_parent();
	
	
	
	var offset :Vector3 = next_position - parent.global_position
	
	parent.global_position = parent.global_position.move_toward(next_position, delta * walk_speed)
	
	# Make the car look at the direction it's moving, while keeping its Y rotation constrained.
	offset.y = 0
	if offset.length() > 0.01:
		var direction : Vector3 = parent.global_position.direction_to(next_position)
		var target_rotation : float = atan2(direction.x, direction.z)
		parent.rotation.y = lerp_angle(parent.rotation.y, target_rotation, delta * acceleration)


func on_navigation_finished() -> void:
	self.set_physics_process(false)
