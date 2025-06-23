extends StaticBody2D

func _on_WagonDetector_body_entered(body):
	if body.name == "Player":
		body.register_wagon(get_instance_id())
