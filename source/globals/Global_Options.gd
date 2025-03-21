extends Node

var current_array_opt = 0;

var down_scroll = false;
var middle_scroll = false;
var no_R = false;
var hide_hud = false;
var fps = 60;
var vsync = false;
var ghost_tapping = true;
var low_quality = false;
var time_bar_alpha = 1.0;
var health_bar_alpha = 1.0;
var hatsune_miku_mode = false;
var show_fps = true;
var full_screen = false;
var pause_music = ["pause V1",  "pause V2"];
var updated_pause_music = "pause V1";
var use_shader = true;
var keys = [
	["left", KEY_LEFT],
	["down", KEY_DOWN],
	["up", KEY_UP],
	["right", KEY_RIGHT]
]
var settingsJson = {};

signal ghost_tapping_miss;

func _ready():
	reset_settings();
	load_settings();
	
	down_scroll = settingsJson["down scroll"];
	middle_scroll = settingsJson["middle scroll"];
	no_R = settingsJson["no R"];
	hide_hud = settingsJson["hide hud"];
	vsync = settingsJson["vsync"];
	ghost_tapping = settingsJson["ghost tapping"];
	low_quality = settingsJson["low quality"];
	time_bar_alpha = settingsJson["time bar alpha"];
	health_bar_alpha = settingsJson["health bar alpha"];
	hatsune_miku_mode = settingsJson["hatsune miku mode"];
	keys = settingsJson["keys"];
	fps = int(settingsJson["fps"]);
	updated_pause_music = settingsJson["pause music"];
	show_fps = settingsJson["show FPS"];
	full_screen = settingsJson["full screen"];
	use_shader = settingsJson["use shader"];
	Global.volume = settingsJson["volume"];
	
	for i in keys.size():
		var ev = InputEventKey.new();
		ev.keycode = keys[i][1];
		if InputMap.has_action("ui_%s"%[OS.get_keycode_string(ev.keycode).to_lower()]):
			InputMap.erase_action("ui_%s"%[OS.get_keycode_string(ev.keycode).to_lower()]);
			
		InputMap.add_action("ui_%s"%[OS.get_keycode_string(ev.keycode).to_lower()]);
		InputMap.action_add_event("ui_%s"%[OS.get_keycode_string(ev.keycode).to_lower()], ev);
		
	print(InputMap.get_actions());
	print(settingsJson);
	
func save_settings():
	var new_jsonFile = FileAccess.open("user://Settings.json", FileAccess.WRITE);
	new_jsonFile.store_string(JSON.stringify(settingsJson));
	new_jsonFile.close();
	
	down_scroll = settingsJson["down scroll"];
	middle_scroll = settingsJson["middle scroll"];
	no_R = settingsJson["no R"];
	hide_hud = settingsJson["hide hud"];
	vsync = settingsJson["vsync"];
	ghost_tapping = settingsJson["ghost tapping"];
	low_quality = settingsJson["low quality"];
	time_bar_alpha = settingsJson["time bar alpha"];
	health_bar_alpha = settingsJson["health bar alpha"];
	hatsune_miku_mode = settingsJson["hatsune miku mode"];
	keys = settingsJson["keys"];
	fps = int(settingsJson["fps"]);
	updated_pause_music = settingsJson["pause music"]
	show_fps = settingsJson["show FPS"];
	full_screen = settingsJson["full screen"];
	use_shader = settingsJson["use shader"];
	Global.volume = settingsJson["volume"];
	
	for i in keys.size():
		var ev = InputEventKey.new();
		ev.keycode = keys[i][1];
		if InputMap.has_action("ui_%s"%[OS.get_keycode_string(ev.keycode).to_lower()]):
			InputMap.erase_action("ui_%s"%[OS.get_keycode_string(ev.keycode).to_lower()]);
			
		InputMap.add_action("ui_%s"%[OS.get_keycode_string(ev.keycode).to_lower()]);
		InputMap.action_add_event("ui_%s"%[OS.get_keycode_string(ev.keycode).to_lower()], ev);
		
func load_settings():
	if FileAccess.file_exists("user://Settings.json"):
		var new_jsonFile = FileAccess.open("user://Settings.json", FileAccess.READ);
		var jsonData = JSON.new();
		jsonData.parse(new_jsonFile.get_as_text());
		settingsJson = jsonData.get_data();
		new_jsonFile.close();
	else:
		settingsJson = {
			"down scroll": false,
			"middle scroll": false,
			"no R": false,
			"hide hud": false,
			"vsync": false,
			"ghost tapping": true,
			"low quality": false,
			"time bar alpha": 1.0,
			"health bar alpha": 1.0,
			"hatsune miku mode": false,
			"fps": 60,
			"pause music": "pause V1",
			"keys": [
				["left", KEY_LEFT],
				["down", KEY_DOWN],
				["up", KEY_UP],
				["right", KEY_RIGHT]
			],
			"use shader": true,
			"full screen": false,
			"show FPS": true,
			"volume": 1
		};
		save_settings();
		
func get_setting(setting, value):
	settingsJson[setting] = value;
	save_settings();
	
func rebind_keys(key_selected, new_key, key_value):
	settingsJson["keys"][key_selected][0] = new_key;
	settingsJson["keys"][key_selected][1] = key_value;
	save_settings();
	
func reset_settings():
	settingsJson = {
		"down scroll": false,
		"middle scroll": false,
		"no R": false,
		"hide hud": false,
		"vsync": false,
		"ghost tapping": true,
		"low quality": false,
		"time bar alpha": 1.0,
		"health bar alpha": 1.0,
		"hatsune miku mode": false,
		"fps": 60,
		"pause music": "pause V1",
		"keys": [
			["left", KEY_LEFT],
			["down", KEY_DOWN],
			["up", KEY_UP],
			["right", KEY_RIGHT]
		],
		"use shader": true,
		"full screen": false,
		"show FPS": true,
		"volume": 1
	};
	print(settingsJson);
	save_settings();
