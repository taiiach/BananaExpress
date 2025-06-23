extends Node2D

@export var movement_speed := 800.0
@export var wagon_scene: PackedScene
@export var wagon_spacing := 150.0
@export var min_wagons := 6
@export var wagon_width := 970.0
@export var wagon_y := 200  # výška, kam umístit vagóny

var is_moving := false

func _ready():
	_generate_initial_wagons()

func _process(delta):
	if is_moving:
		for car in get_children():
			car.position.x -= movement_speed * delta
	_check_for_generation()

func set_moving(value: bool):
	is_moving = value

func _generate_initial_wagons():
	for i in range(min_wagons):
		_spawn_wagon_at(i * (wagon_width + wagon_spacing))

func _spawn_wagon_at(x_pos: float):
	if wagon_scene:
		var new_wagon = wagon_scene.instantiate()
		new_wagon.position = Vector2(x_pos, wagon_y)
		add_child(new_wagon)

func _check_for_generation():
	var rightmost_x := -INF
	for car in get_children():
		if car.position.x > rightmost_x:
			rightmost_x = car.position.x

	var screen_edge = get_viewport().get_visible_rect().size.x
	if rightmost_x < screen_edge:
		_spawn_wagon_at(rightmost_x + wagon_width + wagon_spacing)
