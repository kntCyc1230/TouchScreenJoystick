@tool
extends Control
class_name TouchScreenJoystick

@export var use_textures : bool:
	set(new_bool):
		use_textures = new_bool
		notify_property_list_changed()
@export var knob_color := Color.WHITE
@export var base_color := Color.WHITE
@export var background_color := Color(Color.BLACK, 0.25)

@export var base_radius := 130.0
@export var knob_radius := 65.0
@export var thickness := 1.8
@export var anti_aliased : bool

@export_group("Textures")
@export var use_custom_max_length : bool:
	set(new_bool):
		use_custom_max_length = new_bool
		notify_property_list_changed()

@export var max_length := 120.0
@export var base_texture : Texture2D
@export var knob_texture : Texture2D
@export var background_texture : Texture2D

@export_group("Joystick Params")
@export_enum("FIXED", "DYNAMIC") var mode := 0
@export var deadzone := 10.0:
	set(new_deadzone):
		deadzone = clamp(new_deadzone, 10, base_radius)

@export var smooth_reset : bool:
	set(new_bool):
		smooth_reset = new_bool
		notify_property_list_changed()
@export var smooth_speed := 5.0
@export var change_opacity_when_touched : bool:
	set(new_bool):
		change_opacity_when_touched = new_bool
		notify_property_list_changed()

@export_range(0, 100, 0.01, "suffix:%") var from_opacity := 50.0
@export_range(0, 100, 0.01, "suffix:%") var to_opacity := 100.0
@export var use_input_actions : bool:
	set(new_bool):
		use_input_actions = new_bool
		notify_property_list_changed()

@export_subgroup("Input Actions")
@export var action_left := "ui_left"
@export var action_right := "ui_right"
@export var action_up := "ui_up"
@export var action_down := "ui_down"

@export_group("Debug")
@export var draw_debugs : bool:
	set(new_bool):
		draw_debugs = new_bool
		notify_property_list_changed()
@export var deadzone_color := Color(Color.RED, 0.5)
@export var current_max_length_color := Color(Color.BLUE, 0.5)



var is_pressing : bool
var knob_position : Vector2
var finger_index : int
var default_pos : Vector2

func _ready() -> void:
	default_pos = position
	change_opacity()

func _process(delta: float) -> void:
	
	# checks if currently pressing
	if is_pressing:
		
		move_knob_pos()
	else:
		reset_knob_pos()
	
	# update necessities
	update_input_actions()
	pivot_offset = size / 2
	queue_redraw()

#moves the knob position when pressing
func move_knob_pos() -> void:
	if get_distance() <= get_current_max_length():
		knob_position = get_local_touch_pos()
	else:
		# calculates the angle position of the knob if it's position --
		# -- exceeds from the current max length
		var angle := get_center_pos().angle_to_point(get_global_mouse_position())
		knob_position.x = (get_center_pos().x + cos(angle) * get_current_max_length()) - get_center_pos().x
		knob_position.y = (get_center_pos().y + sin(angle) * get_current_max_length()) - get_center_pos().y
		


# triggers an specific input action based on the --
# -- current direction
func trigger_input_actions() -> void:
	
	var dir := get_deadzoned_vector().normalized()
	
	if dir.x > 0:
		Input.action_release(action_left)
		Input.action_press(action_right, dir.x)
	else:
		Input.action_release(action_right)
		Input.action_press(action_left, -dir.x)
	
	if dir.y < 0:
		Input.action_release(action_down)
		Input.action_press(action_up, -dir.y)
	else:
		Input.action_release(action_up)
		Input.action_press(action_down, dir.y)

# releases all input actions
func release_input_actions() -> void:
	Input.action_release(action_right)
	Input.action_release(action_left)
	Input.action_release(action_up)
	Input.action_release(action_down)

# resets knob position if not pressing
func reset_knob_pos() -> void:
	if smooth_reset:
		knob_position = lerp(knob_position, Vector2.ZERO, smooth_speed * get_process_delta_time())
	else:
		knob_position = Vector2.ZERO

func _validate_property(property: Dictionary) -> void:
	validitate_default_drawing_properties(property)
	validitate_texture_drawing_properties(property)
	validitate_input_action_properties(property)
	if property.name == "smooth_speed" and not smooth_reset:
		property.usage = PROPERTY_USAGE_READ_ONLY
	
	if property.name == "from_opacity" and not change_opacity_when_touched:
		property.usage = PROPERTY_USAGE_READ_ONLY
	
	if property.name == "to_opacity" and not change_opacity_when_touched:
		property.usage = PROPERTY_USAGE_READ_ONLY
	
	if property.name == "deadzone_color" and not draw_debugs:
		property.usage = PROPERTY_USAGE_READ_ONLY
	
	if property.name == "current_max_length_color" and not draw_debugs:
		property.usage = PROPERTY_USAGE_READ_ONLY



func validitate_input_action_properties(property : Dictionary) -> void:
	if property.name == "action_left" and not use_input_actions:
		property.usage = PROPERTY_USAGE_READ_ONLY
	
	if property.name == "action_right" and not use_input_actions:
		property.usage = PROPERTY_USAGE_READ_ONLY
	
	if property.name == "action_up" and not use_input_actions:
		property.usage = PROPERTY_USAGE_READ_ONLY
	
	if property.name == "action_down" and not use_input_actions:
		property.usage = PROPERTY_USAGE_READ_ONLY

