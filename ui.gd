extends CanvasLayer

var distance := 0.0
var bananas := 0
var max_bananas := 0
var jump_count := 0

# Achievement definitions
const ACHIEVEMENTS := [
        {"label": "100m", "type": "distance", "value": 100.0},
        {"label": "250m", "type": "distance", "value": 250.0},
        {"label": "500m", "type": "distance", "value": 500.0},
        {"label": "750m", "type": "distance", "value": 750.0},
        {"label": "1000m", "type": "distance", "value": 1000.0},
        {"label": "10 bananas", "type": "bananas", "value": 10},
        {"label": "50 bananas", "type": "bananas", "value": 50},
        {"label": "100 bananas", "type": "bananas", "value": 100},
        {"label": "5 jumps", "type": "jumps", "value": 5},
]

var unlocked := []

@onready var score_label: Label = $ScoreLabel
@onready var banana_label: Label = $BananaLabel
@onready var achievement_popup: Button = $AchievementPopup

func _ready():
               bananas = Hra.banana_total
               max_bananas = bananas
               jump_count = 0
               unlocked = Hra.achievements_completed.duplicate()
                if unlocked.size() < ACHIEVEMENTS.size():
                                unlocked.resize(ACHIEVEMENTS.size())
                                for i in ACHIEVEMENTS.size():
                                                if i >= Hra.achievements_completed.size():
                                                                unlocked[i] = false
                achievement_popup.hide()

func _process(delta):
				# Tady se distance pouze zobrazuje
				score_label.text = "%.2fm" % distance
				banana_label.text = "%d" % bananas
				_check_achievements()

func add_distance(amount: float):
                               distance += amount

func add_jump():
                               jump_count += 1

func add_banana(amount: int = 1):
                               Hra.add_banana(amount)
                               bananas = Hra.banana_total
                               if bananas > max_bananas:
                                               max_bananas = bananas

func reset_bananas():
                               bananas = Hra.banana_total
                               max_bananas = bananas

func reset_distance():
               distance = 0.0
               jump_count = 0

func _check_achievements():
               for i in ACHIEVEMENTS.size():
                               if unlocked[i]:
                                               continue
                               var ach = ACHIEVEMENTS[i]
                               var condition := false
                               if ach.type == "distance":
                                               condition = distance >= ach.value
                               elif ach.type == "bananas":
                                               condition = max_bananas >= ach.value
                               elif ach.type == "jumps":
                                               condition = jump_count >= ach.value
                               else:
                                               condition = false
                               if condition:
                                               unlocked[i] = true
                                               _show_achievement(ach.label)
                                               Hra.mark_achievement(i)

func _show_achievement(text: String):
		achievement_popup.text = text
		achievement_popup.show()
		achievement_popup.modulate.a = 0.0
		var tw = create_tween()
		tw.tween_property(achievement_popup, "modulate:a", 1.0, 0.4)
		tw.tween_interval(1.2)
		tw.tween_property(achievement_popup, "modulate:a", 0.0, 0.4)
		tw.finished.connect(achievement_popup.hide)
