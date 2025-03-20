extends Node

var music = AudioStreamPlayer2D.new();
var cool_loop = false;

func _ready() -> void:
	add_child(music);
	
func _play_music(to_load, top_level, loop, volume = 0.0):
	Conductor.getMusicTime = 0.0;
	music.stream = load("res://assets/music/%s.ogg"%[to_load]);
	music.top_level = top_level;
	music.volume_db = volume;
	cool_loop = loop;
	music.play(0.0);
	
func _process(delta: float) -> void:
	if music.playing:
		Conductor.getMusicTime += (delta*1);
		#print("music pos: ",Conductor.getMusicTime)
		#print("music lenght: ", music.stream.get_length())
		
		if Conductor.getMusicTime >= music.stream.get_length() && cool_loop:
			Conductor.getMusicTime = 0.0;
			music.play(0.0);
			print("loop")
			
func _stop_music():
	music.stop();
