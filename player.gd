extends CharacterBody2D

const GRAVITY = 1200.0
const MAX_HOLD_TIME = 1.3
const BASE_JUMP_STRENGTH = -400.0
const MAX_JUMP_STRENGTH = -1000.0
const DEATH_Y_THRESHOLD = 900.0  # kdy hráč spadne pod mapu

@export var jump_curve: Curve
@export var transition_curve: Curve
@export var train: NodePath
@export var background: NodePath
@export var ui: NodePath
@export var gameover: NodePath

@export var parallax_speed_air := 200.0
@export var parallax_speed_ground := 1000.0
@export var transition_duration := 0.3

@onready var train_node := get_node(train)
@onready var background_node := get_node(background)
@onready var ui_node := get_node(ui)
@onready var gameover_node := get_node(gameover)
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var charge_sound: AudioStreamPlayer = $ChargeSound
@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var banana_collect_sound: AudioStreamPlayer = $BananaSound



var hold_time := 0.0
var charging := false
var was_on_floor := true
var distance_traveled := 0.0

var parallax_timer := 0.0
var parallax_active := false
var parallax_from := 0.0
var parallax_to := 0.0

var is_dead := false

var last_wagon_x := 0.0
var wagons_skipped := 0
var last_wagon_id: int = -1

func _physics_process(delta):
	train_node.increase_difficulty(distance_traveled)
	if is_dead:
		return

	velocity.y += GRAVITY * delta

	# UI vzdálenost přičítaná podle aktuální rychlosti pozadí
	if train_node.is_moving:
		var movement_speed: float = background_node.get_current_speed()
		var gain = movement_speed * delta / 100.0
		distance_traveled += gain
		ui_node.add_distance(gain)

	# smrt při pádu dolů
	if global_position.y > DEATH_Y_THRESHOLD:
		die()
		return

	# SKOK
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		charging = true
		hold_time = 0.0
		sprite.play("char_jump")
		charge_sound.play()

	if Input.is_action_pressed("ui_accept") and charging:
		hold_time = min(hold_time + delta, MAX_HOLD_TIME)

	if Input.is_action_just_released("ui_accept") and charging:
		charging = false
		charge_sound.stop()
		
		var t = hold_time / MAX_HOLD_TIME
		var curved = jump_curve.sample(t)
		var jump_force = lerp(BASE_JUMP_STRENGTH, MAX_JUMP_STRENGTH, curved)
		velocity.y = jump_force

		jump_sound.play()
		train_node.set_moving(true)
		start_parallax_transition(background_node.get_current_speed(), parallax_speed_air)

	var now_on_floor = is_on_floor()
	if not was_on_floor and now_on_floor:
		train_node.set_moving(false)
		start_parallax_transition(background_node.get_current_speed(), parallax_speed_ground)

	was_on_floor = now_on_floor

	move_and_slide()

	# ANIMACE
	if not charging:
		if not is_on_floor():
			sprite.play("char_midair")
		elif not was_on_floor and now_on_floor:
			sprite.play("char_landing")
		elif not sprite.is_playing() or sprite.animation != "char_idle":
			sprite.play("char_idle")

	# Plynulé zpomalování parallaxu
	if parallax_active:
		parallax_timer += delta
		var t = clamp(parallax_timer / transition_duration, 0.0, 1.0)
		var curved = transition_curve.sample(t)
		var new_speed = lerp(parallax_from, parallax_to, curved)
		background_node.set_parallax_speed(new_speed)

		if t >= 1.0:
			parallax_active = false

func start_parallax_transition(from_speed: float, to_speed: float):
	parallax_timer = 0.0
	parallax_from = from_speed
	parallax_to = to_speed
	parallax_active = true

func die():
        is_dead = true
        gameover_node.show_gameover(distance_traveled, wagons_skipped)

func register_wagon(id: int):
        if id != last_wagon_id:
                wagons_skipped += 1
                last_wagon_id = id

func collect_banana(amount: int = 1):
        ui_node.add_banana(amount)
        if banana_collect_sound:
                banana_collect_sound.play()
