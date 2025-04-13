class_name CmpEntityAI extends Node

@onready var entity : CmpEntity = $".."

enum EntityStates {
	IDLE,
	WALKING
}

# État actuel de l'entité
var current_state: int = EntityStates.IDLE

# Référence aux composants
var cmp_visual_actor : CmpVisualActor
var cmp_motion : CmpMotion

# Signal émis lors d'un changement d'état
signal state_changed(old_state : int, new_state : int)

func _ready() -> void:

	self.cmp_visual_actor = entity.query_component("VisualActor")
	if self.cmp_visual_actor == null:
		push_warning("Could not find VisualActor, AI will not work")
		return

	self.cmp_motion = entity.query_component("Motion")
	if cmp_motion:
		cmp_motion.movement_started.connect(_on_movement_started)
		cmp_motion.movement_finished.connect(_on_movement_finished)
		cmp_motion.movement_in_progress.connect(_on_movement_in_progress)

# Méthode principale pour changer d'état
func set_state(new_state: int) -> void:
	if new_state == current_state:
		return  # Ne rien faire si on est déjà dans cet état
	
	var old_state := current_state
	current_state = new_state
	
	# Appliquer les changements d'animation selon l'état
	if cmp_visual_actor:
		match current_state:
			EntityStates.IDLE:
				cmp_visual_actor.select_animation("idle")
			EntityStates.WALKING:
				cmp_visual_actor.select_animation("walk")
	
	# Émettre le signal de changement d'état
	state_changed.emit(old_state, new_state)

# Méthodes d'aide pour les transitions courantes
func set_idle() -> void:
	set_state(EntityStates.IDLE)

func set_walking() -> void:
	set_state(EntityStates.WALKING)

# Callbacks pour les événements de mouvement
func _on_movement_started() -> void:
	set_walking()

func _on_movement_finished() -> void:
	set_idle()
	
func _on_movement_in_progress() -> void:
	# Optionnel: peut être utilisé pour garantir que l'état est correct pendant le mouvement
	if current_state != EntityStates.WALKING:
		set_walking()
