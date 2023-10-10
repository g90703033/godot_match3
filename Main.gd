extends Node2D
	
@export var unit = 100.0
@export var gridRangeX = Vector2(-5, 5)
@export var gridRangeY = Vector2(-5, 5)
@export var speed = 150

@export var s_cube : PackedScene

enum e_control_mode{
	browse,
	selected
}

enum e_move_axis{
	none,
	x,
	y
}

var data_array
var cube_array
var inited:bool =false

var control_mode = e_control_mode.browse
# control mode : browse
var prev_selected
var selected = false
# control mode : selected
var selected_cube
var origin_grid_position
var origin_world_position
var prev_selected_position:Vector2

var prev_swap_cube
var next_swap_cube
var prev_swap_grid_position
var prev_swap_axis = e_move_axis.none

# Called when the node enters the scene tree for the first time.
func _ready():
	data_array = create_random_2dintarray(get_range(gridRangeX), get_range(gridRangeY), [1,2,4])#gridRangeX.y, gridRangeY.y)
	cube_array = create_cube_array_from_data(data_array, gridRangeX, gridRangeY, Vector2(0,0))
	inited = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if not inited:
		return	
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				print("mouse left pressed")
				switch_control_mode(e_control_mode.selected)
				
			elif event.is_released():
				print("mouse left release")
				switch_control_mode(e_control_mode.browse)
	
	
	if control_mode == e_control_mode.browse:
		update_mode_browse()
	elif control_mode == e_control_mode.selected:
		update_mode_selected()
			
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:
			random_2dintarray(data_array, get_range(gridRangeX), get_range(gridRangeY), [1,2,4])
			update_cube_array_from_data(data_array, gridRangeX, gridRangeY, Vector2(0,0))

func switch_control_mode(new_mode):

	if control_mode == new_mode:
		return
	
	if new_mode == e_control_mode.browse:
		if prev_selected != null:
			cube_array[prev_selected.x][prev_selected.y].on_diselected()
			prev_selected = null
			
			# check swap success or not
			if control_mode == e_control_mode.selected:
				var result = get_grid_position(get_global_mouse_position(), Vector2(0, 0))

				#if result == origin_grid_position:
				selected_cube.move_to(get_world_position(origin_grid_position, Vector2(0,0)), 0.2)
				prev_swap_cube.move_to(get_world_position(prev_swap_grid_position, Vector2(0,0)), 0.2)
#				else:
#					selected_cube.move_to(get_world_position(prev_swap_grid_position, Vector2(0,0)), 0.2)
#					prev_swap_cube.move_to(get_world_position(origin_grid_position, Vector2(0,0)), 0.2)
				#[TODO]: swap data	
	elif new_mode == e_control_mode.selected:	
		var result = get_grid_position(get_global_mouse_position(), Vector2(0, 0))
		prev_swap_cube = null
		
		if not in_range(result):
			return -1
		prev_selected_position = get_global_mouse_position()
		selected_cube = cube_array[result.x][result.y]
		origin_grid_position = result
		origin_world_position = get_world_position(result, Vector2(0,0))
	
	control_mode = new_mode
	
	return 0

func update_mode_browse():
	var result = get_grid_position(get_global_mouse_position(), Vector2(0, 0))
	
	if in_range(result):
		
		var selectedCube = cube_array[result.x][result.y]

		if selectedCube != null:
			if prev_selected != null:
				cube_array[prev_selected.x][prev_selected.y].on_diselected()
			selectedCube.on_selected()
			prev_selected = result
	else:
		if prev_selected != null:
			cube_array[prev_selected.x][prev_selected.y].on_diselected()
			prev_selected = null

func update_mode_selected():
	
	
	var cur_mouse_position = world_position_in_range(get_global_mouse_position())
	var direction = cur_mouse_position - origin_world_position
	var grid_direction = Vector2(0, 0)
	var new_axis = e_move_axis.none
	
	#calculate new delta with clamp
	direction = vec_clamp_by_length(direction, unit)
	var delta = origin_world_position + direction - selected_cube.position	
	
	# determine to move in which direction
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			grid_direction.x = 1
		elif direction.x < 0:
			grid_direction.x = -1
			
		delta.y = 0
		new_axis = e_move_axis.x
	else:
		if direction.y > 0:
			grid_direction.y = 1
		elif direction.y < 0:
			grid_direction.y = -1
			
		delta.x = 0
		new_axis = e_move_axis.y
	
	var next_swap_grid_position = origin_grid_position + grid_direction
	var next_swap_cube = cube_array[next_swap_grid_position.x][next_swap_grid_position.y]
	
	# when change to another axis move, adjust back the shift of previous axis
	var switch_new_axis = is_switch_axis(new_axis)
	
	if switch_new_axis:
		var origin_position = get_world_position(origin_grid_position, Vector2(0, 0))
		var offset = selected_cube.position - origin_position
			
		if prev_swap_axis == e_move_axis.x:
			selected_cube.translate(Vector2(-offset.x, 0))
		if prev_swap_axis == e_move_axis.y:
			selected_cube.translate(Vector2(0, -offset.y))
		
	prev_swap_axis = new_axis
	
	###### swap back
	
	# translate selected cube by delta of mouse position changing
	prev_selected_position = cur_mouse_position
	selected_cube.translate(delta)
	
	# when change to another direction, reset previous one back to origin position
	if prev_swap_cube != null && next_swap_grid_position != prev_swap_grid_position:
		prev_swap_cube.move_to(get_world_position(prev_swap_grid_position, Vector2(0,0)), 0.2)
	
	next_swap_cube.translate(-delta)
	prev_swap_cube = next_swap_cube
	prev_swap_grid_position = next_swap_grid_position

