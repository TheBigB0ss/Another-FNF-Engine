extends Node

var audio = AudioStreamPlayer.new();

func _ready():
	add_child(audio)
	
func playAudio(sound, isPixelAudio, volume = 0.0):
	if(isPixelAudio):
		audio.stream = load("res://assets/sounds/%s.ogg"%[sound + '-pixel']);
	else:
		audio.stream = load("res://assets/sounds/%s.ogg"%[sound]);
	audio.play(volume);
	
func stopAudio():
	audio.stop();
