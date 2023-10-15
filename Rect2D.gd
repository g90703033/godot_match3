extends Node2D

enum CubeType {
	Red,
	Green,
	Yellow
}

@export var cubeType : CubeType = CubeType.Red
var instance_material
var tween

# Called when the node enters the scene tree for the first time.
func _ready():
	instance_material = $Sprite2D.get_material().duplicate()
	$Sprite2D.set_material(instance_material)
	tween = create_tween()

func change_color_by_int(value:int):
	match value:
		1: instance_material.set("shader_param/hue_shift", 0.864)
		2: instance_material.set("shader_param/hue_shift", 0.15)
		3: instance_material.set("shader_param/hue_shift", 0.05)
		4: instance_material.set("shader_param/hue_shift", 0.45)
	

func change_color(cubeType:CubeType):
	var color = Color.WHITE
	
	match cubeType:
		CubeType.Red: instance_material.set("shader_param/hue_shift", 0.864)
		CubeType.Green: instance_material.set("shader_param/hue_shift", 0.15)
		CubeType.Yellow: instance_material.set("shader_param/hue_shift", 0.05)
	#on_selected()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#translate(Vector2(100,0)*delta)
	pass

func move_to(world_position: Vector2, duration: float)->void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "position", world_position, duration)

func move(delta: Vector2)->void:
	translate(delta)

func on_selected():
	instance_material.set("shader_param/tint", Vector4(2, 2, 2, 1))
	
func on_diselected():	
	instance_material.set("shader_param/tint", Vector4(1, 1, 1, 1))
