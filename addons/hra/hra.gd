extends Node

var top_scores := []
const SAVE_PATH := "user://scoreboard.save"

# Persistent banana currency
var banana_total := 0
const BANANA_SAVE_PATH := "user://bananas.save"

# Persistent achievement completion
var achievements_completed := []
const ACHIEVEMENTS_SAVE_PATH := "user://achievements.save"
const ACHIEVEMENTS_COUNT := 8

func _ready():
	load_scores()
	load_bananas()
	load_achievements()

func save_score(distance: float, name: String):
	top_scores.append({ "name": name, "score": distance })
	top_scores.sort_custom(func(a, b): return b["score"] < a["score"])
	if top_scores.size() > 3:
		top_scores = top_scores.slice(0, 3)
	save_to_disk()

func get_score_string(index: int) -> String:
	if index < top_scores.size():
		var s = top_scores[index]
		return "%.2fm - %s" % [s["score"], s["name"]]
	return "---"

func save_to_disk():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(top_scores)

func load_scores():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		top_scores = file.get_var()
	else:
		top_scores = []

# -- Banana currency persistence ------------------------------------------
func add_banana(amount: int = 1):
	banana_total += amount
	save_bananas()

func save_bananas():
	var file = FileAccess.open(BANANA_SAVE_PATH, FileAccess.WRITE)
	file.store_var(banana_total)

func load_bananas():
	if FileAccess.file_exists(BANANA_SAVE_PATH):
		var file = FileAccess.open(BANANA_SAVE_PATH, FileAccess.READ)
		banana_total = file.get_var()
	else:
		banana_total = 0

# -- Achievement persistence ---------------------------------------------
func save_achievements():
	var file = FileAccess.open(ACHIEVEMENTS_SAVE_PATH, FileAccess.WRITE)
	file.store_var(achievements_completed)

func load_achievements():
	if FileAccess.file_exists(ACHIEVEMENTS_SAVE_PATH):
		var file = FileAccess.open(ACHIEVEMENTS_SAVE_PATH, FileAccess.READ)
		achievements_completed = file.get_var()
	else:
		achievements_completed.resize(ACHIEVEMENTS_COUNT)
		for i in ACHIEVEMENTS_COUNT:
			achievements_completed[i] = false

func mark_achievement(idx: int):
	if idx >= 0 and idx < ACHIEVEMENTS_COUNT:
		achievements_completed[idx] = true
		save_achievements()
