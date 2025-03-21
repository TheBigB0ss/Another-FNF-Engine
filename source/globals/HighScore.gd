extends Node

var score_data = {};

func _ready():
	#clear_score();
	load_score();
	print(score_data);
	
func save_score():
	var new_jsonFile = FileAccess.open("user://Score.json", FileAccess.WRITE);
	new_jsonFile.store_string(JSON.stringify(score_data, "\t"));
	print(score_data);
	
func load_score():
	if FileAccess.file_exists("user://Score.json"):
		var new_jsonFile = FileAccess.open("user://Score.json", FileAccess.READ);
		var jsonData = JSON.new();
		jsonData.parse(new_jsonFile.get_as_text());
		score_data = jsonData.get_data();
		new_jsonFile.close();
	else:
		var new_jsonFile = FileAccess.open("user://Score.json", FileAccess.WRITE);
		new_jsonFile.store_string(JSON.stringify(score_data, "\t"));
		
func get_song_score(song = "", diff = "", score = 0):
	if diff == "normal":
		score_data[set_song(song, "")] = score;
	else:
		score_data[set_song(song, diff)] = score;
	save_score();
	
func get_score(song = "", diff = ""):
	if !score_data.has(set_song(song, diff)):
		get_song_score(song, diff, 0);
		
	return int(score_data[set_song(song, diff)])
	
func set_song(song, diff):
	return str(song, diff);
	
func clear_score():
	Global.week_status = {};
	score_data = {};
	save_score();
