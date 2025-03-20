extends Node2D

var new_chartData:Dictionary = {};

@onready var voices = $'chart_voices';
@onready var inst = $'chart_inst';

@onready var iconP1 = $'grid_objs/icons/icon_player';
@onready var iconP2 = $'grid_objs/icons/icon_opponent';

@onready var chart_cam = $'Camera2D';

var curselected_note = []

var note_types = ["", "gf sing", "Hey!", "No Animation", "alt anim", "Hurt Note", "Kill Note", "Second opponent"];

var grid_size = 40;

var free_Mouse = false;
var duet_notes = false;

var curSection = 0;
var is_playing = true;

var curSong = "";
var curStage = "stage";
var curDiff = "";

var is_next_section = false;

@onready var grid = $'grid_objs/grid';
@onready var black_grid = $'grid_objs/black_grid';

@onready var song_line = $'grid_objs/song_line';
@onready var selection = $'grid_objs/selection_box';

@onready var notes = $'grid_objs/notes';
@onready var sustain_notes = $'grid_objs/sustain_notes';

@onready var chart_info = $'chart_UI/chart_objs/chart_info';

@onready var player1Options = $'chart_UI/chart_objs/TabContainer/song/player1';
@onready var player2Options = $'chart_UI/chart_objs/TabContainer/song/player2';
@onready var player3Options = $'chart_UI/chart_objs/TabContainer/song/player3';
@onready var gfOptions = $'chart_UI/chart_objs/TabContainer/song/gf';
@onready var stageOptions = $'chart_UI/chart_objs/TabContainer/song/stage';

@onready var note_type_button = $'chart_UI/chart_objs/TabContainer/note/note_type';

@onready var cool_file_save = $"FileDialog"

var replaceString = "";
var characterList = [];
var stageList = [];

var songDiff = "";

func _ready():
	Discord.update_discord_info("chart menu", "Is in menus")
	
	Global.is_on_chartMode = true;
	
	%song_name.text = Global.songsShit;
	
	songDiff = Global.diffsShit;
	
	print(songDiff)
	
	characterList = addCharToList();
	stageList = addStagesToList();
	
	for i in note_types:
		note_type_button.add_item(i)
		
	for i in characterList:
		if i.contains(".json"):
			replaceString = i.replace(".json", "");
		player1Options.add_item(replaceString);
		player2Options.add_item(replaceString);
		player3Options.add_item(replaceString);
		gfOptions.add_item(replaceString);
		
	for i in stageList:
		if i.contains(".json"):
			replaceString = i.replace(".json", "");
		stageOptions.add_item(replaceString);
		
	var music_inst = load("res://assets/songs/" +  %song_name.text.to_lower() + "/Inst.ogg");
	var music_voices = load("res://assets/songs/" +  %song_name.text.to_lower() + "/Voices.ogg");
	
	inst.stream = music_inst;
	voices.stream = music_voices;
	
	inst.play(0.0);
	voices.play(0.0);
	
	inst.stream_paused = true;
	voices.stream_paused = true;
	
	loadJson(%song_name.text, Global.diffsShit);
	load_section();
	
	grid.GRID_SIZE = grid_size;
	grid.grid_Y_size = len(new_chartData["song"]["notes"]);
	
	black_grid.scale = Vector2(8, 16);
	black_grid.position.x = grid.position.x;
	black_grid.position.y = grid.position.y+640;
	
	player3Options.disabled = %new_opponent.button_pressed
	
	Conductor.curBeat = 0;
	Conductor.curStep = 0;
	Conductor.lastBeat = 0;
	Conductor.lastStep = 0;
	
	Conductor.changeBpm(new_chartData["song"]["bpm"]);
	Conductor.bpm = new_chartData["song"]["bpm"];
	Conductor.getSongTime = 0.0;
	
	%Bpm.value = Conductor.bpm;
	%song_speed.value = new_chartData["song"]["speed"];
	%is_pixel_stage.button_pressed = new_chartData["song"]["isPixelStage"];
	%new_opponent.button_pressed = new_chartData["song"]["two opponents"];
	
	for i in [player1Options, player2Options, gfOptions, player3Options]:
		i.connect("item_selected", change_icons);
		
	if soakedAppears() <= 4:
		$soaked.show();
	else:
		$soaked.hide();
		
	play_song();
	update_chart_status();
	
