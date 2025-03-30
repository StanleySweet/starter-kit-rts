extends Node3D

@export_category("Scroll")
@export var scroll_speed: float = 120.0
@export var scroll_speed_modifier: float = 1.05
@export var scroll_mouse_detect_distance: int = 3

@export_category("Rotate")
@export var rotate_x_speed: float = 1.2
@export var rotate_x_min: float = 28.0
@export var rotate_x_max: float = 60.0
@export var rotate_x_default: float = -35.0
@export var rotate_y_speed: float = 2.0
@export var rotate_y_speed_wheel: float = 0.45
@export var rotate_y_default: float = 0.0
@export var rotate_speed_modifier: float = 1.05
@export var rotate_x_smoothness: float = 0.5
@export var rotate_y_smoothness: float = 0.3

@export_category("Drag")
@export var drag_speed: float = 0.5
@export var drag_inverted: bool = false

@export_category("Zoom")
@export var zoom_speed: float = 256.0
@export var zoom_speed_wheel: float = 32.0
@export var zoom_min: float = 50.0
@export var zoom_max: float = 200.0
@export var zoom_default: float = 20.0
@export var zoom_speed_modifier: float = 1.05
@export var zoom_smoothness: float = 0.4

@export_category("Camera")
@export var far: float = 4096.0
@export var fov: float = 45.0
@export var near: float = 2.0

@export_category("Other")
@export var pos_smoothness: float = 0.1
@export var height_smoothness: float = 0.5
@export var height_min: float = 16.0



@onready var camera_3d: Camera3D = $Camera3D

var target_zoom: float
var target_rotation_x: float
var target_rotation_y: float

var target_position : Vector3

var dragging: bool = false
var last_mouse_position: Vector2
var hotkey_jump_positions: Dictionary = {}  # Stores jump positions

func _ready() -> void:
	self.target_rotation_x = rotate_x_default
	self.target_rotation_y = rotate_y_default
	self.rotation_degrees.x = target_rotation_x
	self.rotation_degrees.y = target_rotation_y

	self.camera_3d.fov = fov
	self.camera_3d.far = far
	self.camera_3d.near = near

	self.target_zoom = zoom_default
	self._update_camera_position()

func _input(event: InputEvent) -> void:

	if event is InputEventMouseMotion:
		if dragging:
			_handle_drag(event)

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = event.pressed
			if dragging:
				last_mouse_position = event.position

		if event.button_index == MOUSE_BUTTON_MIDDLE:
			self._handle_pan(event)

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			self._handle_zoom(-zoom_speed_wheel)

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			self._handle_zoom(zoom_speed_wheel)

	elif event is InputEventKey and event.pressed:
		self._handle_hotkeys(event)

func frame_independent_lerp(delta : float, smoothness : float) -> float:
	return 1.0 - exp(-smoothness * delta * 60)
	


func _physics_process(delta: float) -> void:
	self.position = lerp(position, target_position, frame_independent_lerp(delta, pos_smoothness))
	self.camera_3d.position.z = lerp(self.camera_3d.position.z, target_zoom, frame_independent_lerp(delta, zoom_smoothness))
	rotation_degrees.x = lerp(rotation_degrees.x, target_rotation_x, frame_independent_lerp(delta, rotate_x_smoothness * rotate_speed_modifier))
	rotation_degrees.y = lerp(rotation_degrees.y, target_rotation_y, frame_independent_lerp(delta, rotate_y_smoothness * rotate_speed_modifier))
	_update_camera_position()

func _handle_zoom(amount: float) -> void:
	self.target_zoom = clamp(self.target_zoom + amount, self.zoom_min, self.zoom_max)

func _handle_drag(event: InputEventMouseMotion) -> void:
	var delta : Vector2 = event.relative * drag_speed
	if drag_inverted:
		delta *= -1

	target_rotation_y -= delta.x * rotate_y_speed
	target_rotation_x = -clamp(target_rotation_x - delta.y * rotate_x_speed, rotate_x_min, rotate_x_max)

func _handle_hotkeys(event: InputEventKey) -> void:
	if Input.is_action_pressed("camera.down"):
		self._handle_pan_key(Vector3(0, 0, -1))

	if Input.is_action_pressed("camera.up"):
		self._handle_pan_key(Vector3(0, 0, 1))

	if Input.is_action_pressed("camera.left"):
		self._handle_pan_key(Vector3(1, 0, 0))

	if Input.is_action_pressed("camera.right"):
		self._handle_pan_key(Vector3(-1, 0, 0))
		
	if Input.is_action_pressed("camera.reset"):
		self._reset_camera()

	if Input.is_action_pressed("camera.lastattackfocus"):
		self._jump_to_last_attack()

	if Input.is_action_just_released("camera.zoom.in"):
		self._handle_zoom(-zoom_speed)
	
	if Input.is_action_just_released("camera.zoom.out"):
		self._handle_zoom(zoom_speed)

	if Input.is_action_pressed("camera.rotate.cw"):
		self._handle_rotation_key(10)

	if Input.is_action_pressed("camera.rotate.ccw"):
		self._handle_rotation_key(-10)
		
	match event.keycode:
		KEY_F5, KEY_F6, KEY_F7, KEY_F8:
			_jump_to_saved_position(event.keycode)
		_:
			pass


func _handle_pan(event: InputEventMouseMotion) -> void:
	var pan_speed : float = scroll_speed * 0.02

	# Get the camera's right and forward vectors
	var right := -global_transform.basis.x
	
	# Get forward vector, but ignore the Y component (to prevent zooming effect)
	var forward := -global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()  # Normalize after modification

	
	# Compute movement based on mouse drag
	self.target_position += (right * event.relative.x * pan_speed) + (forward * event.relative.y * pan_speed)


func _handle_pan_key(direction: Vector3) -> void:
	# Get the camera's right and forward vectors
	var right := -global_transform.basis.x
	
	# Get forward vector, but ignore the Y component (to prevent zooming effect)
	var forward := -global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()  # Normalize after modification

	
	# Apply movement
	self.target_position += (right * direction.x) + (forward * direction.z)

func _handle_rotation_key(amount: float) -> void:
	target_rotation_y += amount

func _reset_camera() -> void:
	target_rotation_x = rotate_x_default
	target_rotation_y = rotate_y_default
	target_zoom = zoom_default

func _jump_to_last_attack() -> void:
	# Placeholder for actual attack location logic
	global_position = Vector3(0, 0, 0)

func _jump_to_saved_position(keycode: int) -> void:
	if hotkey_jump_positions.has(keycode):
		global_position = hotkey_jump_positions[keycode]

func _update_camera_position() -> void:
	camera_3d.position.z = max(camera_3d.position.z, height_min)
