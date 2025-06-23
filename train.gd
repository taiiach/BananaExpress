extends Node2D

@export var movement_speed := 800.0
@export var wagon_scene: PackedScene
@export var wagon_spacing := 150.0
@export var min_wagons := 6
@export var wagon_width := 970.0
@export var wagon_y := 200  # výška, kam umístit vagóny
@export var obstacle_scenes: Array[PackedScene] = []
@export var banana_scene: PackedScene
@export var banana_chance := 0.3

var is_moving := false
var obstacle_chance := 0.2  # Začíná na 20%
var current_distance := 0.0

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

                # Zkus generovat překážku
                if obstacle_scenes.size() > 0 and randf() < obstacle_chance:
                        var spawn_point := new_wagon.get_node_or_null("ObstacleSpawn")
                        if spawn_point:
                                var obstacle_scene := obstacle_scenes[randi() % obstacle_scenes.size()]
                                var obstacle = obstacle_scene.instantiate()
                                spawn_point.add_child(obstacle)

                # Zkus generovat banán
                if banana_scene and randf() < banana_chance:
                        var spawn_banana := new_wagon.get_node_or_null("ObstacleSpawn")
                        if spawn_banana:
                                var stack := 1 + int(current_distance / 500.0)
                                for i in range(stack):
                                        var banana = banana_scene.instantiate()
                                        banana.position.y -= i * 20
                                        spawn_banana.add_child(banana)

func _check_for_generation():
	var rightmost_x := -INF
	for car in get_children():
		if car.position.x > rightmost_x:
			rightmost_x = car.position.x

	var screen_edge = get_viewport().get_visible_rect().size.x
	if rightmost_x < screen_edge:
		_spawn_wagon_at(rightmost_x + wagon_width + wagon_spacing)

func increase_difficulty(distance: float):
        # Zvýšíme pravděpodobnost, ale max na 90 %
        obstacle_chance = clamp(0.2 + distance / 3000.0, 0.2, 0.9)
        current_distance = distance
