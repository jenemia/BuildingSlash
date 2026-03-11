extends Control

signal move_axis_changed(axis: float)
signal jump_triggered

@export var base_radius: float = 72.0
@export var knob_radius: float = 30.0
@export var left_margin: float = 96.0
@export var bottom_margin: float = 110.0
@export var deadzone: float = 0.2
@export var jump_threshold: float = 0.7

var _active_touch_id: int = -1
var _base_center: Vector2 = Vector2.ZERO
var _knob_offset: Vector2 = Vector2.ZERO
var _jump_latched: bool = false

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_layout()
	get_viewport().size_changed.connect(_update_layout)

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
	else:
		if event.index == _active_touch_id:
			_release_stick()

func _handle_drag(event: InputEventScreenDrag) -> void:
	if event.index != _active_touch_id:
		return
	_update_from_position(event.position)

func _update_from_position(screen_pos: Vector2) -> void:
	var delta := screen_pos - _base_center
	if delta.length() > base_radius:
		delta = delta.normalized() * base_radius
	_knob_offset = delta
	
	var normalized := _knob_offset / base_radius
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
	return screen_pos.distance_to(_base_center) <= base_radius * 1.8

func _update_layout() -> void:
	var viewport_size := get_viewport_rect().size
	_base_center = Vector2(left_margin, viewport_size.y - bottom_margin)
	if _active_touch_id == -1:
		_knob_offset = Vector2.ZERO
	queue_redraw()

func _draw() -> void:
	draw_circle(_base_center, base_radius, Color(0.1, 0.1, 0.1, 0.35))
	draw_circle(_base_center, base_radius - 6.0, Color(0.5, 0.5, 0.5, 0.18))
	draw_circle(_base_center + _knob_offset, knob_radius, Color(0.7, 0.9, 1.0, 0.7))
