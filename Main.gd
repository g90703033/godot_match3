extends Node2D
	
@export var unit = 100
@export var gridRangeX = Vector2(-5, 5)
@export var gridRangeY = Vector2(-5, 5)
@export var speed = 150

@export var s_cube : PackedScene

func get_range(range:Vector2):
	return range.y - range.x + 1

# Called when the node enters the scene tree for the first time.
func _ready():
	var array = create_random_2dintarray(get_range(gridRangeX), get_range(gridRangeY), [1,2,4])#gridRangeX.y, gridRangeY.y)
	create_cube_array_from_data(array, gridRangeX, gridRangeY, Vector2(0,0))

#
#	for i in range(gridRangeX.x, gridRangeX.y + 1):
#		print(str(i))
#		for j in range(gridRangeY.x, gridRangeY.y + 1):
#			create_cube(i, j, Vector2(0, 0))
#
#	print(create2d(7,5, [1,2,4]))

func create_random_2dintarray(x:int, y:int,set)->Array:
	var result = []
	
	for _x in range(0, x):
		result.append([])
		for _y in range(0, y):
			result[_x].append(get_random(set))
	
	return result
	

func get_random(set:Array):
	var index = randi() % set.size()
	return set[index]
	

func create_cube_array_from_data(array2d, rangeX:Vector2, rangeY:Vector2, init=Vector2.ZERO):
	var baseX = 0
	if rangeX.x < 0 : 
		baseX = abs(rangeX.x)
	var baseY = 0
	if rangeY.x < 0 : 
		baseY = abs(rangeY.x)
	
	for _x in range(rangeX.x, rangeX.y+1):
		for _y in range(rangeY.x, rangeY.y+1):
			var cube = create_cube(_x, _y, init)
			cube.change_color_by_int(array2d[baseX + _x][baseY + _y])
			
	
func create_cube(x, y, init = Vector2.ZERO):
	var cube = s_cube.instantiate() # Replace with function body.
	cube.name = "name_"+str(x)+"_"+str(y)
	add_child(cube)
	cube.position = Vector2(x, y) * unit + init
	
	return cube

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
		
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos = get_global_mouse_position()
			print("mouse left pressed")