func vec_clamp_by_length(input:Vector2, length:float)->Vector2:
	if input.length() > length:
		return input.normalized() * length
	return input

func is_switch_axis(new_axis: e_move_axis):
	var result = false
	
	if prev_swap_axis == e_move_axis.x && new_axis == e_move_axis.y:
		result = true
	if prev_swap_axis == e_move_axis.y && new_axis == e_move_axis.x:
		result = true
		
	return result

func create_random_2dintarray(x:int, y:int,set)->Array:
	var result = []
	
	for _x in range(0, x):
		result.append([])
		for _y in range(0, y):
			result[_x].append(get_random(set))
	
	return result

func random_2dintarray(array2d, x:int, y:int, set):
	for _x in range(0, x):
		for _y in range(0, y):
			array2d[_x][_y] = get_random(set)
	

func create_cube_array_from_data(array2d, rangeX:Vector2, rangeY:Vector2, init=Vector2.ZERO):
	var result = []
	var baseX = 0
	if rangeX.x < 0 : 
		baseX = abs(rangeX.x)
	var baseY = 0
	if rangeY.x < 0 : 
		baseY = abs(rangeY.x)
	
	for _x in range(rangeX.x, rangeX.y+1):
		result.append([])
		for _y in range(rangeY.x, rangeY.y+1):
			var cube = create_cube(_x, _y, init)
			cube.change_color_by_int(array2d[_x + baseX][_y + baseY])
			result[_x + baseX].append(cube)
			#cube_array[_x][_y] = cube
	return result

func update_cube_array_from_data(array2d, rangeX:Vector2, rangeY:Vector2, init=Vector2.ZERO):
	var baseX = 0
	if rangeX.x < 0 : 
		baseX = abs(rangeX.x)
	var baseY = 0
	if rangeY.x < 0 : 
		baseY = abs(rangeY.x)
	
	for _x in range(rangeX.x, rangeX.y+1):
		for _y in range(rangeY.x, rangeY.y+1):
			cube_array[_x][_y].change_color_by_int(array2d[baseX + _x][baseY + _y])
	
func create_cube(x, y, init = Vector2.ZERO):
	var cube = s_cube.instantiate() # Replace with function body.
	cube.name = "name_"+str(x)+"_"+str(y)
	add_child(cube)
	cube.position = Vector2(x, y) * unit + init
	
	return cube


func get_random(set:Array):
	var index = randi() % set.size()
	return set[index]
	
static func get_range(range:Vector2):
	return range.y - range.x + 1

func get_world_position(grid_position:Vector2, init:Vector2)->Vector2:
	return (grid_position - Vector2(abs(gridRangeX.x), abs(gridRangeY.x))) * unit + init

func get_grid_position(world_position:Vector2, init:Vector2)->Vector2:
	var re_centered = world_position - init
	var baseX = 0
	if gridRangeX.x < 0 : 
		baseX = abs(gridRangeX.x)
	var baseY = 0
	if gridRangeY.x < 0 : 
		baseY = abs(gridRangeY.x)
	
	return Vector2(floor(re_centered.x/unit + 0.5) + baseX, floor(re_centered.y/unit+0.5) + baseY)

func in_range(grid_position:Vector2)->bool:
	var x_in_range = grid_position.x >= 0 and grid_position.x < grid_length_x() 
	var y_in_range = grid_position.y >= 0 and grid_position.y < grid_length_y()
	
	return x_in_range and y_in_range 
	
	
func grid_length_x()->int:
	if gridRangeX.x < 0:
		return abs(gridRangeX.x) + gridRangeX.y + 1
	else:
		return gridRangeX.y - gridRangeX.x + 1

func grid_length_y()->int:
	if gridRangeY.x < 0:
		return abs(gridRangeY.x) + gridRangeY.y + 1
	else:
		return gridRangeY.y - gridRangeY.x + 1

func world_position_in_range(world_position:Vector2):
	world_position.x = clamp(world_position.x , unit * gridRangeX.x, unit * gridRangeX.y)
	world_position.y = clamp(world_position.y , unit * gridRangeY.x, unit * gridRangeY.y)
	return world_position
