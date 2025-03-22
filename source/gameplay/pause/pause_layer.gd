extends CanvasLayer

@onready var options_grp = $'panel/options_grp';
@onready var song_text = $'panel/song_text';
@onready var difficulty_text = $'panel/difficulty_text';
@onready var pause_panel = $'panel';
@onready var death_count_text = $'panel/deaths';

var paused = false;
var opts = ['RESUME', 'RESTART', 'BOTPLAY', 'EXIT TO MENU'];
var cur_option = 0;
var can_use = false;
var is_paused = false;

var offSetShit = 0;
var coolOffset = 125

var cool_arrow = Alphabet.new();

func _ready():
	song_text.text = "";
	difficulty_text.text = "";
	death_count_text.text = "";
	
	if Global.is_on_chartMode:
		opts.insert(3, "EXIT CHART MODE")
		
	for i in opts:
		var pause_opts = Alphabet.new();
		pause_opts._creat_word(i)
		pause_opts.position.y = offSetShit;
		if Global.is_on_chartMode:
			pause_opts.position.y = offSetShit - 140;
		options_grp.add_child(pause_opts);
		offSetShit += coolOffset
		
	cool_arrow._creat_word(">");
	cool_arrow.position.x = 70;
	cool_arrow.modulate = Color("#ffd65d");
	pause_panel.add_child(cool_arrow);
	
	death_count_text.text += str("Deaths: ",Global.death_count);
	song_text.text += "Song: %s"%[SongData.chartData["song"]["song"]]
	difficulty_text.text += "Difficulty: %s"%[Global.diffsShit]
	
	death_count_text.position.x -= len(death_count_text.text)*2;
	song_text.position.x -= len(SongData.chartData["song"]["song"])*17;
	difficulty_text.position.x -= len(Global.diffsShit)*24;
	
	change_opt(0);
	is_paused = true;
	process_mode = 2;
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept") && !is_paused:
		_choice_pause_opts();
		is_paused = true;
		
	if Input.is_action_just_released("ui_accept"):
		is_paused = false;
		
func _input(ev):
	if ev is InputEventKey:
		if ev.pressed && !ev.echo && can_use && Global.can_use_menus:
			if ev.keycode in [KEY_DOWN]:
				change_opt(1);
				SoundStuff.playAudio("scrollMenu", false)
				
			if ev.keycode in [KEY_UP]:
				change_opt(-1);
				SoundStuff.playAudio("scrollMenu", false)
				
func change_opt(opt):
	cur_option += opt;
	cur_option = wrapi(cur_option, 0, len(opts));
	for i in options_grp.get_children():
		if i == options_grp.get_children()[cur_option]:
			i.modulate.a = 1;
			cool_arrow.position.y = i.position.y + 260
		else:
			i.modulate.a = 0.5;
			
	var tw = get_tree().create_tween();
	tw.tween_property(options_grp, "position:y", 260-coolOffset*cur_option, 0.09);
	
func _choice_pause_opts():
	match opts[cur_option]:
		"RESUME":
			_resume();
			can_use = false;
			
		"RESTART":
			_resume();
			
			get_tree().current_scene.inst.stop();
			get_tree().current_scene.voices.stop();
			
			Global.reloadScene(true, false, 3.5);
			
			pause_panel.hide();
			can_use = false;
			
		"BOTPLAY":
			Global.is_a_bot = !Global.is_a_bot;
			
		"EXIT TO MENU":
			Global.is_on_chartMode = false;
			Global.death_count = 0;
			
			paused = false;
			pause_panel.visible = false;
			
			get_tree().paused = false;
			get_tree().current_scene.inst.stop();
			get_tree().current_scene.voices.stop();
			
			Global.changeScene("menus/story_mode/storyMode" if Global.isStoryMode else "menus/freeplay/freeplay_menu");
			
			MusicManager._play_music("freakyMenu", true, true);
			pause_panel.hide();
			can_use = false;
			
		"EXIT CHART MODE":
			Global.is_on_chartMode = false;
			_resume();
			
			get_tree().current_scene.inst.stop();
			get_tree().current_scene.voices.stop();
			
			Global.reloadScene(true, false, 3.5);
			
			var default_chart = null;
			var songDiff = "" if Global.diffsShit == "" else Global.diffsShit
			var song = Global.songsShit[0] if Global.isStoryMode else Global.songsShit
			
			SongData.loadJson(song, songDiff, default_chart);
			pause_panel.hide();
			can_use = false;
			
func _paused():
	MusicManager._play_music(GlobalOptions.updated_pause_music, true, true);
	MusicManager.music.seek(0.0);
	paused = true;
	pause_panel.visible = true;
	
func _resume():
	MusicManager._stop_music();
	paused = false;
	pause_panel.visible = false;
	get_tree().paused = false;
