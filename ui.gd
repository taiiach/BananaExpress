extends CanvasLayer

var distance := 0.0
var bananas := 0

@onready var score_label: Label = $ScoreLabel
@onready var banana_label: Label = $BananaLabel

func _ready():
		bananas = Hra.banana_total

func _process(delta):
		# Tady se distance pouze zobrazuje
		score_label.text = "%.2fm" % distance
		banana_label.text = "%d" % bananas

func add_distance(amount: float):
		distance += amount

func add_banana(amount: int = 1):
				Hra.add_banana(amount)
				bananas = Hra.banana_total

func reset_bananas():
				bananas = Hra.banana_total

func reset_distance():
	distance = 0.0
