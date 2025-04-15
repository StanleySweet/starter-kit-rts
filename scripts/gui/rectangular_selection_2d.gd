extends Panel

signal finished(rect: Rect2)

@export var interrupt_on_hitting_screen_margin: bool = true
@export var screen_margin: int = 1

var _rect := Rect2()
var _selecting := false

func _ready() -> void:
	hide()

func _physics_process(_delta: float) -> void:
	_update()
	if interrupt_on_hitting_screen_margin and _screen_margin_hit():
		_clear()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_start()
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_finish()

func _screen_margin_hit() -> bool:
	var viewport_size: Vector2 = get_viewport().size
	var mouse_pos: Vector2 = get_global_mouse_position()
	return (
		mouse_pos.x <= screen_margin
		or mouse_pos.x >= viewport_size.x - screen_margin
		or mouse_pos.y <= screen_margin
		or mouse_pos.y >= viewport_size.y - screen_margin
	)

func _start() -> void:
	_rect = Rect2(get_global_mouse_position(), Vector2.ZERO)
	_selecting = true

func _clear() -> void:
	_rect = Rect2()
	_selecting = false
	hide()

func _finish() -> void:
	if not _selecting:
		return
	_rect.end = get_global_mouse_position()
	finished.emit(_rect.abs())
	self._clear()

func _update() -> void:
	if not _selecting:
		return
	_rect.end = get_global_mouse_position()
	var absolute_rect: Rect2 = _rect.abs()
	if absolute_rect.has_area():
		show()
	position = absolute_rect.position
	size = absolute_rect.size
