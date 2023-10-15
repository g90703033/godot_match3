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
var match_data_array
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
	data_array = create_random_array2d_data(get_range(gridRangeX), get_range(gridRangeY), [1,2,4])#gridRangeX.y, gridRangeY.y)
	match_data_array = create_array2d(get_range(gridRangeX), get_range(gridRangeY), 0)
	cube_array = create_cube_array_from_data(data_array, gridRangeX, gridRangeY, Vector2(0,0))
	inited = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if not inited:
		return	
	
	if event is InputEventKey:
		if event.keycode == KEY_M:
			if event.is_pressed():
				find_all_matches(3)
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				switch_control_mode(e_control_mode.selected)
				
			elif event.is_released():
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
	
	var prev_mode = control_mode 
	
	if new_mode == e_control_mode.browse:
		if prev_selected != null:
			cube_array[prev_selected.x][prev_selected.y].on_diselected()
			prev_selected = null
			
			# check swap success or not
			if prev_mode == e_control_mode.selected:
				var position = world_position_in_range(get_global_mouse_position())
				var result = get_grid_position(position, Vector2(0, 0))
				
				if result.x == origin_grid_position.x && result.y == origin_grid_position.y:
					selected_cube.move_to(get_world_position(origin_grid_position, Vector2(0,0)), 0.2)
					if prev_swap_cube:
						prev_swap_cube.move_to(get_world_position(prev_swap_grid_position, Vector2(0,0)), 0.2)
				elif prev_swap_cube:
					selected_cube.move_to(get_world_position(prev_swap_grid_position, Vector2(0,0)), 0.2)
					prev_swap_cube.move_to(get_world_position(origin_grid_position, Vector2(0,0)), 0.2)
					swap_data(origin_grid_position, prev_swap_grid_position)
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

func find_all_matches(num):
	fill_array2d(match_data_array, grid_length_x(), grid_length_y())
	#find horizontal (3, 1)array match
	for _y in range(0, grid_length_y()):
		
		for _x in range(0, grid_length_x() - num + 1):
			var link = true
			for i in range(0, num-1):
				link = (link and (data_array[_x+i][_y] == data_array[_x+i+1][_y]))
				
			if link:
				for i in range(0, num):
					match_data_array[_x+i][_y] = 1
		
	#find horizontal (1, 3)array match
	
	for _x in range(0, grid_length_x()):
		for _y in range(0, grid_length_y()-num + 1):
			var link = true
			for i in range(0, num-1):
				link = (link and (data_array[_x][_y+i] == data_array[_x][_y+i+1]))
			if link:
				for i in range(0, num):
					match_data_array[_x][_y+i] = 1
	
	#destroy all matches
	for _x in range(0, grid_length_x()):
		for _y in range(0, grid_length_y()):
			if match_data_array[_x][_y] == 1:
				cube_array[_x][_y].queue_free()

func swap_data(n1, n2):
	var temp = cube_array[n1.x][n1.y]
	cube_array[n1.x][n1.y] = cube_array[n2.x][n2.y]
	cube_array[n2.x][n2.y] = temp
	
	var temp1 = data_array[n1.x][n1.y]
	data_array[n1.x][n1.y] = data_array[n2.x][n2.y]
	data_array[n2.x][n2.y] = temp1

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
		
		direction.y = 0
		delta.y = 0
		new_axis = e_move_axis.x
	else:
		if direction.y > 0:
			grid_direction.y = 1
		elif direction.y < 0:
			grid_direction.y = -1
		
		direction.x = 0
		delta.x = 0
		new_axis = e_move_axis.y
	
	var next_swap_grid_position = origin_grid_position + grid_direction
	var next_swap_world_position = get_world_position(next_swap_grid_position, Vector2(0,0))
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
	
	
	next_swap_cube.move_to(next_swap_world_position - direction -delta, 0)
	prev_swap_cube = next_swap_cube
	prev_swap_grid_position = next_swap_grid_position

func is_switch_axis(new_axis: e_move_axis):
	var result = false
	
	if prev_swap_axis == e_move_axis.x && new_axis == e_move_axis.y:
		result = true
	if prev_swap_axis == e_move_axis.y && new_axis == e_move_axis.x:
		result = true
		
	return result

func create_random_array2d_data(x:int, y:int,set)->Array:
	var result = []
	
	for _x in range(0, x):
		result.append([])
		for _y in range(0, y):
			result[_x].append(get_random(set))
	
	return result

func create_array2d(x:int, y:int, value = 0):
	var result = []
	
	for _x in range(0, x):
		result.append([])
		for _y in range(0, y):
			result[_x].append(value)
	
	return result

func fill_array2d(result, x:int, y:int, value = 0):

	for _x in range(0, x):
		for _y in range(0, y):
			result[_x][_y] = value
	
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
	
func get_range(range:Vector2):
	return range.y - range.x + 1

func get_world_position(grid_position:Vector2, init:Vector2)->Vector2:
	return world_position_in_range(grid_position - Vector2(abs(gridRangeX.x), abs(gridRangeY.x))) * unit + init

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

func vec_clamp_by_length(input:Vector2, length:float)->Vector2:
	if input.length() > length:
		return input.normalized() * length
	return input

