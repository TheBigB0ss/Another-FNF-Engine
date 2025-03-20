extends CanvasLayer

func flashAppears(flashTime = 0.5, color = Color(255, 255, 255)):
	$'ColorRect'.modulate = color;
	var tween = get_tree().create_tween();
	tween.tween_property($'ColorRect', "modulate:a", 0, flashTime);
