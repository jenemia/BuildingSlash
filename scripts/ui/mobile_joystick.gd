extends Control

signal move_axis_changed(axis: float)
signal jump_triggered
signal attack_triggered

@export var base_radius: float = 172.0
@export var knob_radius: float = 70.0
@export var left_margin: float = 188.0
@export var bottom_margin: float = 190.0
@export var deadzone: float = 0.18
@export var jump_threshold: float = 0.62
@export var attack_button_radius: float = 68.0
@export var attack_right_margin: float = 128.0
@export var attack_bottom_margin: float = 156.0
@export var design_height: float = 1080.0
@export var ui_scale_min: float = 0.70
@export var ui_scale_max: float = 1.35

var _active_touch_id: int = -1
var _attack_touch_id: int = -1
var _base_center: Vector2 = Vector2.ZERO
var _attack_center: Vector2 = Vector2.ZERO
var _knob_offset: Vector2 = Vector2.ZERO
var _jump_latched: bool = false
var _ui_scale: float = 1.0
var _safe_rect: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = _should_show_on_this_device()
	_update_layout()
	get_viewport().size_changed.connect(_update_layout)

func apply_safe_area(safe_rect: Rect2) -> void:
	_safe_rect = safe_rect
	_update_layout()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if _active_touch_id == -1 and _is_valid_start(event.position):
			_active_touch_id = event.index
			_update_from_position(event.position)
		elif _attack_touch_id == -1 and _is_attack_button(event.position):
			_attack_touch_id = event.index
			attack_triggered.emit()
			queue_redraw()
	else:
		if event.index == _active_touch_id:
			_release_stick()
		if event.index == _attack_touch_id:
			_attack_touch_id = -1
			queue_redraw()

func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index != _active_touch_id:
		return
	_update_from_position(event.position)

func _update_from_position(screen_pos: Vector2) -> void:
	var delta := screen_pos - _base_center
	var current_base_radius := _scaled(base_radius)
	if delta.length() > current_base_radius:
		delta = delta.normalized() * current_base_radius
	_knob_offset = delta
	
	var normalized := _knob_offset / current_base_radius
	var axis := normalized.x
	if absf(axis) < deadzone:
		axis = 0.0
	move_axis_changed.emit(clampf(axis, -1.0, 1.0))
	
	if normalized.y <= -jump_threshold:
		if not _jump_latched:
			_jump_latched = true
			jump_triggered.emit()
	else:
		_jump_latched = false
	
	queue_redraw()

func _release_stick() -> void:
	_active_touch_id = -1
	_knob_offset = Vector2.ZERO
	_jump_latched = false
	move_axis_changed.emit(0.0)
	queue_redraw()

func _is_valid_start(screen_pos: Vector2) -> bool:
	# 왼쪽 하단 영역만 사용 (오른쪽 영역 액션 버튼 확장 여지)
	var viewport_size := get_viewport_rect().size
	if screen_pos.x > viewport_size.x * 0.55:
		return false
	return screen_pos.distance_to(_base_center) <= _scaled(base_radius) * 1.8

func _is_attack_button(screen_pos: Vector2) -> bool:
	return screen_pos.distance_to(_attack_center) <= _scaled(attack_button_radius) * 1.2

func _update_layout() -> void:
	var viewport_size := get_viewport_rect().size
	if _safe_rect.size == Vector2.ZERO:
		_safe_rect = Rect2(Vector2.ZERO, viewport_size)
	_ui_scale = _compute_ui_scale(viewport_size)

	var current_base_radius := _scaled(base_radius)
	var current_attack_radius := _scaled(attack_button_radius)
	var current_left_margin := _scaled(left_margin)
	var current_bottom_margin := _scaled(bottom_margin)
	var current_attack_right_margin := _scaled(attack_right_margin)
	var current_attack_bottom_margin := _scaled(attack_bottom_margin)
	var padding := _scaled(12.0)

	var min_x := _safe_rect.position.x + current_base_radius + padding
	var max_x := _safe_rect.end.x - current_base_radius - padding
	var min_y := _safe_rect.position.y + current_base_radius + padding
	var max_y := _safe_rect.end.y - current_base_radius - padding
	
	var target_x := clampf(_safe_rect.position.x + current_left_margin, min_x, max_x)
	var target_y := clampf(_safe_rect.end.y - current_bottom_margin, min_y, max_y)
	_base_center = Vector2(target_x, target_y)

	var attack_min_x := _safe_rect.position.x + current_attack_radius + padding
	var attack_max_x := _safe_rect.end.x - current_attack_radius - padding
	var attack_min_y := _safe_rect.position.y + current_attack_radius + padding
	var attack_max_y := _safe_rect.end.y - current_attack_radius - padding
	var attack_x := clampf(_safe_rect.end.x - current_attack_right_margin, attack_min_x, attack_max_x)
	var attack_y := clampf(_safe_rect.end.y - current_attack_bottom_margin, attack_min_y, attack_max_y)
	_attack_center = Vector2(attack_x, attack_y)
	
	if _active_touch_id == -1:
		_knob_offset = Vector2.ZERO
	queue_redraw()

func _should_show_on_this_device() -> bool:
	if OS.has_feature("mobile"):
		return true
	if DisplayServer.has_method("is_touchscreen_available"):
		return DisplayServer.is_touchscreen_available()
	return false

func _draw() -> void:
	var current_base_radius := _scaled(base_radius)
	var current_knob_radius := _scaled(knob_radius)
	var current_attack_radius := _scaled(attack_button_radius)

	draw_circle(_base_center, current_base_radius, Color(0.1, 0.1, 0.1, 0.35))
	draw_circle(_base_center, current_base_radius - _scaled(6.0), Color(0.5, 0.5, 0.5, 0.18))
	draw_circle(_base_center + _knob_offset, current_knob_radius, Color(0.7, 0.9, 1.0, 0.7))

	var attack_color := Color(1.0, 0.35, 0.35, 0.55)
	if _attack_touch_id != -1:
		attack_color = Color(1.0, 0.2, 0.2, 0.9)
	draw_circle(_attack_center, current_attack_radius, attack_color)
	draw_circle(_attack_center, current_attack_radius - _scaled(8.0), Color(1.0, 0.8, 0.8, 0.35))

func _compute_ui_scale(viewport_size: Vector2) -> float:
	if design_height <= 0.0:
		return 1.0
	var scale := viewport_size.y / design_height
	return clampf(scale, ui_scale_min, ui_scale_max)

func _scaled(v: float) -> float:
	return v * _ui_scale
