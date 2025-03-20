extends Node2D

func _ready() -> void:
	if Global.songsShit[0] == "roses" if Global.isStoryMode else Global.songsShit == "roses":
		$Character_Animation.play("BG fangirls dissuaded/ ");
	else:
		$Character_Animation.play("BG girls group/ ");
