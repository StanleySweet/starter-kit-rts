class_name CmpMotion extends NavigationAgent3D

@onready var walk_speed: float = 5.0
@onready var run_multiplier: float = 1.0
@onready var acceleration: float = 5.0

# Signaux pour notifier les changements d'état
signal movement_started
signal movement_finished
signal movement_in_progress

func _ready() -> void:
	self.set_physics_process(false)
	self.navigation_finished.connect(on_navigation_finished)

func move_to(target: Vector3) -> void:
	if target == null:
		return
		
	self.target_position = target
	self.set_physics_process(true)
	
	# Notifier que le mouvement a commencé
	movement_started.emit()

func _physics_process(delta: float) -> void:
	if self.is_navigation_finished():
		return
	
	var next_position: Vector3 = self.get_next_path_position()
	var parent := self.get_parent()
	var offset: Vector3 = next_position - parent.global_position
	
	# Déplacer l'entité vers la prochaine position
	parent.global_position = parent.global_position.move_toward(next_position, delta * walk_speed)
	
	# Faire que l'entité regarde dans la direction où elle se déplace (en gardant sa rotation Y contrainte)
	offset.y = 0
	if offset.length() > 0.01:
		var direction: Vector3 = parent.global_position.direction_to(next_position)
		var target_rotation: float = atan2(direction.x, direction.z)
		parent.rotation.y = lerp_angle(parent.rotation.y, target_rotation, delta * acceleration)
	
	# Émettre un signal indiquant que le mouvement est en cours
	movement_in_progress.emit()

func on_navigation_finished() -> void:
	self.set_physics_process(false)
	
	# Notifier que le mouvement est terminé
	movement_finished.emit()
