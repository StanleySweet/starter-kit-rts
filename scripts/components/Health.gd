## Component that manages the health of an entity.
class_name CmpHealth extends Node

## Defines the max health of the entity.
@export_range(0.1, INF, 0.1, "or_greater", "hide_slider") var max_health : float = 200.0
var _current_health : float = max_health

signal health_changed(new_health : HealthChangedMessage)

## Returns the current health as a percentage of the maximum health.
func get_health_percentage() -> float:
	return _current_health / max_health * 100.0

## Applies damage to the entity, reducing its health.
## Emits the health_changed signal.
func apply_damage(amount: float) -> void:
	_current_health = max(0.0, _current_health - amount)
	health_changed.emit({
		"new_health" : _current_health,
		"new_percent" : get_health_percentage()
	})

## Applies healing to the entity, increasing its health.
## Emits the health_changed signal.
func apply_healing(amount: float) -> void:
	_current_health = min(max_health, _current_health + amount)
	health_changed.emit({
		"new_health" : _current_health,
		"new_percent" : get_health_percentage()
	})

## Sets the current health of the entity, clamping it between 0 and max_health.
## Emits the health_changed signal.
func set_health(value: float) -> void:
	_current_health = clamp(value, 0.0, max_health)
	health_changed.emit({
		"new_health" : _current_health,
		"new_percent" : get_health_percentage()
	})

## Returns the current health of the entity.
func get_health() -> float:
	return _current_health
