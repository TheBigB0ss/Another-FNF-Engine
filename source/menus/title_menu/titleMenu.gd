extends Node

var coolArray = [];
var no_spam = false;

var coolOffset = 0;

@onready var gf = $'tiltle stuff/Gf';
@onready var logo = $'tiltle stuff/logo';
@onready var enterText = $'tiltle stuff/title';
@onready var newGroundsLogo = $'tiltle stuff/NG Logo';

@onready var alphabets = $'alphabet_grp';

var hasSkippedIntro = false;
var gfDanceLeft = false;

var ameigosSuffix = ""
var random_text_arr = []

var datetime = Time.get_datetime_dict_from_system()

func _ready():
	Discord.update_discord_info("title menu", "Is in menus")
	
	if !Global.finished_intro:
		hide_guys();
		MusicManager._play_music("freakyMenu", true, true);
	else:
		show_guys();
		Flash.flashAppears(1.3);
		
	enterText.play("Press Enter to Begin");
	Global.connect("new_beat", _on_freaky_menu_beat);
	
	if datetime.month == 12 && datetime.day == 25:
		ameigosSuffix = "_natal"
		
	elif datetime.month == 10 && datetime.day == 31:
		ameigosSuffix = "_hallowen"
		
	else:
		ameigosSuffix = ""
		
	random_text_arr = [getTxt()];
	print(random_text_arr)
	
func _process(delta):
	Conductor.getSongTime += delta*1000;
	
func show_guys():
	gf.show();
	logo.show();
	enterText.show();
	
func hide_guys():
	gf.hide();
	logo.hide();
	enterText.hide();
	
func _input(ev):
	if Global.finished_intro:
		hasSkippedIntro = true;
		
	if hasSkippedIntro && !no_spam:
		if ev is InputEventKey && ev.pressed && (ev.keycode in [KEY_ENTER] || ev.keycode in [KEY_KP_ENTER]):
			no_spam = true;
			enterText.play("ENTER PRESSED");
			SoundStuff.playAudio('confirmMenu', false);
			Global.finished_intro = true;
			
			await get_tree().create_timer(1.5).timeout
			Global.changeScene("menus/main_menu/MainMenu");
			
	if ev is InputEventKey && ev.pressed && (ev.keycode in [KEY_ENTER] || ev.keycode in [KEY_KP_ENTER]) && !hasSkippedIntro && !Global.finished_intro:
		skipIntro();
		
func skipIntro():
	Flash.flashAppears(0.5);
	hideText();
	show_guys();
	newGroundsLogo.hide();
	hasSkippedIntro = true;
	
func getTxt():
	var txtData = [];
	var txtTexts = [];
	var readTxt = FileAccess.open("res://assets/data/IntroTexts.txt", FileAccess.READ);
	txtData = readTxt.get_as_text().split("\n");
	
	for i in txtData:
		var coolest_split = i.split("--");
		txtTexts.append(coolest_split);
		
	return txtTexts.pick_random();
	
func create_text(text = [], offSet = 0.0):
	for i in text:
		var alphabet = Alphabet.new();
		alphabet._creat_word(i)
		alphabet.position.y += alphabets.get_child_count()*70;
		alphabet.position.x += offSet
		alphabets.add_child(alphabet);
		
func hideText():
	if alphabets.get_child_count() > 0:
		for i in alphabets.get_children():
			i.queue_free();
			
func _on_freaky_menu_beat(beat):
	gfDanceLeft = !gfDanceLeft;
	if gfDanceLeft:
		gf.play("dance_right");
	else:
		gf.play("dance_left");
		
	logo.play("logo bumpin");
	
	if !hasSkippedIntro && !Global.finished_intro:
		match beat:
			1:
				create_text(["BIG BOSS PRESENTS"], 130)
			4:
				hideText();
			5:
				create_text(["NOT ASSOCIATION"], 220);
				create_text(["WITH"], 500)
			7:
				create_text(["NEWGROUNDS"], 355)
				newGroundsLogo.show();
			8:
				hideText();
				newGroundsLogo.hide();
			9:
				create_text([random_text_arr[0][0]], 350)
			10:
				create_text([random_text_arr[0][1]], 290)
				
				#just a inside joke :) 
				if random_text_arr[0][0] == "ameigos":
					newGroundsLogo.texture = load("res://assets/images/ameigos_logos/ameigos_logo%s.png"%[ameigosSuffix])
					newGroundsLogo.scale = Vector2(2.5, 2.5)
					newGroundsLogo.show();
					$ameigos_bg.show();
					
			11:
				hideText();
				newGroundsLogo.hide();
				$ameigos_bg.hide();
			12:
				create_text(["ANOTHER"], 400)
			13:
				create_text(["FNF ENGINE"], 330)
			14:
				create_text(["MADE IN GODOT"], 250)
			16:
				hideText();
				skipIntro();
				
