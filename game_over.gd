extends CanvasLayer

@onready var label_fbro: Label = $ColorRect/CenterContainer/VBoxContainer/fbro
@onready var label_metry: Label = $ColorRect/CenterContainer/VBoxContainer/Label2
@onready var line_edit: LineEdit = $ColorRect/CenterContainer/VBoxContainer/HBoxContainer/LineEdit
@onready var save_button: Button = $ColorRect/CenterContainer/VBoxContainer/Button
@onready var scoreboard: VBoxContainer = $ColorRect/CenterContainer/VBoxContainer/VBoxContainer
@onready var restart_button: Button = $ColorRect/CenterContainer/VBoxContainer/restart

# Container for dynamically created achievement buttons
var achievements_container: VBoxContainer

# Definitions for achievements
const ACHIEVEMENTS := [
	{"label": "100m", "type": "distance", "value": 100.0},
	{"label": "250m", "type": "distance", "value": 250.0},
	{"label": "500m", "type": "distance", "value": 500.0},
	{"label": "750m", "type": "distance", "value": 750.0},
	{"label": "1000m", "type": "distance", "value": 1000.0},
	{"label": "10 bananas", "type": "bananas", "value": 10},
	{"label": "50 bananas", "type": "bananas", "value": 50},
	{"label": "100 bananas", "type": "bananas", "value": 100},
]

var achievement_buttons: Array = []

@export var transition_player_path: NodePath
@onready var transition_anim := get_node(transition_player_path).get_node("TransitionPlayer")

var current_distance := 0.0

var current_skipped := 0

func _ready():
		visible = false
		save_button.pressed.connect(_on_save_pressed)
		restart_button.pressed.connect(_on_restart_pressed)

		# Build achievements UI
		achievements_container = VBoxContainer.new()
		$ColorRect/CenterContainer/VBoxContainer.add_child(achievements_container)
		for ach in ACHIEVEMENTS:
				var btn := Button.new()
				btn.text = ach["label"]
				btn.disabled = true
				achievements_container.add_child(btn)
				achievement_buttons.append(btn)

func show_gameover(distance: float, wagons: int):
		current_distance = distance
		current_skipped = wagons
		label_metry.text = "Uletěl jsi %.2f m\nPřeskočil jsi %d vagónů" % [distance, wagons]
		_update_achievements()
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

func _update_achievements():
		for i in ACHIEVEMENTS.size():
				var ach = ACHIEVEMENTS[i]
				var unlocked := false
				if ach.type == "distance":
						unlocked = current_distance >= ach.value
				else:
						unlocked = Hra.banana_total >= ach.value

				var btn: Button = achievement_buttons[i]
				btn.text = (unlocked ? "✓ " : "") + ach.label

func _on_restart_pressed():
	transition_anim.play("blesk")
	await transition_anim.animation_finished
	get_tree().reload_current_scene()

func do_restart():
	get_tree().reload_current_scene()