func validitate_default_drawing_properties(property : Dictionary) -> void:
	if property.name == "base_color" and use_textures:
		property.usage = PROPERTY_USAGE_READ_ONLY
	
	if property.name == "knob_color" and use_textures:
		property.usage = PROPERTY_USAGE_READ_ONLY
	
	if property.name == "background_color" and use_textures:
		property.usage = PROPERTY_USAGE_READ_ONLY
	
	if property.name == "base_radius" and use_textures:
		property.usage = PROPERTY_USAGE_READ_ONLY
	
	
	if property.name == "knob_radius" and use_textures:
		property.usage = PROPERTY_USAGE_READ_ONLY
	
	if property.name == "thickness" and use_textures:
		property.usage = PROPERTY_USAGE_READ_ONLY
	
	if property.name == "anti_aliased" and use_textures:
		property.usage = PROPERTY_USAGE_READ_ONLY
		

func validitate_texture_drawing_properties(property : Dictionary) -> void:
	
	
	if property.name == "background_texture" and not use_textures:
		property.usage = PROPERTY_USAGE_READ_ONLY
	
	if property.name == "use_custom_max_length" and not use_textures:
		property.usage = PROPERTY_USAGE_READ_ONLY
	
	if property.name == "max_length" and not use_textures:
		property.usage = PROPERTY_USAGE_READ_ONLY
	
	if property.name == "max_length" and not use_custom_max_length:
		property.usage = PROPERTY_USAGE_READ_ONLY
	
	if property.name == "base_texture" and not use_textures:
		property.usage = PROPERTY_USAGE_READ_ONLY
	
	if property.name == "knob_texture" and not use_textures:
		property.usage = PROPERTY_USAGE_READ_ONLY
	

func _draw() -> void:
	if not use_textures:
		draw_default_joystick()
	else:
		draw_textured_joystick()
	
	if draw_debugs:
		draw_debug()

func draw_default_joystick() -> void:
	
	draw_set_transform(size / 2)
	# background
	draw_circle(Vector2.ZERO, base_radius, background_color, true, -1.0, anti_aliased)
	
	# base
	draw_circle(Vector2.ZERO, base_radius, base_color, false, thickness, anti_aliased)
	var pos := knob_position
	# knob
	draw_circle(pos, knob_radius, knob_color, true, -1.0, anti_aliased)


func draw_textured_joystick() -> void:
	
	if background_texture:
		var centered_base_pos := size / 2 - (base_texture.get_size() / 2)
		draw_set_transform(centered_base_pos)
		draw_texture_rect(background_texture, Rect2(Vector2.ZERO, base_texture.get_size()), false)
	
	# draw textured base
	if base_texture:
		var centered_base_pos := size / 2 - (base_texture.get_size() / 2)
		
		size.x = clamp(size.x, base_texture.get_size().x, INF)
		size.y = clamp(size.y, base_texture.get_size().y, INF)
		draw_set_transform(centered_base_pos)
		draw_texture_rect(base_texture, Rect2(Vector2.ZERO, base_texture.get_size()), false)
		
	# draw texture knob
	
	if knob_texture:
		var centered_knob_pos := (Vector2.ZERO - knob_texture.get_size() / 2) + size / 2
		
		draw_set_transform(centered_knob_pos)
		draw_texture_rect(knob_texture, Rect2(knob_position, knob_texture.get_size()), false)

	

func draw_debug() -> void:
	draw_set_transform(size / 2)
	# draw deadzone
	
	draw_circle(Vector2.ZERO, deadzone, deadzone_color, false, 1.0, true)
	
	# draw current max length
	draw_circle(Vector2.ZERO, get_current_max_length(), current_max_length_color, false, 1.0, true)
	
	draw_circle(knob_position, 10, Color.RED, true, -1.0, true)
	


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var is_touching := event.pressed and get_global_rect().has_point(event.position) as bool
		
		if is_touching:
			on_touched(event)
		else:
			on_touch_released(event)


func on_touched(event: InputEventScreenTouch) -> void:
	is_pressing = true
	finger_index = event.index
	change_opacity()
	var mouse_pos := get_global_mouse_position() - size / 2
	if mode == 1 and event.index == finger_index and get_global_rect().has_point(mouse_pos):
		position = mouse_pos
	#update_input_actions()

func on_touch_released(event: InputEventScreenTouch) -> void:
	if event.index == finger_index:
		is_pressing = false
		if mode == 1:
			position = default_pos
		change_opacity()
		#update_input_actions()


func update_input_actions() -> void:
	if use_input_actions and is_pressing:
		trigger_input_actions()
	else:
		release_input_actions()

func get_vector() -> Vector2:
	return get_center_pos().direction_to(knob_position + get_center_pos())


func get_deadzoned_vector() -> Vector2:
	var vector : Vector2
	if is_pressing and not is_in_deadzone():
		vector = get_center_pos().direction_to(knob_position + get_center_pos())
	else:
		vector = Vector2.ZERO
	return vector

func get_center_pos() -> Vector2:
	return position + size / 2

func get_local_touch_pos() -> Vector2: 
	return (get_global_mouse_position() - get_center_pos()) / scale.x

func get_distance() -> float:
	return get_global_mouse_position().distance_to(get_center_pos()) / scale.x

# get the current max length of the knob's position. --
# -- if you use textures, the current max length will --
# -- automatically set to the half base texture's width
func get_current_max_length() -> float:
	var curr_max_length : float
	if not use_textures:
		curr_max_length = base_radius
	else:
		if use_custom_max_length:
			curr_max_length = max_length
		elif not use_custom_max_length and base_texture:
			curr_max_length = base_texture.get_size().x / 2
	
	return curr_max_length

# changes the opacity when touched
func change_opacity() -> void:
	if change_opacity_when_touched and not Engine.is_editor_hint():
		if is_pressing:
			modulate.a = to_opacity / 100.0
		else:
			modulate.a = from_opacity / 100.0
	else:
		modulate.a = 1.0

func is_in_deadzone() -> bool:
	return get_distance() <= deadzone