func soakedAppears():
	return randi_range(0, 1000);
	
func get_icons(char):
	var icon = {}
	var replaced = char;
	
	if char.contains(".json"):
		replaced = char.replace(".json", "");
		
	if replaced == "none":
		return "no_icon";
		
	var jsonFile = FileAccess.open("res://assets/characters/%s.json"%[replaced],FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	icon = jsonData.get_data()
	jsonFile.close();
	return icon["HealthIcon"];
	
func change_icons(char):
	iconP1.texture = load("res://assets/images/icons/icon-%s.png"%[get_icons(characterList[player1Options.selected])]);
	iconP2.texture = load("res://assets/images/icons/icon-%s.png"%[get_icons(characterList[player2Options.selected])]);
	
	if iconP1.texture != null:
		if iconP1.texture.get_width() <= 300:
			iconP1.hframes = 2;
			
		if iconP1.texture.get_width() >= 450:
			iconP1.hframes = 3;
			
		iconP1.frame = 0;
		
	if iconP2.texture != null:
		if iconP2.texture.get_width() <= 300:
			iconP2.hframes = 2;
			
		if iconP2.texture.get_width() >= 450:
			iconP2.hframes = 3;
			
		iconP2.frame = 0;
		
func _input(ev):
	if ev is InputEventKey:
		if ev.pressed:
			if ev.keycode in [KEY_SHIFT]:
				free_Mouse = true;
				
			if ev.keycode in [KEY_CTRL]:
				duet_notes = true;
				
			if (ev.keycode in [KEY_ESCAPE] || ev.keycode in [KEY_ENTER] || ev.keycode in [KEY_KP_ENTER]) && !ev.echo:
				load_chart_stuff();
				inst.stream_paused = true;
				voices.stream_paused = true;
				Global.songsShit = %song_name.text;
				
				var new_chart = new_chartData;
				var new_diff = songDiff;
				var new_name = %song_name.text;
				
				SongData.loadJson(new_name, new_diff, new_chart);
				Global.changeScene("gameplay/PlayState", true, false);
				Global.is_on_chartMode = true;
		else:
			duet_notes = false;
			free_Mouse = false;
			
func _process(delta):
	player3Options.disabled = !%new_opponent.button_pressed;
	if Input.is_action_just_pressed("ui_space"):
		play_song();
		
	if is_playing:
		Conductor.getSongTime += (delta*1000);
		
		if Conductor.getSongTime >= strum_start_time() + 4 * (1000 * 60 / Conductor.bpm):
			curSection += 1;
			changeSection(curSection);
			
		if Conductor.getSongTime/1000 >= inst.stream.get_length():
			curSection = 0;
			Conductor.curBeat = 0;
			Conductor.curStep = 0;
			Conductor.lastBeat = 0;
			Conductor.lastStep = 0;
			Conductor.getSongTime = 0.0;
			
			Conductor.changeBpm(new_chartData["song"]["bpm"]);
			Conductor.bpm = new_chartData["song"]["bpm"];
			
			inst.play(0.0);
			voices.play(0.0);
			
			changeSection(0);
			
	if Input.is_action_just_pressed("mouse_click"):
		if get_global_mouse_position().x >= grid.position.x && get_global_mouse_position().x <= grid.position.x + 315 && get_global_mouse_position().y > grid.position.y && get_global_mouse_position().y < grid.position.y + grid_size*16:
			add_note(selection.position.y, floor(get_global_mouse_position().x / grid_size)-9, 0, note_types[note_type_button.selected]);
			
	if Input.is_action_just_pressed("input_E") && curselected_note != []:
		%note_sustain_lenght.value += Conductor.stepCrochet/2;
		load_section();
		
	if Input.is_action_just_pressed("input_Q") && curselected_note != []:
		if %note_sustain_lenght.value > 0:
			%note_sustain_lenght.value -= Conductor.stepCrochet/2;
		load_section();
		
	if curselected_note != []:
		curselected_note[2] = %note_sustain_lenght.value;
		load_section();
		
	#for note in notes.get_children():
		#if Conductor.getSongTime >= note.songPos:
			#match note.noteData:
				#0:
					#print("left")
				#1:
					#print("down")
				#2:
					#print("up")
				#3:
					#print("right")
					
	song_line.position.y = get_strum_Y(Conductor.getSongTime - strum_start_time());
	chart_cam.position.y = song_line.position.y;
	$bg.position.y = song_line.position.y;
	
	if Input.is_action_just_released("mouse_wheel_down"):
		is_playing = false;
		Conductor.getSongTime += (6500 * delta);
		voices.play(Conductor.getSongTime/1000);
		inst.play(Conductor.getSongTime/1000);
		inst.stream_paused = true;
		voices.stream_paused = true;
		
		if song_line.position.y >= 675:
			changeSection(curSection + 1);
			
	if Input.is_action_just_released("mouse_wheel_up"):
		if Conductor.getSongTime > 0:
			is_playing = false;
			Conductor.getSongTime -= (6500 * delta);
			voices.play(Conductor.getSongTime/1000);
			inst.play(Conductor.getSongTime/1000);
			inst.stream_paused = true;
			voices.stream_paused = true;
			
			if curSection == 0 && song_line.position.y <= 100:
				Conductor.getSongTime = 0;
				song_line.position.y = 100;
				
			if curSection > 0 && song_line.position.y <= 100:
				changeSection(curSection - 1);
				
	chart_info.text = "section: %s\ncurBeat: %s\ncurStep: %s\nsong position: %s"%[curSection,Conductor.curBeat,Conductor.curStep,str(int(inst.get_playback_position()) / 60).pad_zeros(1) + ":" + str(int(inst.get_playback_position()) % 60).pad_zeros(2) + " / " + str(int(inst.stream.get_length()) / 60).pad_zeros(1) + ":" + str(int(inst.stream.get_length()) % 60).pad_zeros(2)]
	
	if get_global_mouse_position().x >= grid.position.x && get_global_mouse_position().x <= grid.position.x + 315 && get_global_mouse_position().y > grid.position.y && get_global_mouse_position().y < grid.position.y + grid_size + 585:
		selection.show();
		selection.position.x = floor(get_global_mouse_position().x/grid_size)*grid_size
		selection.position.y = get_global_mouse_position().y if free_Mouse else floor(get_global_mouse_position().y/grid_size)*grid_size;
	else:
		selection.hide();
		
func changeSection(sec):
	curSection = sec
	curSection = wrapi(curSection, 0, len(new_chartData["song"]["notes"]))
	load_section();
	update_chart_status();
	
func play_song():
	is_playing = !is_playing;
	if is_playing:
		inst.stream_paused = false;
		voices.stream_paused = false;
	else:
		inst.stream_paused = true;
		voices.stream_paused = true;
		
func load_section():
	for i in notes.get_children():
		i.queue_free();
		
	for i in sustain_notes.get_children():
		i.queue_free();
		
	if new_chartData["song"]["notes"][curSection]["changeBPM"]:
		%bpm_change.button_pressed = new_chartData["song"]["notes"][curSection]["changeBPM"];
		%new_bpm.value = new_chartData["song"]["notes"][curSection]["bpm"];
		
		Conductor.changeBpm(new_chartData["song"]["notes"][curSection]["bpm"]);
		Conductor.bpm = new_chartData["song"]["notes"][curSection]["bpm"];
		
		print("change bpm ", %new_bpm.value);
		
	if new_chartData["song"]["notes"][curSection]["changeBPM"] && new_chartData["song"]["notes"][curSection]["bpm"]:
		if new_chartData["song"]["notes"][curSection+1]["bpm"] <= 0:
			new_chartData["song"]["notes"][curSection+1]["bpm"] = %new_bpm.value;
			
	if new_chartData["song"]["notes"][curSection]["mustHitSection"]:
		iconP1.position.x = 430;
		iconP1.flip_h = false;
		iconP2.position.x = 610;
		iconP2.flip_h = true;
		
		if new_chartData["song"]["notes"][curSection]["gfSection"]:
			iconP1.texture = load("res://assets/images/icons/icon-gf.png");
			
		change_icons(0)
	else:
		iconP1.position.x = 610;
		iconP1.flip_h = true;
		iconP2.position.x = 430;
		iconP2.flip_h = false;
		
		if new_chartData["song"]["notes"][curSection]["gfSection"]:
			iconP2.texture = load("res://assets/images/icons/icon-gf.png");
			
		change_icons(0);
		
	for i in new_chartData["song"]["notes"][curSection]["sectionNotes"]:
		is_next_section = false;
		var new_note = spawn_note(get_strum_Y(i[0] - get_strum_time()), i[1], i[2], floor(get_strum_Y((i[0] - strum_start_time()))), i[3]);
		new_note.note_line.hide();
		new_note.note_end.hide();
		spawn_sustain(new_note);
		
func spawn_note(strumtime = 0.0, noteData = 0, sustain = 0, cool_y = null, note_type = ""):
	var newNote = load("res://source/arrows/note/note.tscn").instantiate();
	newNote.songPos = strumtime;
	newNote.noteData = int(noteData)%8;
	newNote.sustainLenght = sustain;
	newNote.type = note_type;
	newNote.position.x = floor(noteData * grid_size) + 380;
	newNote.position.y = grid_size + cool_y - 20 if cool_y != null else selection.position.y + 20;
	newNote.scale = Vector2(0.25, 0.25);
	if newNote.type == "Second opponent":
		newNote.scale = Vector2(0.25, 0.25);
		
	notes.add_child(newNote);
	return newNote;
	
func spawn_sustain(note):
	var sustain_line = $"grid_objs/note_sustain".duplicate();
	sustain_line.position.x = note.position.x -5;
	sustain_line.position.y = note.position.y + grid_size / 2;
	sustain_line.size.y = floor(remap(note.sustainLenght, 0, Conductor.stepCrochet * 16, 0, (16 * grid_size)));
	sustain_line.show();
	sustain_notes.add_child(sustain_line);
	return sustain_line;
	
func add_note(strumtime, noteData, sustain, type):
	var note_strumtime = get_strum_time(strumtime) + strum_start_time();
	var note_data = noteData;
	var note_sustain = 0;
	var note_type = type;
	
	new_chartData["song"]["notes"][curSection]["sectionNotes"].append([note_strumtime, note_data, note_sustain, note_type]);
	if duet_notes:
		new_chartData["song"]["notes"][curSection]["sectionNotes"].append([note_strumtime, int(noteData + 4)%8, note_sustain, note_type]);
		
	for i in new_chartData["song"]["notes"][curSection]["sectionNotes"]:
		curselected_note = i;
		
	%note_sustain_lenght.value = curselected_note[2];
	
	for note in notes.get_children():
		if selection.position.x + 20 == note.position.x && selection.position.y + 20 == note.position.y:
			for i in new_chartData["song"]["notes"][curSection]["sectionNotes"]:
				if i[0] == note_strumtime && i[1] == note_data:
					new_chartData["song"]["notes"][curSection]["sectionNotes"].erase(i);
					
					note.queue_free();
					for sustain_note in sustain_notes.get_children():
						sustain_note.queue_free();
						
				if curselected_note != []:
					if i[0] == curselected_note[0] && i[1] == curselected_note[1]:
						new_chartData["song"]["notes"][curSection]["sectionNotes"].erase(curselected_note);
						curselected_note = [];
						note.queue_free();
						for sustain_note in sustain_notes.get_children():
							sustain_note.queue_free();
							
	spawn_note(note_strumtime, note_data, note_sustain, null, note_type);
	
	print(curselected_note);
	load_section();
	
func loadJson(song, difficulty = ""):
	var difficultyPath = "";
	if difficulty == "" or difficulty == "normal":
		difficultyPath = "res://assets/data/%s/%s.json"%[song, song];
	else:
		difficultyPath = "res://assets/data/%s/%s-%s.json"%[song, song, difficulty];
		
	print(difficulty)
	print(difficultyPath)
	
	var jsonFile = FileAccess.open(difficultyPath, FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	new_chartData = jsonData.get_data();
	jsonFile.close();
	
	change_icons(0)
	
	if !new_chartData["song"].has("speed"):
		new_chartData["song"]["speed"] = 1;
		
	if !new_chartData["song"].has("bpm"):
		new_chartData["song"]["bpm"] = 100;
		
	if !new_chartData["song"].has("two opponents"):
		new_chartData["song"]["two opponents"] = false;
		
	if !new_chartData["song"].has("player4"):
		new_chartData["song"]["player4"] = "";
		
	if !new_chartData["song"].has("stage"):
		new_chartData["song"]["stage"] = "stage";
		
	if !new_chartData["song"].has("song"):
		new_chartData["song"]["song"] = "bopeebo";
		
	if !new_chartData["song"].has("isPixelStage"):
		new_chartData["song"]["isPixelStage"] = false;
		
	for i in player1Options.get_item_count():
		if player1Options.get_item_text(i) == new_chartData["song"]["player1"]:
			player1Options.select(i);
			
	for i in player2Options.get_item_count():
		if player2Options.get_item_text(i) == new_chartData["song"]["player2"]:
			player2Options.select(i);
			
	for i in gfOptions.get_item_count():
		if gfOptions.get_item_text(i) == new_chartData["song"]["player3"]:
			gfOptions.select(i);
			
	for i in stageOptions.get_item_count():
		if stageOptions.get_item_text(i) == new_chartData["song"]["stage"].to_lower():
			stageOptions.select(i);
			
	if new_chartData["song"]["player4"] != "":
		for i in player3Options.get_item_count():
			if player3Options.get_item_text(i) == new_chartData["song"]["player4"]:
				player3Options.select(i);
				
	for i in new_chartData["song"]["notes"]:
		if !i.has("gfSection"): 
			i["gfSection"] = false;
			
		if !i.has("altAnim"): 
			i["altAnim"] = false;
			
		if !i.has("changeBPM"): 
			i["changeBPM"] = false;
			
		if !i.has("bpm"): 
			i["bpm"] = 0;
			
	for i in new_chartData["song"]["notes"].size():
		for j in new_chartData["song"]["notes"][i]["sectionNotes"].size():
			if new_chartData["song"]["notes"][i]["sectionNotes"][j].size() < 4:
				new_chartData["song"]["notes"][i]["sectionNotes"][j].append("");
				
func get_strum_time(pos_Y = 0.0):
	return remap(pos_Y, grid.position.y, grid.position.y + (16 * grid_size), 0, 16 * Conductor.stepCrochet)
	
func get_strum_Y(pos = 0):
	return remap(pos, 0, 16 * Conductor.stepCrochet, grid.position.y, grid.position.y + (16 * grid_size))
	
func strum_start_time():
	var coolBpm = Conductor.bpm;
	var coolPos = 0
	for i in curSection:
		if new_chartData["song"]["notes"][i]["changeBPM"]:
			coolBpm = new_chartData["song"]["notes"][i]["bpm"];
			
		coolPos += 4 * (1000 * 60 / coolBpm);
	return coolPos
	
func getFolderShit(folder):
	var file = [];
	var coolFolder = DirAccess.open("res://%s"%[folder]);
	if coolFolder:
		coolFolder.list_dir_begin();
		var nameShit = coolFolder.get_next();
		while nameShit != "":
			file.append(nameShit);
			nameShit = coolFolder.get_next();
	else:
		print("folder not found!")
	return file;
	
func addCharToList():
	var charList = [];
	var char = getFolderShit("assets/characters/");
	for i in char:
		if i.ends_with(".json"):
			charList.append(i);
	return charList;
	
func addStagesToList():
	var stageList = [];
	var stage = getFolderShit("assets/stages/data/");
	for i in stage:
		if i.ends_with(".json"):
			stageList.append(i);
	return stageList;
	
func save_json(json):
	load_chart_stuff()
	var new_jsonFile = FileAccess.open(json, FileAccess.WRITE);
	new_jsonFile.store_string(JSON.stringify({"song": new_chartData["song"]}, "\t"));
	new_jsonFile.close();
	print('save: ', json);
	
func save_file():
	cool_file_save.popup_centered();
	
func load_song_json():
	loadJson(%song_name.text, "");
	
	%Bpm.value = Conductor.bpm;
	%new_opponent.button_pressed = new_chartData["song"]["two opponents"];
	%is_pixel_stage.button_pressed = new_chartData["song"]["isPixelStage"];
	%song_speed.value = new_chartData["song"]["speed"];
	
	Conductor.curBeat = 0;
	Conductor.curStep = 0;
	Conductor.lastBeat = 0;
	Conductor.lastStep = 0;
	
	Conductor.changeBpm(new_chartData["song"]["bpm"]);
	Conductor.getSongTime = 0.0;
	
	curSection = 0;
	
	load_section();
	
	is_playing = false;
	
	var music_inst = load("res://assets/songs/" +  %song_name.text.to_lower() + "/Inst.ogg");
	var music_voices = load("res://assets/songs/" +  %song_name.text.to_lower() + "/Voices.ogg");
	
	inst.stream = music_inst;
	voices.stream = music_voices;
	
	inst.play(0.0);
	voices.play(0.0);
	
	inst.stream_paused = true;
	voices.stream_paused = true;
	
func load_chart_stuff():
	new_chartData["song"]["player1"] = characterList[player1Options.selected].substr(0, characterList[player1Options.selected].length()-5);
	new_chartData["song"]["player2"] = characterList[player2Options.selected].substr(0, characterList[player2Options.selected].length()-5);
	new_chartData["song"]["player3"] = characterList[gfOptions.selected].substr(0, characterList[gfOptions.selected].length()-5);
	new_chartData["song"]["player4"] = characterList[player3Options.selected].substr(0, characterList[player3Options.selected].length()-5);
	new_chartData["song"]["stage"] = stageList[stageOptions.selected].substr(0, stageList[stageOptions.selected].length()-5);
	new_chartData["song"]["needsVoices"] = %have_voice_track.button_pressed;
	new_chartData["song"]["isPixelStage"] = %is_pixel_stage.button_pressed;
	new_chartData["song"]["speed"] = %song_speed.value;
	new_chartData["song"]["bpm"] = %Bpm.value;
	new_chartData["song"]["two opponents"] = %new_opponent.button_pressed;
	new_chartData["song"]["notes"][curSection]["changeBPM"];
	new_chartData["song"]["notes"][curSection]["altAnim"];
	new_chartData["song"]["notes"][curSection]["gfSection"];
	new_chartData["song"]["notes"][curSection]["mustHitSection"];
	
func update_chart_status():
	%must_hit.button_pressed = new_chartData["song"]["notes"][curSection]["mustHitSection"];
	%gf_section.button_pressed = new_chartData["song"]["notes"][curSection]["gfSection"];
	%alt_section.button_pressed = new_chartData["song"]["notes"][curSection]["altAnim"];
	%bpm_change.button_pressed = new_chartData["song"]["notes"][curSection]["changeBPM"];
	
var copyNotes = [];
var copySection = 0;
func copy_section() -> void:
	copyNotes = [];
	copySection = curSection;
	for i in new_chartData["song"]["notes"][curSection]["sectionNotes"]:
		copyNotes.append(i);
		
func paste_section() -> void:
	if copyNotes != []:
		var new_time = Conductor.stepCrochet*new_chartData["song"]["notes"][curSection]["lengthInSteps"]*(curSection - copySection);
		for i in copyNotes:
			var new_strumTime = i[0] + new_time;
			i = [new_strumTime, i[1], i[2], i[3]];
			new_chartData["song"]["notes"][curSection]["sectionNotes"].append(i);
		load_section();
		
func _on_must_hit_pressed() -> void:
	new_chartData["song"]["notes"][curSection]["mustHitSection"] = %must_hit.button_pressed;
	load_section();
	
func _on_gf_section_pressed() -> void:
	new_chartData["song"]["notes"][curSection]["gfSection"] = %gf_section.button_pressed;
	load_section()
	
func _on_alt_section_pressed() -> void:
	new_chartData["song"]["notes"][curSection]["altAnim"] = %alt_section.button_pressed;
	load_section()
	
func _on_bpm_change_pressed() -> void:
	new_chartData["song"]["notes"][curSection]["changeBPM"] = %bpm_change.button_pressed;
	
	load_section();
	
func _on_section_step_value_changed(value: float) -> void:
	%section_step.value = new_chartData["song"]["notes"][curSection]["lengthInSteps"]
	load_section()
	
func _on_new_bpm_value_changed(value: float) -> void:
	new_chartData["song"]["notes"][curSection]["bpm"] = value;
	load_section();
