extends weekStuff

@onready var locker = $'lock';

@onready var weekTitle = $'texts/weekName';
@onready var weeksSpr = $'bgs/WeekSprite';
@onready var songText = $'texts/songs';
@onready var scoreText = $'texts/score';

@onready var menu_bf = $'characters/characterPosition1';
@onready var menu_gf = $'characters/characterPosition2';
@onready var menu_opponent = $'characters/characterPosition3';

@onready var diffSpr = $'difficulties';

@onready var leftArrow = $'arrows/LeftArrow';
@onready var rightArrow = $'arrows/RightArrow';

var yellowBf = null;
var yellowGf = null;
var yellowOpponent = null;

var noSpam = false;
var diffs = ["easy", "normal", "hard"];
var curDiff = 0;

var week = [];
var new_weeks = [];

var curWeek = 0;
var coolSong = [];

var offSetShit = 0;
var coolOffset = 115

var score = 0;

func loadJson(week):
	var jsonFile = FileAccess.open("res://assets/weeks/%s.json"%[week],FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	weekJson = jsonData.get_data();
	jsonFile.close();
	return weekJson
	
func _ready():
	Discord.update_discord_info("story menu", "Is in menus")
	
	Global.weekShit = weekJson
	#loadJson(week[curWeek])
	
	week = get_week_files();
	for i in week:
		loadJson(i);
		if !weekJson["hideFromStoryMode"]:
			new_weeks.append(weekJson["weekName"])
			
	print(new_weeks)
	
	for i in new_weeks:
		var storySprite = Sprite2D.new();
		storySprite.texture = load("res://assets/images/weeks/%s.png"%[i]);
		storySprite.position.y = offSetShit;
		weeksSpr.add_child(storySprite);
		offSetShit += coolOffset
		
	changeMenuCharacter();
	changeDiff(1);
	changeWeek(Global.cur_thing);
	
var choiced = false;
func _input(ev):
	if ev is InputEventKey:
		if Global.can_use_menus:
			if ev.keycode in [KEY_ESCAPE] && !ev.echo && ev.pressed:
				Global.cur_thing = 0;
				Global.changeScene("menus/main_menu/MainMenu", true, false);
				
			if ev.keycode in [KEY_DOWN] && !noSpam && !ev.echo && ev.pressed:
				changeWeek(1);
				
			if ev.keycode in [KEY_UP] && !noSpam && !ev.echo && ev.pressed:
				changeWeek(-1);
				
			if ev.keycode in [KEY_LEFT] && !noSpam && !ev.echo && ev.pressed:
				leftArrow.play("arrow push left");
				changeDiff(-1);
			else:
				leftArrow.play("arrow left");
				
			if ev.keycode in [KEY_RIGHT] && !noSpam && !ev.echo && ev.pressed:
				rightArrow.play("arrow push right");
				changeDiff(1);
			else:
				rightArrow.play("arrow right");
				
			if (ev.keycode in [KEY_ENTER] || ev.keycode in [KEY_KP_ENTER]) && !noSpam && !ev.echo && ev.pressed:
				var is_unlocked = Global.unlockweek(weekJson["lastWeek"])
				
				if is_unlocked:
					noSpam = true;
					choiced = true;
					
					var storyMode = true;
					var songsList = [];
					var diffsList = [];
					var songPath = "";
					
					for i in weekJson["songs"]:
						songsList.append(i[0]);
						diffsList = diffs[curDiff];
						
					Global.songsShit = songsList;
					Global.diffsShit = diffsList;
					Global.isStoryMode = storyMode;
					Global.cur_week = weekJson["weekName"];
					
					if yellowBf != null:
						yellowBf.play("M bf HEY");
						
					SoundStuff.playAudio("confirmMenu", false)
					
					await get_tree().create_timer(1).timeout;
					songPath = songsList[0]
					if diffsList == "normal":
						SongData.loadJson(songPath, "");
					else:
						SongData.loadJson(songPath, diffsList);
					Global.changeScene("gameplay/PlayState", true, false);
					MusicManager._stop_music();
				else:
					SoundStuff.playAudio("cancelMenu", false)
					
var week_score = 0;

var confirm_timer = 0.075;
var can_change_color = false;
func _process(delta):
	if choiced:
		confirm_timer -= delta
		if confirm_timer <= 0:
			if can_change_color:
				weeksSpr.get_child(curWeek).modulate = Color.CYAN;
				can_change_color = false;
			else:
				weeksSpr.get_child(curWeek).modulate = Color.WHITE;
				can_change_color = true;
				
			confirm_timer = 0.075;
			
	scoreText.text = "Week Score: %s"%[week_score]
	
func changeDiff(shit):
	var is_unlocked = Global.unlockweek(weekJson["lastWeek"])
	
	if is_unlocked:
		curDiff += shit;
		curDiff = wrapi(curDiff, 0, len(diffs));
		diffSpr.texture = load("res://assets/images/difficulties/%s.png"%[diffs[curDiff]]);
		
		var tw = get_tree().create_tween();
		if diffSpr.texture.get_width() < 250:
			tw.tween_property(leftArrow, "position", Vector2(811,480), 0.02);
			tw.tween_property(rightArrow, "position", Vector2(1073,480), 0.02);
		else:
			tw.tween_property(leftArrow, "position", Vector2(763,480), 0.02);
			tw.tween_property(rightArrow, "position", Vector2(1125,480), 0.02);
			
	for i in weekJson["songs"]:
		if diffs[curDiff] == "normal":
			week_score = HighScore.get_score(i[0], "")
		else:
			week_score = HighScore.get_score(i[0], str("-", diffs[curDiff].to_lower()))
			
func changeWeek(shit):
	curWeek += shit;
	SoundStuff.playAudio("scrollMenu", false);
	curWeek = wrapi(curWeek, 0, len(new_weeks));
	Global.cur_thing = curWeek;
	updateWeek();
	
	for j in new_weeks.size():
		if j == curWeek:
			weeksSpr.get_children()[j].modulate.a = 1;
		else:
			weeksSpr.get_children()[j].modulate.a = 0.5;
			
func updateWeek():
	loadJson(new_weeks[curWeek]);
	changeMenuCharacter();
	
	for i in new_weeks:
		if !Global.week_status.has(i):
			Global.week_status[i] = weekJson["isLocked"];
			Global.save_week_status();
	Global.weekShit = weekJson;
	
	var is_unlocked = Global.unlockweek(weekJson["lastWeek"]);
	
	songText.text = '';
	weekTitle.text = '';
	
	for i in weekJson["weekDifficulties"]:
		if weekJson["weekDifficulties"][curDiff] == null:
			diffs = ["easy", "normal", "hard"];
		else:
			diffs = weekJson["weekDifficulties"];
			
	if !is_unlocked:
		locker.show();
		leftArrow.hide();
		rightArrow.hide();
		diffSpr.hide();
		weeksSpr.get_child(curWeek).modulate = Color.GRAY;
	else:
		locker.hide();
		leftArrow.show();
		rightArrow.show();
		diffSpr.show();
		weeksSpr.get_child(curWeek).modulate = Color.WHITE;
		
	for i in weekJson["songs"]:
		if !is_unlocked:
			songText.text = "???"
		else:
			songText.text += i[0].to_upper()+"\n";
			
	if !is_unlocked:
		weekTitle.text = "week locked";
	else:
		weekTitle.text = weekJson["weekDescription"];
		
	weekTitle.position.x = 1005;
	weekTitle.position.x -= len(weekTitle.text)*17
	
	for i in weekJson["songs"]:
		if diffs[curDiff] == "normal":
			week_score = HighScore.get_score(i[0], "")
		else:
			week_score = HighScore.get_score(i[0], str("-", diffs[curDiff].to_lower()))
			
	if !is_unlocked:
		menu_gf.modulate = Color("#000000");
		menu_bf.modulate = Color("#000000");
		menu_opponent.modulate = Color("#000000");
	else:
		menu_gf.modulate = Color("#ffffff");
		menu_bf.modulate = Color("#ffffff");
		menu_opponent.modulate = Color("#ffffff");
		
	var tw = get_tree().create_tween();
	tw.tween_property(weeksSpr, "position:y", 480-coolOffset*curWeek, 0.11).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
func changeMenuCharacter():
	for i in menu_opponent.get_children():
		menu_opponent.remove_child(i);
		i.queue_free();
		
	for i in menu_bf.get_children():
		menu_bf.remove_child(i);
		i.queue_free();
		
	for i in menu_gf.get_children():
		menu_gf.remove_child(i);
		i.queue_free();
		
	var chars = [];
	chars.append(weekJson["weekCharacters"][0]);
	chars.append(weekJson["weekCharacters"][1]);
	chars.append(weekJson["weekCharacters"][2]);
	
	if weekJson["weekCharacters"][0] != "" && weekJson["weekCharacters"][0] != null:
		yellowOpponent = load("res://source/characters/menu characters/menu_%s.tscn"%[weekJson["weekCharacters"][0]]).instantiate();
		menu_opponent.show();
	else:
		menu_opponent.hide();
	menu_opponent.add_child(yellowOpponent);
	
	if weekJson["weekCharacters"][1] != "" && weekJson["weekCharacters"][1] != null:
		yellowBf = load("res://source/characters/menu characters/menu_%s.tscn"%[weekJson["weekCharacters"][1]]).instantiate();
		menu_bf.show();
	else:
		menu_bf.hide();
	menu_bf.add_child(yellowBf);
	
	if weekJson["weekCharacters"][2] != "" && weekJson["weekCharacters"][2] != null:
		yellowGf = load("res://source/characters/menu characters/menu_%s.tscn"%[weekJson["weekCharacters"][2]]).instantiate();
		menu_gf.show();
	else:
		menu_gf.hide();
	menu_gf.add_child(yellowGf);
	
