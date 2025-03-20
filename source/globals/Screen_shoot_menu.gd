extends Node2D

func _input(ev):
	if ev is InputEventKey:
		if ev.pressed && !ev.echo:
			if ev.keycode in [KEY_F11]:
				screen_shoot();
				
func screen_shoot():
	var datetime = Time.get_datetime_string_from_system(false, true).replace(":", "-");
	var screen_shoot_image = get_viewport().get_texture().get_image()
	var image_name = "res://screenshoots/screenshoot %s.png"%[datetime];
	screen_shoot_image.save_png(image_name)
