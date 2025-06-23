extends CanvasLayer

var distance := 0.0

@onready var score_label: Label = $ScoreLabel

func _process(delta):
	# Tady se distance pouze zobrazuje
	score_label.text = "%.2fm" % distance

func add_distance(amount: float):
	distance += amount

func reset_distance():
	distance = 0.0
