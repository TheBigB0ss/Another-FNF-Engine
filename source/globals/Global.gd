extends Node

var songsShit = [];
var diffsShit = [];

var weekShit = {};
var cur_week = "";
var week_status = {};

var isStoryMode = false;
var globalCombo = 0;
var is_a_bot = false;

var cur_thing = 0;

var volume = 1;

var death_count = 0;

var updated_options = [];

var is_on_death_screen = false;

var is_pressing_note = false;
var pressed_note = false;
var is_on_playstate = false;
var finished_intro = false;

var can_use_menus = true;

var is_pause_mode = false;

var is_on_chartMode = false;

signal notePressed(note)
signal longNotePressed(note)
signal noteMissed(note)

signal new_beat(beat);
signal new_step(step);

var is_not_in_cutscene = true;

signal end_dialogue;
signal end_senpai_cutscene;

func _ready():
	load_week_status();
	update_windowMode(GlobalOptions.full_screen);
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if GlobalOptions.vsync else DisplayServer.VSYNC_DISABLED);
	
func _process(delta: float) -> void:
	Engine.max_fps = GlobalOptions.fps;
	
func unlockweek(week):
	return week_status[week] == true if weekShit["lastWeek"] != weekShit["weekName"] && weekShit["isLocked"] else true;
	
func load_week_status():
	if FileAccess.file_exists("user://week status.json"):
		var new_jsonFile = FileAccess.open("user://week status.json", FileAccess.READ);
		var jsonData = JSON.new();
		jsonData.parse(new_jsonFile.get_as_text());
		week_status = jsonData.get_data();
		new_jsonFile.close();
		print(week_status)
	else:
		save_week_status();
		
func save_week_status():
	var new_jsonFile = FileAccess.open("user://week status.json", FileAccess.WRITE);
	new_jsonFile.store_string(JSON.stringify(week_status));
	new_jsonFile.close();
	print(week_status)
	
func getFolderShit(folder):
	var file = [];
	var coolFolder = DirAccess.open("res://%s"%[folder]);
	
	var nextFolder = coolFolder.get_next();
	if nextFolder != "":
		file.append(nextFolder);
	return file;
	
func getTextFromTxt(path):
	var txt = "res://assets/"+path+".txt";
	var readTxt = FileAccess.open(txt,FileAccess.READ);
	var file = readTxt.get_as_text();
	return file;
	
func getTextFromJson(path):
	var json = "res://assets/%s.json"%[path];
	var file = FileAccess.open(json, FileAccess.READ);
	var fileData = JSON.parse_string(file.get_as_text());
	return fileData;
	
func getTime():
	var time = Time.get_time_dict_from_system();
	return time;
	
func getUserName():
	var user = OS.get_environment("USERNAME");
	return user;
	
func closeGame():
	get_tree().quit();
	
func playVideo(video, videoVolume, skip = false):
	var videoFile = VideoStreamPlayer.new();
	videoFile.stream = load("res://assets/videos/%s.mp4"%[video]);
	videoFile.volume = videoVolume;
	videoFile.play();
	if skip == true:
		videoFile.stop();
	return videoFile;
	
func update_windowMode(toggle):
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if toggle else DisplayServer.WINDOW_MODE_WINDOWED);
	
func changeScene(scene, useTransition = true, use_stickers = true):
	if useTransition:
		Transition._is_in_transition(use_stickers)
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://source/%s.tscn"%[scene])
	else:
		get_tree().change_scene_to_file("res://source/%s.tscn"%[scene])
		
func reloadScene(useTrasition = true, use_stickers = false, speed = 0.65):
	if useTrasition:
		Transition.transition_speed = speed
		Transition._is_in_transition(use_stickers)
		await get_tree().create_timer(1.0).timeout
		get_tree().reload_current_scene();
	else:
		get_tree().reload_current_scene();
