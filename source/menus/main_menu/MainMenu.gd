extends Node2D

var curOption = 0
var options = ["story_mode", "freeplay", "credits", "options"];
var noSpam = false;

@onready var coolOptions = $'options';
@onready var new_bg = $'TextureRect';
@onready var cool_bg = $'bg';

var coolOffset = 145;
var offSetShit = 0;

var you_delete_kenny = false;

func _ready():
	Discord.update_discord_info("main menu", "Is in menus")
	
	#var kenny_file = FileAccess;
	#var kenny_img = "res://assets/Kenny (don't delete he).png"
	#if kenny_file.file_exists(kenny_img):
	#	print("kenny exist")
	#	you_delete_kenny = false;
	#else:
	#	print("you kill him...")
	#	you_delete_kenny = true;
		
	get_tree().get_root().files_dropped.connect(drop_new_bg_image);
	
	for i in options:
		var menu_opts = load("res://source/menus/main_menu/menu_options/%s.tscn"%[i]).instantiate();
		menu_opts.play(i + " basic");
		menu_opts.position.y = offSetShit;
		menu_opts.position.x = -30;
		coolOptions.add_child(menu_opts);
		offSetShit += coolOffset;
		
	changeItem(0);
	
func drop_new_bg_image(file):
	var newBg_image = Image.new();
	newBg_image.load(file[0]);
	
	var newBg_texture = ImageTexture.new();
	newBg_texture.set_image(newBg_image);
	
	new_bg.texture = newBg_image;
	new_bg.show()
	if new_bg.texture != null:
		cool_bg.hide();
	print(new_bg);
	print(newBg_image);
	
var choiced = false;
func _input(ev):
	if ev is InputEventKey:
		if ev.pressed && !ev.echo && Global.can_use_menus:
			if ev.keycode in [KEY_DOWN] && !noSpam:
				changeItem(1);
				
			if ev.keycode in [KEY_UP] && !noSpam:
				changeItem(-1);
				
			if (ev.keycode in [KEY_ENTER] || ev.keycode in [KEY_KP_ENTER]) && !noSpam:
				noSpam = true;
				choiced = true;
				SoundStuff.playAudio("confirmMenu", false)
				await get_tree().create_timer(0.9).timeout;
				match options[curOption]:
					"story_mode":
						Global.changeScene("/menus/story_mode/storyMode", true, false);
					"freeplay":
						Global.changeScene("/menus/freeplay/freeplay_menu", true, true);
					"credits":
						Global.changeScene("/menus/credits/credits", true, false);
					"options":
						Global.changeScene("/menus/options/options_menu", true, false);
						
			if ev.keycode in [KEY_ESCAPE] && !noSpam:
				noSpam = true;
				Global.changeScene("/menus/title_menu/titleMenu", true, false);
				Global.finished_intro = true;
				
var can_show_magenta = true;
var magenta_time = 0.095;
func _process(delta):
	if choiced:
		$magentaBg.show();
		magenta_time -= delta
		if magenta_time <= 0:
			if can_show_magenta:
				$magentaBg.modulate.a = 1;
				can_show_magenta = false;
			else:
				$magentaBg.modulate.a = 0;
				can_show_magenta = true;
				
			magenta_time = 0.095;
			
func changeItem(change):
	curOption += change
	SoundStuff.playAudio("scrollMenu", false)
	#I now, this is stupid
	curOption = wrapi(curOption, 0, len(options));
	for j in options.size():
		#if options[j] == "freeplay":
		#	coolOptions.get_children()[j].modulate.a = 0.5
			
		coolOptions.get_children()[j].play(options[j] + " basic");
		if j == curOption:
			coolOptions.get_children()[j].play(options[curOption] + " white");
