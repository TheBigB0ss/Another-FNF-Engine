extends weekStuff

@onready var song_stuff = $'songs';
@onready var icons_stuff = $'icons';

var cur_song = 0;
var cur_diff = 0;

var weeks = [];
var songs = [];
var diffs = ["easy", "normal", "hard"];
var bg_colors = [];
var icons = [];

var cur_score = 0;
var score = 0;

var noSpam = false;

var offSetShit = 0;
var coolOffset = 140;

var alphabet_array = [];

func loadJson(week):
	var jsonFile = FileAccess.open("res://assets/weeks/%s.json"%[week],FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	weekJson = jsonData.get_data();
	jsonFile.close();
	return weekJson
	
func get_week_files():
	var file = [];
	var coolFolder = DirAccess.open("res://assets/weeks");
	if coolFolder:
		coolFolder.list_dir_begin();
		var nameShit = coolFolder.get_next();
		while nameShit != "":
			file.append(nameShit.replace(".json", ""));
			nameShit = coolFolder.get_next();
	return file;
	
func _ready() -> void:
	Discord.update_discord_info("freeplay menu", "Is in menus")
	
	weeks = get_week_files();
	for i in weeks:
		loadJson(i);
		
		for j in weekJson["songs"]:
			if !weekJson["hideFromFreeplay"]:
				#if j[0].contains("-"):
				#	j[0].replace("-", " ");
					
				songs.append(j[0]);
				icons.append(j[1]);
				bg_colors.append(j[2]);
				
				var alphabet = Alphabet.new();
				alphabet._creat_word(j[0]);
				alphabet.position.y += offSetShit;
				song_stuff.add_child(alphabet);
				
				var icon = freeplayIcon.new();
				icon.alphabet = alphabet;
				icon.new_x = 100;
				icon.load_icon(j[1]);
				icons_stuff.add_child(icon);
				
				alphabet_array.append(alphabet);
				
				offSetShit += coolOffset;
				
	for i in weekJson["weekDifficulties"]:
		if weekJson["weekDifficulties"][cur_diff] == null:
			diffs = ["easy", "normal", "hard"];
		else:
			diffs = weekJson["weekDifficulties"];
			
	change_song(Global.cur_thing);
	changeDiff(1);
	
func _process(delta):
	cur_score = int(lerp(cur_score, score, 0.1))
	
	if diffs[cur_diff] == "normal":
		score = HighScore.get_score(songs[cur_song].to_lower(), "")
	else:
		score = HighScore.get_score(songs[cur_song].to_lower(), str("-", diffs[cur_diff].to_lower()))
		
	$scoreText.text = "SCORE: %s"%[cur_score];
	
func add_new_song(pos, song, icon, color):
	songs.insert(pos, song);
	icons.insert(pos, icon);
	bg_colors.insert(pos, color);
	
func _input(ev):
	if ev is InputEventKey:
		if ev.pressed && Global.can_use_menus:
			if ev.keycode in [KEY_ESCAPE] && !ev.echo:
				Global.cur_thing = 0;
				Global.changeScene("menus/main_menu/MainMenu");
				
			if ev.keycode in [KEY_DOWN] && !ev.echo && !noSpam:
				change_song(1);
				
			if ev.keycode in [KEY_UP] && !ev.echo && !noSpam:
				change_song(-1);
				
			if (ev.keycode in [KEY_ENTER] || ev.keycode in [KEY_KP_ENTER]) && !ev.echo && !noSpam:
				noSpam = true;
				go_to_song(songs[cur_song], diffs[cur_diff])
				
			if ev.keycode in [KEY_LEFT] && !noSpam && !ev.echo:
				changeDiff(-1);
				
			if ev.keycode in [KEY_RIGHT] && !noSpam && !ev.echo:
				changeDiff(1);
				
			if ev.keycode in [KEY_R] && ev.echo:
				HighScore.clear_score();
				
func go_to_song(song, diff_path):
	SoundStuff.playAudio("confirmMenu", false)
	Global.songsShit = song;
	Global.diffsShit = diff_path;
	Global.isStoryMode = false;
	MusicManager._stop_music();
	await get_tree().create_timer(0.6).timeout;
	if diff_path == "normal":
		SongData.loadJson(song, "");
	else:
		SongData.loadJson(song, diff_path);
		
	Global.changeScene("gameplay/PlayState", true, false);
	
func change_song(change):
	cur_song += change;
	
	SoundStuff.playAudio("scrollMenu", false);
	cur_song = wrapi(cur_song, 0, songs.size());
	Global.cur_thing = cur_song;
	update_song();
	
func changeDiff(shit):
	cur_diff += shit;
	cur_diff = wrapi(cur_diff, 0, len(diffs));
	$difficultyText.text = str("< ",diffs[cur_diff].to_upper()," >");
	
func update_song():
	for j in songs.size():
		if j == cur_song:
			icons_stuff.get_children()[j].modulate.a = 1;
			song_stuff.get_children()[j].modulate.a = 1;
		else:
			icons_stuff.get_children()[j].modulate.a = 0.5;
			song_stuff.get_children()[j].modulate.a = 0.5;
			
	var tw = get_tree().create_tween();
	tw.tween_property(song_stuff, "position:y", 350-coolOffset*cur_song, 0.11).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
	var icon_tw = get_tree().create_tween();
	icon_tw.tween_property(icons_stuff, "position:y", 350-coolOffset*cur_song, 0.11).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
	var color_tw = get_tree().create_tween();
	color_tw.tween_property($'bg', "modulate", Color(bg_colors[cur_song][0], bg_colors[cur_song][1], bg_colors[cur_song][2]), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
