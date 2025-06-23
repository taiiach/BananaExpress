extends Node2D

@export var default_scroll_speed := 1000.0
var current_scroll_speed := 1000.0

var sprite_a: Sprite2D
var sprite_b: Sprite2D
const SPRITE_WIDTH := 1278  # šířka obrázku pozadí

func _ready():
	current_scroll_speed = default_scroll_speed
	sprite_a = $bg1
	sprite_b = $bg2

	# nastav výchozí pozice
	sprite_a.position = Vector2(0, 0)
	sprite_b.position = Vector2(SPRITE_WIDTH, 0)

func _process(delta):
	sprite_a.position.x -= current_scroll_speed * delta
	sprite_b.position.x -= current_scroll_speed * delta

	# loop pozadí
	if sprite_a.position.x <= -SPRITE_WIDTH:
		sprite_a.position.x = sprite_b.position.x + SPRITE_WIDTH

	if sprite_b.position.x <= -SPRITE_WIDTH:
		sprite_b.position.x = sprite_a.position.x + SPRITE_WIDTH

func set_parallax_speed(value: float):
	current_scroll_speed = value

func get_current_speed() -> float:
	return current_scroll_speed
