extends CanvasLayer

@onready var label_metres = $VBoxContainer/metry
@onready var input_name = $VBoxContainer/jmenohrace
@onready var button_save = $VBoxContainer/ulozit
@onready var label_top3 = $VBoxContainer/top3

var current_distance := 0.0
var highscores: Array = []  # Array of dictionaries: [{name="Jana", score=12.4}, ...]

func _ready():
	hide()
	load_highscores()
	button_save.pressed.connect(save_score)

func show_gameover(distance: float):
	current_distance = distance
	label_metres.text = "Uskákal jsi %.2f metrů" % distance
	input_name.text = ""
	show()
	input_name.grab_focus()

func save_score():
	var name = input_name.text.strip_edges()
	if name == "":
		name = "Bezejmenný"
	
	highscores.append({"name": name, "score": current_distance})
	highscores.sort_custom(func(a, b): return b["score"] < a["score"])
	highscores = highscores.slice(0, 3)
	
	save_highscores()
	update_scoreboard()
	hide()

func update_scoreboard():
	var text = ""
	for i in highscores.size():
		var entry = highscores[i]
		text += "%d. %s – %.2fm\n" % [i + 1, entry["name"], entry["score"]]
	label_top3.text = text.strip_edges()

func save_highscores():
	var save = FileAccess.open("user://highscores.save", FileAccess.WRITE)
	save.store_var(highscores)

func load_highscores():
	if FileAccess.file_exists("user://highscores.save"):
		var file = FileAccess.open("user://highscores.save", FileAccess.READ)
		highscores = file.get_var()
	else:
		highscores = []
	update_scoreboard()
