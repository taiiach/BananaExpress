extends CanvasLayer

@onready var label_fbro: Label = $ColorRect/CenterContainer/VBoxContainer/fbro
@onready var label_metry: Label = $ColorRect/CenterContainer/VBoxContainer/Label2
@onready var line_edit: LineEdit = $ColorRect/CenterContainer/VBoxContainer/HBoxContainer/LineEdit
@onready var save_button: Button = $ColorRect/CenterContainer/VBoxContainer/Button
@onready var scoreboard: VBoxContainer = $ColorRect/CenterContainer/VBoxContainer/VBoxContainer
@onready var restart_button: Button = $ColorRect/CenterContainer/VBoxContainer/restart

@export var transition_player_path: NodePath
@onready var transition_anim := get_node(transition_player_path).get_node("TransitionPlayer")

var current_distance := 0.0

var current_skipped := 0

func _ready():
	visible = false
	save_button.pressed.connect(_on_save_pressed)
	restart_button.pressed.connect(_on_restart_pressed)

func show_gameover(distance: float, wagons: int):
	current_distance = distance
	current_skipped = wagons
	label_metry.text = "Uletěl jsi %.2f m\nPřeskočil jsi %d vagónů" % [distance, wagons]
	visible = true
	line_edit.grab_focus()

func _on_save_pressed():
	var playername = line_edit.text.strip_edges()
	if playername == "":
		playername = "Anonym"
		Hra.save_score(current_distance, playername)  # předpoklad, že máš Game singleton (nebo to přepíšeme)
	else:
		Hra.save_score(current_distance, playername)

	update_scoreboard()
	save_button.disabled = true

func update_scoreboard():
	scoreboard.get_node("Label4").text = "1. %s" % Hra.get_score_string(0)
	scoreboard.get_node("Label5").text = "2. %s" % Hra.get_score_string(1)
	scoreboard.get_node("Label6").text = "3. %s" % Hra.get_score_string(2)

func _on_restart_pressed():
	transition_anim.play("blesk")
	await transition_anim.animation_finished
	get_tree().reload_current_scene()

func do_restart():
	get_tree().reload_current_scene()
