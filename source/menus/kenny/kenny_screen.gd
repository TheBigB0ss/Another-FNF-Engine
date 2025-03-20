extends Node2D

@onready var kenny_text = $'suffer_text';
@onready var timer = $'Timer';
@onready var kenny_song = $'kenny happy song';
var times = -1;

func _ready() -> void:
	$'bg/fire'.play("fire")
	
func _on_timer_timeout() -> void:
	var tween = get_tree().create_tween();
	times += 1;
	timer.start(3.5);
	match times:
		0:
			kenny_text.text = "you..."
		1:
			kenny_text.text = "you BASTARD"
		2:
			kenny_text.text = "look what you have DONE"
			tween.tween_property($'bg/madKenny', "modulate:a", 0.1, 1)
		3:
			kenny_text.text = "YOU KILL HIM"
			tween.tween_property($'bg/madKenny', "modulate:a", 0.2, 1)
			kenny_song.volume_db = 4.5
		4:
			kenny_text.text = "YOU ARE A MONSTER"
			tween.tween_property($'bg/madKenny', "modulate:a", 0.3, 1)
		5:
			kenny_text.text = "I WILL FIND YOU"
			tween.tween_property($'bg/madKenny', "modulate:a", 0.4, 1)
			kenny_song.volume_db = 8.5
		6:
			kenny_text.text += "\n AND I WILL KILL YOU";
			tween.tween_property($'bg/madKenny', "modulate:a", 0.5, 1)
			kenny_song.volume_db = 12.5
		7:
			kenny_text.text = ""
			tween.tween_property($'bg/madKenny', "modulate:a", 0.6, 1)
			kenny_song.volume_db = 15.5
		8:
			kenny_text.text = "GOOD NIGHT :)"
			tween.tween_property($'bg/fire', "modulate:a", 0.0, 1)
			kenny_song.volume_db = 15.5
			#tween.tween_property($'bg/madKenny', "modulate:a", 0.0, 1)
		10:
			Global.closeGame(); 
