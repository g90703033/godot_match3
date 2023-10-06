extends Node2D
	
@export var unit = 100.0
@export var gridRangeX = Vector2(-5, 5)
@export var gridRangeY = Vector2(-5, 5)
@export var speed = 150

@export var s_cube : PackedScene

var data_array
var cube_array
var inited:bool =false
var prev_selected

# Called when the node enters the scene tree for the first time.
func _ready():
	data_array = create_random_2dintarray(get_range(gridRangeX), get_range(gridRangeY), [1,2,4])#gridRangeX.y, gridRangeY.y)
	cube_array = create_cube_array_from_data(data_array, gridRangeX, gridRangeY, Vector2(0,0))
	inited = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if not inited:
		return	
		
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
			
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos = get_global_mouse_position()
			print("mouse left pressed")
			
		
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:
			random_2dintarray(data_array, get_range(gridRangeX), get_range(gridRangeY), [1,2,4])
			update_cube_array_from_data(data_array, gridRangeX, gridRangeY, Vector2(0,0))



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
