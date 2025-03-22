extends Node

@onready var timeText = $'hud/Hud_Layer/timeLabel';
@onready var scoreText = $'hud/Hud_Layer/scoreLabel';
@onready var timeBar = $"hud/Hud_Layer/timeBar";

var health = 50.0;
var health_loss = 1;
@onready var healthBar = $'hud/Hud_Layer/healthBar';

@onready var voices = $'voices';
@onready var inst = $'inst';

@onready var iconP1 = $'hud/Hud_Layer/icons/iconPlayer';
@onready var iconP2 = $'hud/Hud_Layer/icons/iconDad';
@onready var iconGrp = $'hud/Hud_Layer/icons';

@onready var animatedIconP1 = $"hud/Hud_Layer/animated icons/iconPlayer";
@onready var animatedIconP2 = $"hud/Hud_Layer/animated icons/iconDad";

var ratingPart = "";
var ratings = ["sick", "good", "bad", "shit", "miss"];
@onready var rating_spr = $'rating/Rating_Layer/rating';
@onready var combo_spr = $'rating/Rating_Layer/combo';
@onready var nums_spr = $'rating/Rating_Layer/nums';

@onready var pause_menu = $'pause/Pause_Layer';
@onready var dialogue_box = $'dialogue/DialogueBox';

var can_pause = false;

var sicks = 0;
var goods = 0;
var bads = 0;
var shits = 0;

var combo = 0;
var score = 0;
var misses = 0;
var ratingName = '';

var totalHits = 0;
var notesPlayed = 0;
var percent = 0;

var isDead = false;

var bf = null;
var gf = null;
var dad = null;
var new_opponent = null;

@onready var stageGrp = $'stage';
var stage = null;

var is_on_intro = false;
var finished_song = false;

var skipIntro = false;
@onready var countdownSprite = $'hud/Hud_Layer/countdown';
var countdownset = {
	"default": ['prepare', 'ready','set','go'],
	"pixel": ['prepare', 'ready','set','date']
};

@onready var playerNote = $'strums/Strum_Layer/Player Notes';
@onready var opponentNote = $'strums/Strum_Layer/Opponent Notes';
var new_opponent_strumLine = null;
var notesList = [];

var curStage = "";
var curSong = "";

var playlist = [];
var songDiff = [];
var isStoryMode = false;

var singAnims = ["singLeft", "singDown", "singUp", "singRight"];

var playerNotes = [];
var opponentNotes = [];
var new_opponentNotes = [];
var array_notes = [];
@onready var noteGrp = $"notes/Note_Layer/Note_Grp";

@onready var sectionCamera = $"Camera2D";
var camera_position = Vector2();
var camera_on_Bf = false;
var gf_is_singing = false;

@onready var botplayText = $'hud/Hud_Layer/botplayLabel';
var can_show_botplay = true;
var botplayTime = 0.60;

func _ready():
	pause_menu.can_use = false;
	
	Global.connect("new_beat", beat_hit);
	Global.connect("new_step", step_hit);
	
	reset_status();
	
	isStoryMode = Global.isStoryMode;
	playlist = Global.songsShit;
	songDiff = Global.diffsShit;
	
	print("song list is: " + str(playlist));
	print("song diff is: " + str(songDiff));
	
	Global.is_on_death_screen = false;
	Global.connect("noteMissed", miss_note);
	Global.connect("end_dialogue", startCoutdown)
	GlobalOptions.connect("ghost_tapping_miss", miss_note);
	
	if SongData.chartData["song"]["stage"] != "":
		stage = load("res://source/stage/%s.tscn"%[SongData.chartData["song"]["stage"].to_lower()]).instantiate();
		SongData.loadStageJson(SongData.chartData["song"]["stage"].to_lower());
	else:
		stage = load("res://source/stage/Stage.tscn").instantiate();
		SongData.loadStageJson("stage");
		
	stageGrp.add_child(stage)
	
	curSong = SongData.chartData["song"]["song"];
	curStage = SongData.chartData["song"]["stage"];
	
	if !GlobalOptions.hatsune_miku_mode:
		if SongData.chartData["song"]["player1"] != "none":
			bf = load("res://source/characters/" + SongData.chartData["song"]["player1"] + ".tscn").instantiate();
			
		if SongData.chartData["song"]["player2"] != "none":
			dad = load("res://source/characters/" + SongData.chartData["song"]["player2"] + ".tscn").instantiate();
			
		if SongData.chartData["song"]["player3"] != "none":
			gf = load("res://source/characters/" + SongData.chartData["song"]["player3"] + ".tscn").instantiate();
			
		if SongData.chartData["song"]["player4"] != "" && SongData.chartData["song"]["two opponents"]:
			new_opponent = load("res://source/characters/" + SongData.chartData["song"]["player4"] + ".tscn").instantiate();
	else:
		bf = Sprite2D.new();
		bf.texture = load("res://assets/images/hatsune miku.png");
		
		dad = Sprite2D.new();
		dad.texture = load("res://assets/images/hatsune miku.png");
		dad.flip_h = true;
		
		gf = Sprite2D.new();
		gf.texture = load("res://assets/images/hatsune miku.png");
		
	add_child(gf);
	add_child(new_opponent);
	add_child(dad);
	add_child(bf);
	
	if SongData.chartData["song"]["player1"] != "none":
		bf.position = Vector2(SongData.stageData["bf"][0], SongData.stageData["bf"][1]);
		
	if SongData.chartData["song"]["player3"] != "none":
		gf.position = Vector2(SongData.stageData["gf"][0], SongData.stageData["gf"][1]);
		
	if SongData.chartData["song"]["player2"] == "gf":
		dad.position = Vector2(SongData.stageData["gf"][0], SongData.stageData["gf"][1]);
	else:
		if SongData.chartData["song"]["player2"] != "none":
			dad.position = Vector2(SongData.stageData["opponent"][0], SongData.stageData["opponent"][1]);
			
	if SongData.chartData["song"]["player4"] != "" && SongData.chartData["song"]["two opponents"]:
		new_opponent.position = Vector2(dad.position.x + 150, dad.position.y)
		
	if SongData.chartData["song"]["isPixelStage"]:
		countdownSprite.scale = Vector2(8,8);
		countdownSprite.texture_filter = Sprite2D.TEXTURE_FILTER_NEAREST;
		rating_spr.texture_filter = Sprite2D.TEXTURE_FILTER_NEAREST;
		combo_spr.texture_filter = Sprite2D.TEXTURE_FILTER_NEAREST;
		nums_spr.texture_filter = Sprite2D.TEXTURE_FILTER_NEAREST;
		ratingPart = '-pixel';
	else:
		ratingPart = '';
		
	if !GlobalOptions.hatsune_miku_mode:
		if dad.healthBar_Color != null:
			scoreText.modulate = dad.healthBar_Color
			healthBar.tint_under = dad.healthBar_Color;
		else:
			scoreText.modulate = Color("#ffffff")
			healthBar.tint_under = Color("#ff000f")
			
		if bf.healthBar_Color != null:
			healthBar.tint_progress = bf.healthBar_Color;
		else:
			healthBar.tint_progress = Color("#00ff06");
			
		if bf.animatedIcon:
			var new_animatedIconP1 = AnimatedIcon.new();
			new_animatedIconP1.icon_frames = "assets/images/icons/animated/icon-%s.res"%[bf.curIcon];
			new_animatedIconP1.icon_char = bf.curIcon;
			new_animatedIconP1.flip_h = true;
			animatedIconP1.add_child(new_animatedIconP1);
			iconP1.hide();
		else:
			iconP1.texture = load("res://assets/images/icons/icon-%s.png"%[bf.curIcon]);
			animatedIconP1.hide();
			
		if dad.animatedIcon:
			var new_animatedIconP2 = AnimatedIcon.new();
			new_animatedIconP2.icon_frames = "assets/images/icons/animated/icon-%s.res"%[dad.curIcon];
			new_animatedIconP2.icon_char = dad.curIcon;
			animatedIconP2.add_child(new_animatedIconP2);
			iconP2.hide();
		else:
			iconP2.texture = load("res://assets/images/icons/icon-%s.png"%[dad.curIcon]);
			animatedIconP2.hide();
	else:
		healthBar.tint_under = Color("#ff000f");
		healthBar.tint_progress = Color("#00ff06");
		
		var new_animatedIconP1 = AnimatedIcon.new();
		new_animatedIconP1.icon_frames = "assets/images/icons/animated/icon-BetaAlphaIcon.res";
		new_animatedIconP1.icon_char = "BetaAlphaIcon";
		new_animatedIconP1.flip_h = true;
		animatedIconP1.add_child(new_animatedIconP1);
		
		var new_animatedIconP2 = AnimatedIcon.new();
		new_animatedIconP2.icon_frames = "assets/images/icons/animated/icon-BetaAlphaIcon.res";
		new_animatedIconP2.icon_char = "BetaAlphaIcon";
		animatedIconP2.add_child(new_animatedIconP2);
		
		iconP1.hide();
		iconP2.hide();
		
	for i in SongData.chartData["song"]["notes"]:
		for j in i["sectionNotes"]:
			array_notes.insert(0, [j[0], j[1], j[2], j[3], i["gfSection"], i["altAnim"], i["mustHitSection"], false]);
			
	Conductor.mapBPMChanges(SongData.chartData);
	Conductor.changeBpm(SongData.chartData["song"]["bpm"]);
	
	Conductor.getSongTime = -Conductor.crochet*5;
	Conductor.songSpeed = SongData.chartData["song"]["speed"];
	
	startSong();
	
	for i in [healthBar, iconP1, iconP2, $"hud/Hud_Layer/animated icons"]:
		i.modulate.a = GlobalOptions.health_bar_alpha;
		
	for i in [timeBar, timeText]:
		i.modulate.a = GlobalOptions.time_bar_alpha;
		
	if GlobalOptions.hide_hud:
		for i in [$hud/Hud_Layer/healthBar, $hud/Hud_Layer/icons, $hud/Hud_Layer/scoreLabel, $hud/Hud_Layer/timeLabel, $hud/Hud_Layer/timeBar, $"hud/Hud_Layer/animated icons"]:
			i.hide();
			
	if GlobalOptions.down_scroll:
		$hud/Hud_Layer/healthBar.position.y = 60;
		$hud/Hud_Layer/icons/iconDad.position.y = 65;
		$hud/Hud_Layer/icons/iconPlayer.position.y = 65;
		$hud/Hud_Layer/timeBar.position.y = 680;
		$hud/Hud_Layer/scoreLabel.position.y = 85;
		$hud/Hud_Layer/timeLabel.position.y = 675;
		$"strums/Strum_Layer/Player Notes".position.y = 620;
		$"strums/Strum_Layer/Opponent Notes".position.y = 620;
		$"hud/Hud_Layer/animated icons/iconPlayer".position.y = 65;
		$"hud/Hud_Layer/animated icons/iconDad".position.y = 65;
		
	if GlobalOptions.middle_scroll:
		playerNote.position.x = 478;
		opponentNote.visible = false;
		
	if SongData.chartData["song"]["two opponents"]:
		new_opponent_strumLine = Node2D.new();
		new_opponent_strumLine.set_script(preload("res://source/gameplay/strums/Opponent Notes.gd"));
		new_opponent_strumLine.second_opponent = true;
		new_opponent_strumLine.position = Vector2(550, 100) if !GlobalOptions.down_scroll else Vector2(550, 600);
		new_opponent_strumLine.scale = Vector2(0.5, 0.5);
		new_opponent_strumLine.modulate.a = 0.60;
		$'strums/Strum_Layer'.add_child(new_opponent_strumLine);
		
		if GlobalOptions.middle_scroll:
			new_opponent_strumLine.visible = false;
			
	if iconP2.texture.get_width() <= 300:
		iconP2.hframes = 2;
	if iconP2.texture.get_width() >= 450:
		iconP2.hframes = 3;
	if iconP1.texture.get_width() <= 300:
		iconP1.hframes = 2;
	if iconP1.texture.get_width() >= 450:
		iconP1.hframes = 3;
		
	var txt_path = "res://assets/data/%s/%sDialogue.txt"%[SongData.chartData["song"]["song"].to_lower(), SongData.chartData["song"]["song"].to_lower()];
	if FileAccess.file_exists(txt_path):
		if Global.death_count <= 0 && Global.isStoryMode:
			if curSong.to_lower() == "thorns":
				var senpai_cutscene = load("res://source/gameplay/dialogue/cutscene/senpai_transform.tscn").instantiate();
				add_child(senpai_cutscene);
				Global.connect("end_senpai_cutscene", start_dialogue);
			else:
				start_dialogue()
		else:
			startCoutdown();
	else:
		Global.is_not_in_cutscene = true;
		startCoutdown();
		
	if curStage == "school":
		sectionCamera.zoom = Vector2(1.0, 1.0);
		
	updateScoreText();
	
func start_dialogue():
	Global.is_not_in_cutscene = false;
	dialogue_box.show();
	dialogue_box.pause_song();
	
func spawnNote(songPos, noteData, lenght, type, isGfNote, isAltAnim, isPlayer):
	var is_a_player_note = isPlayer;
	if noteData > 3:
		is_a_player_note = !isPlayer
		
	var note = load("res://source/arrows/note/note.tscn").instantiate();
	note.isGfNote = isGfNote;
	note.is_altAnim = isAltAnim;
	note.songPos = songPos;
	note.noteData = int(noteData)%4;
	note.sustainLenght = lenght;
	note.type = type;
	note.isPlayer = is_a_player_note;
	note.must_press = note.isPlayer;
	
	match note.type:
		"alt anim":
			note.is_altAnim = true;
		"No Animation":
			note.no_anim = true;
		"Hey!":
			note.is_hey_note = true;
		"gf sing":
			note.isGfNote = true;
		_:
			pass
			
	if note.must_press && is_a_player_note:
		note.position.x = playerNote.position.x;
		note.modulate.a = playerNote.modulate.a;
		note.rotation = playerNote.rotation;
		#note.scale = playerNote.scale;
		
	if !note.must_press && !is_a_player_note:
		note.position.x = opponentNote.position.x;
		note.modulate.a = opponentNote.modulate.a;
		note.rotation = opponentNote.rotation;
		#note.scale = opponentNote.scale;
		if GlobalOptions.middle_scroll:
			note.visible = false;
			
	if !note.must_press && !is_a_player_note && note.type == "Second opponent":
		note.position.x = new_opponent_strumLine.position.x;
		note.modulate.a = new_opponent_strumLine.modulate.a;
		note.rotation = new_opponent_strumLine.rotation;
		if GlobalOptions.middle_scroll:
			note.visible = false;
			
	if note.sustainLenght > 0.0:
		note.isSustain = true;
	else:
		note.isSustain = false;
		
	note.position.x += (40+65)*note.noteData if note.type != "Second opponent" else (25+27)*note.noteData;
	
	if note.isPlayer:
		playerNotes.append(note);
		
	if !note.isPlayer:
		opponentNotes.append(note);
		
	if !note.isPlayer && note.type == "Second opponent":
		new_opponentNotes.append(note)
		
	notesList.append(note);
	noteGrp.add_child(note);
	
var strumY = null;
var start_song = false;
func _process(delta: float) -> void:
	if start_song:
		if !pause_menu.paused:
			inst.stream_paused = false;
			voices.stream_paused = false;
			
			Conductor.getSongTime = Conductor.getSongTime+(delta*1000)
			var inst_pos = (inst.get_playback_position() + AudioServer.get_time_since_last_mix()) * 1000
			if abs(inst_pos - Conductor.getSongTime) > 30:
				inst.seek(Conductor.getSongTime / 1000.0)
				voices.seek(Conductor.getSongTime / 1000.0)
		else:
			inst.stream_paused = true;
			voices.stream_paused = true;
			
	healthBar.value = lerp(healthBar.value, health, 0.40);
	sectionCamera.zoom = lerp(sectionCamera.zoom, Vector2(0.8, 0.8), 0.09) if curStage != "school" else lerp(sectionCamera.zoom, Vector2(1.0, 1.0), 0.09)
	scoreText.scale = lerp(scoreText.scale, Vector2(0.049, 0.049), 0.08);
	
	if animatedIconP1.get_child_count() > 0:
		animatedIconP1.get_child(0).scale = lerp(animatedIconP1.get_child(0).scale, Vector2(1.0, 1.0), 0.08);
		
	if animatedIconP2.get_child_count() > 0:
		animatedIconP2.get_child(0).scale = lerp(animatedIconP2.get_child(0).scale, Vector2(1.0, 1.0), 0.08);
		
	iconP1.scale = lerp(iconP1.scale, Vector2(1.0, 1.0), 0.08);
	iconP2.scale = lerp(iconP2.scale, Vector2(1.0, 1.0), 0.08);
	
	if Conductor.getSongTime > 0 && !is_on_intro && isStoryMode && playlist.size() > 0:
		Discord.update_discord_info("Playstate", "Playing: %s (%s)"%[playlist[0], songDiff], "Another FNF Engine Made In Godot", dad.curIcon if !GlobalOptions.hatsune_miku_mode else "", Conductor.getSongTime/1000);
	else:
		Discord.update_discord_info("Playstate", "", "Another FNF Engine Made In Godot", dad.curIcon if !GlobalOptions.hatsune_miku_mode else "", 0.0);
		
	if Conductor.getSongTime >= 0 && !is_on_intro:
		timeBar.value = Conductor.getSongTime/1000;
		
	timeBar.max_value = inst.stream.get_length();
	
	#I hate myself
	if !healthBar.max_value > 100 or !health > 100:
		iconP1.position.x = healthBar.position.x + remap(healthBar.value-2, healthBar.min_value, healthBar.max_value, 475, healthBar.scale.x - lerp(healthBar.value, health, 0.5)) + 130;
		iconP2.position.x = healthBar.position.x + remap(healthBar.value-2, healthBar.min_value, healthBar.max_value, 475, healthBar.scale.x - lerp(healthBar.value, health, 0.5)) + 30;
		
		animatedIconP1.position.x = healthBar.position.x + remap(healthBar.value-2, healthBar.min_value, healthBar.max_value, 475, healthBar.scale.x - lerp(healthBar.value, health, 0.5)) + 130;
		animatedIconP2.position.x = healthBar.position.x + remap(healthBar.value-2, healthBar.min_value, healthBar.max_value, 475, healthBar.scale.x - lerp(healthBar.value, health, 0.5)) + 30;
		
	if Global.is_a_bot:
		botplayText.show();
		botplayTime -= delta
		if botplayTime <= 0:
			if can_show_botplay:
				botplayText.modulate.a = 1;
				can_show_botplay = false;
			else:
				botplayText.modulate.a = 0;
				can_show_botplay = true;
				
			botplayTime = 0.60
	else:
		botplayText.hide();
		
	for i in array_notes:
		var note_data = int(i[1])%8;
		var distance = (i[0] - Conductor.getSongTime)*Conductor.songSpeed;
		if distance <= 2500 && !i[7]:
			spawnNote(i[0], note_data, i[2], i[3], i[4], i[5], i[6]);
			i[7] = true;
			
	for note in notesList:
		if note != null:
			note.ms = note.songPos - Conductor.getSongTime;
			
			strumY = playerNote.position.y if note.isPlayer else opponentNote.position.y;
			if note.type == "Second opponent":
				strumY = new_opponent_strumLine.position.y
				
			if !note.is_pressing:
				note.position.y = strumY - (Conductor.getSongTime - note.songPos) * (0.45 * Conductor.songSpeed) if !GlobalOptions.down_scroll else strumY + (Conductor.getSongTime - note.songPos) * (0.45 * Conductor.songSpeed)
			else:
				note.position.y = strumY
				
			note.can_press = int(note.ms) <= 125 && int(note.ms) >= -175 && note.isPlayer;
			
			if note.is_pressing && note.isPlayer:
				if note.sustainLenght > 0 or note.sustainLenght != 0 && !Global.is_a_bot && !note.missed:
					play_strum_anim(note, false, 0.30);
					playBfAnim(note);
					
			if Conductor.getSongTime > 200 + note.songPos && note.isPlayer && !note.is_pressing && !note.is_a_bad_note:
				if note.sustainLenght > 0:
					playBfMissAnim(note);
					note.miss_note();
					if note != null:
						note.modulate.a = 0.3;
						
					if note.note_line != null:
						note.note_line.modulate.a = 0.3;
						note.note_line.position.y = strumY;
						
					if note.note_end != null:
						note.note_end.modulate.a = 0.3;
						note.note_end.position.y = strumY;
						
					note.missed = true;
				else:
					playBfMissAnim(note);
					note.miss_note();
					if note != null:
						note.modulate.a = 0.3;
						
					note.missed = true;
					
			if Conductor.getSongTime > 390 + note.songPos && note.isPlayer && note.sustainLenght <= 0:
				playerNotes.erase(note);
				notesList.erase(note);
				note.queue_free();
				
			if Conductor.getSongTime > 390 + note.songPos && note.isPlayer && note.sustainLenght > 0 && !note.is_pressing:
				if note.sustainLenght <= 0:
					playerNotes.erase(note);
					notesList.erase(note);
					note.queue_free();
					
	Global.pressed_note = false;
	for note in playerNotes:
		if !Global.is_a_bot && note != null:
			if Input.is_action_just_pressed("ui_"+note.custom_note_dir) && note.isPlayer && playerNotes.size() > 0 && note.can_press && note.must_press && !note.missed:
				if !note.is_a_bad_note:
					pressedNote(note);
					if note.sustainLenght == 0:
						playBfAnim(note);
						note.pressed();
						playerNotes.erase(note);
						notesList.erase(note);
					else:
						note.get_child(0).queue_free();
						note.pressed();
						note.is_pressing = true;
						
				elif note.is_a_bad_note:
					if note.sustainLenght == 0:
						health_loss = note.miss_health;
						note.miss_note();
						playBfMissAnim(note);
						playerNotes.erase(note);
						notesList.erase(note);
						note.queue_free();
					else:
						playBfMissAnim(note);
						note.get_child(0).queue_free();
						note.miss_note();
						note.is_pressing = true;
						
			if Input.is_action_pressed("ui_"+note.custom_note_dir) && note.isPlayer && playerNotes.size() > 0 && note.must_press && note.can_press && note.isSustain && !note.missed:
				if !note.is_a_bad_note && note.sustainLenght > 0 && !note.missed:
					if note.sustainLenght <= 0:
						note.is_pressing = false;
						playerNotes.erase(note);
						notesList.erase(note);
						
				elif note.is_a_bad_note && note.sustainLenght > 0 && !note.missed:
					note.is_pressing = true;
					if note.sustainLenght <= 0:
						note.is_pressing = false;
						playerNotes.erase(note);
						notesList.erase(note);
						
			if Input.is_action_just_released("ui_"+note.custom_note_dir) && note.isPlayer && playerNotes.size() > 0 && note.must_press && !note.is_a_bad_note && note.is_pressing:
				note.is_pressing = false;
				note.missed = true;
				
		if Global.is_a_bot && note != null:
			if Conductor.getSongTime >= note.songPos && note.isPlayer && playerNotes.size() > 0 && note.must_press && !note.is_a_bad_note && !note.missed:
				#pressedNote(note);
				note.pressed();
				if note.sustainLenght == 0:
					playBfAnim(note);
					playerNotes.erase(note);
					notesList.erase(note);
				else:
					playBfAnim(note);
					note.get_child(0).hide();
					
				if note.sustainLenght > 0 or note.sustainLenght != 0:
					note.is_pressing = true;
					if note.sustainLenght <= 0:
						note.is_pressing = false;
						playerNotes.erase(note);
						notesList.erase(note);
						
	for note in opponentNotes:
		if note != null:
			if Conductor.getSongTime >= note.songPos && opponentNotes.size() > 0 && !note.isPlayer && !note.is_a_bad_note:
				if note.sustainLenght == 0:
					playOpponentAnim(note);
					note.opponent_pressed();
					opponentNotes.erase(note);
					notesList.erase(note);
				else:
					playOpponentAnim(note);
					note.get_child(0).hide();
					
				if note.sustainLenght > 0 or note.sustainLenght != 0:
					note.is_pressing = true;
					if note.sustainLenght <= 0:
						note.is_pressing = false;
						opponentNotes.erase(note);
						notesList.erase(note);
						
	if SongData.chartData["song"]["two opponents"]:
		for note in new_opponentNotes:
			if note != null:
				if Conductor.getSongTime >= note.songPos && new_opponentNotes.size() > 0 && !note.isPlayer && !note.is_a_bad_note && note.type == "Second opponent":
					if note.sustainLenght == 0:
						playOpponentAnim(note);
						note.opponent_pressed();
						new_opponentNotes.erase(note);
						notesList.erase(note);
						
					if note.sustainLenght > 0 or note.sustainLenght != 0:
						playOpponentAnim(note);
						note.get_child(0).hide();
						
					if note.sustainLenght > 0 or note.sustainLenght != 0:
						note.is_pressing = true;
						if note.sustainLenght <= 0:
							note.is_pressing = false;
							new_opponentNotes.erase(note);
							notesList.erase(note);
							
	if health <= 15:
		if !GlobalOptions.hatsune_miku_mode:
			if !dad.animatedIcon:
				if iconP2.texture.get_width() <= 300:
					iconP2.frame = 0;
				if iconP2.texture.get_width() >= 450:
					iconP2.frame = 2;
			else:
				animatedIconP2.get_child(0).play_icon_anim("win" if animatedIconP2.get_child(0).end_transition else "transition");
				
			if !bf.animatedIcon:
				iconP1.frame = 1;
			else:
				animatedIconP1.get_child(0).play_icon_anim("lose" if animatedIconP1.get_child(0).end_transition else "transition");
				
		else:
			animatedIconP2.get_child(0).play_icon_anim("win" if animatedIconP2.get_child(0).end_transition else "transition");
			animatedIconP1.get_child(0).play_icon_anim("lose" if animatedIconP1.get_child(0).end_transition else "transition");
			
	elif health >= 80:
		if !GlobalOptions.hatsune_miku_mode:
			if !bf.animatedIcon:
				if iconP1.texture.get_width() <= 300:
					iconP1.frame = 0;
				if iconP1.texture.get_width() >= 450:
					iconP1.frame = 2;
			else:
				animatedIconP1.get_child(0).play_icon_anim("win" if animatedIconP1.get_child(0).end_transition else "transition");
				
			if !dad.animatedIcon:
				iconP2.frame = 1;
			else:
				animatedIconP2.get_child(0).play_icon_anim("lose" if animatedIconP2.get_child(0).end_transition else "transition");
				
		else:
			animatedIconP2.get_child(0).play_icon_anim("lose" if animatedIconP2.get_child(0).end_transition else "transition");
			animatedIconP1.get_child(0).play_icon_anim("win" if animatedIconP1.get_child(0).end_transition else "transition");
			
	elif health <= 50 or health >= 50:
		if !GlobalOptions.hatsune_miku_mode:
			if !dad.animatedIcon:
				iconP2.frame = 0;
			else:
				animatedIconP2.get_child(0).play_icon_anim("idle");
				
			if !bf.animatedIcon:
				iconP1.frame = 0;
			else:
				animatedIconP1.get_child(0).play_icon_anim("idle");
		else:
			animatedIconP2.get_child(0).play_icon_anim("idle");
			animatedIconP1.get_child(0).play_icon_anim("idle");
			
	if Conductor.getSongTime >= 0:
		timeText.text = str(int(inst.get_playback_position()) / 60).pad_zeros(1) + ":" + str(int(inst.get_playback_position()) % 60).pad_zeros(2) + " / " + str(int(inst.stream.get_length()) / 60).pad_zeros(1) + ":" + str(int(inst.stream.get_length()) % 60).pad_zeros(2);
		if Conductor.getSongTime/1000 >= inst.stream.get_length() && !finished_song:
			finished_song = true;
			finishSong();
	else:
		timeText.text = str("0:00") + " / " + str(int(inst.stream.get_length()) / 60).pad_zeros(1) + ":" + str(int(inst.stream.get_length()) % 60).pad_zeros(2);
			
	if health <= 0:
		playerDead();
		
	newFc();
	
func reset_status():
	totalHits = 0;
	combo = 0;
	score = 0;
	shits = 0;
	bads = 0;
	goods = 0;
	sicks = 0;
	
	Global.globalCombo = 0;
	Conductor.curBeat = 0;
	Conductor.curStep = 0;
	Conductor.lastStep = 0;
	Conductor.lastBeat = 0;
	
func pressedNote(note):
	scoreText.scale = Vector2(0.051, 0.051);
	
	voices.volume_db = 0;
	Global.pressed_note = true;
	
	var pressed = false;
	
	if Global.is_a_bot && note.sustainLenght > 0 && note.emit_longNote && !note.get_child(0).visible:
		pressed = true;
		
	if !pressed:
		if note.ms <= 125 && !note.ms <= 65:
			notesPlayed += 0.2;
			score += 20;
			shits += 1;
			rating_spr.pop_up_rating(3);
			#print("shit");
			
		if note.ms <= 65 && !note.ms <= 50:
			notesPlayed += 0.6;
			score += 80;
			bads += 1;
			rating_spr.pop_up_rating(2);
			#print("bad");
			
		if note.ms <= 50 && !note.ms <= 10:
			notesPlayed += 0.8;
			score += 140;
			goods += 1;
			rating_spr.pop_up_rating(1);
			#print("good");
			
		if note.ms <= 10 && !note.ms < -175:
			notesPlayed += 1;
			score += 200;
			sicks += 1;
			rating_spr.pop_up_rating(0)
			#print("sick");
			
		totalHits += 1;
		combo += 1;
		Global.globalCombo += 1;
		
		if combo >= 10:
			combo_spr.pop_up_rating();
		else:
			combo_spr.hide();
			
		nums_spr.pop_up_rating();
		updateScoreText();
		
		pressed = true;
		
func miss_note():
	SoundStuff.playAudio("miss_sounds/missnote%s"%[randi_range(1, 3)], false);
	SoundStuff.audio.volume_db = -8
	voices.volume_db = -80;
	misses += 1;
	health -= 4 * health_loss;
	notesPlayed += 0;
	if combo > 10 && gf != null && SongData.chartData["song"]["player3"] != "none" && !GlobalOptions.hatsune_miku_mode:
		gf._playAnim("sad");
		combo = 0;
	combo = 0;
	Global.globalCombo = 0;
	rating_spr.pop_up_rating(4);
	updateScoreText();
	
	await get_tree().create_timer(0.3).timeout;
	voices.volume_db = 0;
	
func playBfMissAnim(curNote):
	if curNote.sustainLenght > 0 && !curNote.is_pressing:
		health -= 0.12;
		
	if curNote.sustainLenght > 0 && curNote.is_pressing && curNote.is_a_bad_note:
		health -= 0.12;
		
	if GlobalOptions.hatsune_miku_mode:
		return;
		
	var coolAnims = singAnims[int(curNote.noteData)%4];
	
	if bf.animList.has(coolAnims+" MISS"):
		bf._playAnim(coolAnims+" MISS");
		
	elif curNote.isGfNote && gf.animList.has(coolAnims+" MISS") && gf != null:
		gf._playAnim(coolAnims+" MISS");
		
func playBfAnim(curNote):
	if !health > 100 && !Global.is_a_bot:
		if curNote.sustainLenght <= 0:
			health += 3;
			
	if Global.is_a_bot:
		play_strum_anim(curNote, false, 0.30);
		
		if curNote.sustainLenght > 0 && curNote.is_pressing:
			play_strum_anim(curNote, false, 0.30);
			
		elif curNote.sustainLenght > 0 && !curNote.is_pressing:
			play_strum_anim(curNote, false, 0);
			
	elif !Global.is_a_bot && !curNote.sustainLenght > 0:
		var noteID = playerNote.get_child(curNote.noteData);
		noteID.play_note_anim("confirm");
		
	if GlobalOptions.hatsune_miku_mode:
		SoundStuff.playAudio("bop", false);
		if curNote.sustainLenght > 0 && curNote.is_pressing && !curNote.isGfNote && !curNote.is_hey_note:
			SoundStuff.playAudio("bop", false);
		return;
		
	if curNote.no_anim:
		return;
		
	var altAnim = "";
	var coolAnims = singAnims[int(curNote.noteData)%4];
	
	if curNote.is_altAnim:
		altAnim += "-alt";
	else:
		altAnim = "";
		 
	if curNote.isGfNote && gf != null:
		gf._playAnim(coolAnims);
		
	if curNote.is_hey_note:
		bf._playAnim("hey");
		
	if !curNote.isGfNote && !curNote.is_hey_note && !curNote.is_a_bad_note:
		bf._playAnim(coolAnims+altAnim);
		
		if bf.loopAnim && !curNote.isSustain:
			if bf.character is AnimatedSprite2D:
				bf.character.speed_scale = 1.0;
				bf.character.frame = 0;
				
			if bf.character is Sprite2D:
				bf.character_anim.playback_speed = 1.0;
				bf.character_anim.seek(0.0);
				
		if bf.loopAnim && curNote.sustainLenght > 0 or curNote.sustainLenght != 0:
			if bf.character is AnimatedSprite2D:
				bf.character.speed_scale = 4.0;
				
			if bf.character is Sprite2D:
				bf.character_anim.playback_speed = 4.0;
				
	if curNote.sustainLenght > 0 && curNote.is_pressing && !curNote.is_a_bad_note:
		if !health > 100 && !Global.is_a_bot:
			health += 0.13;
			
func playOpponentAnim(curNote):
	play_strum_anim(curNote, true if curNote.type != "Second opponent" else false, 0.30, false if curNote.type != "Second opponent" else true);
	if curNote.sustainLenght > 0 && curNote.is_pressing:
		play_strum_anim(curNote, true if curNote.type != "Second opponent" else false, 0.30, false if curNote.type != "Second opponent" else true);
	elif curNote.sustainLenght > 0 && !curNote.is_pressing:
		play_strum_anim(curNote, true if curNote.type != "Second opponent" else false, 0, false if curNote.type != "Second opponent" else true);
		
	if GlobalOptions.hatsune_miku_mode:
		SoundStuff.playAudio("bop", false)
		return;
		
	if curNote.no_anim:
		return;
		
	var altAnim = "";
	var coolAnims = singAnims[int(curNote.noteData)%4];
	
	if curNote.is_altAnim:
		altAnim += "-alt";
	else:
		altAnim = "";
		
	if curNote.isGfNote && gf != null:
		gf._playAnim(coolAnims);
		
	if curNote.is_hey_note:
		dad._playAnim("hey");
		
	if !curNote.isGfNote && !curNote.is_hey_note && curNote.type != "Second opponent":
		dad._playAnim(coolAnims+altAnim);
		
		if dad.loopAnim && !curNote.isSustain:
			if dad.character is AnimatedSprite2D:
				dad.character.speed_scale = 1.0;
				dad.character.frame = 0;
				
			if dad.character is Sprite2D:
				dad.character_anim.playback_speed = 1.0;
				dad.character_anim.seek(0.0);
				
		if dad.loopAnim && curNote.sustainLenght > 0 or curNote.sustainLenght != 0:
			if dad.character is AnimatedSprite2D:
				dad.character.speed_scale = 4.0
				
			if dad.character is Sprite2D:
				dad.character_anim.playback_speed = 4.0;
				
	if curNote.type == "Second opponent":
		new_opponent._playAnim(coolAnims+altAnim);
		
func play_strum_anim(note = null, is_opponent = true, timer = 0.0, is_second_opponent = false):
	if timer > 0.50:
		timer = 0;
		
	if is_second_opponent && !is_opponent:
		new_opponent_strumLine.reset_arrow_anim = timer;
		var noteID = new_opponent_strumLine.get_child(note.noteData);
		noteID.play_note_anim("confirm");
		
	if is_opponent && !is_second_opponent:
		opponentNote.reset_arrow_anim = timer;
		var noteID = opponentNote.get_child(note.noteData);
		noteID.play_note_anim("confirm");
		
	if !is_opponent && !is_second_opponent:
		playerNote.reset_arrow_anim = timer;
		var noteID = playerNote.get_child(note.noteData);
		noteID.play_note_anim("confirm");
		
func playerDead():
	print("player is dead");
	Global.death_count += 1;
	
	if GlobalOptions.hatsune_miku_mode:
		Global.reloadScene(true, false);
		
	elif bf.have_death_animation == true:
		Global.is_on_death_screen = true;
		can_pause = false;
		Global.changeScene("/gameplay/death_scene/death_scene", false, false);
	else:
		Global.reloadScene(true, false);
		
func newFc():
	var fc = "";
	if sicks > 0:
		fc = 'SFC'
	if goods > 0:
		fc = 'GFC'
	if bads > 0 && shits > 0:
		fc = 'FC'
	if misses >= 10:
		fc = 'Clear'
	if misses > 0 && misses < 10:
		fc = 'SDCB'
		
	return fc;
	
func newPercent():
	percent = float(notesPlayed/totalHits);
	#print(percent)
	
	if percent >= 0 && percent < 0.2:
		ratingName = "Kys";
	if percent >= 0.2 && percent < 0.4:
		ratingName = "Shit";
	if percent >= 0.4 && percent < 0.6:
		ratingName = "Bad";
	if percent >= 0.6 && percent < 0.8:
		ratingName = "Good";
	if percent >= 0.8 && percent < 1:
		ratingName = "Great";
	if percent >= 1:
		ratingName = "Perfect!!";
		
func _input(ev):
	if ev is InputEventKey:
		if ev.pressed && !ev.echo:
			if ev.keycode in [KEY_R] && !GlobalOptions.no_R:
				playerDead();
				
			if ev.keycode in [KEY_7] && can_pause:
				Global.songsShit = playlist if !Global.isStoryMode else playlist[0]; 
				Global.changeScene("menus/editors/chart_editor/chartState", true, false)
				
			if (ev.keycode in [KEY_ENTER] || ev.keycode in [KEY_KP_ENTER]) && can_pause:
				pause_menu.can_use = true;
				pause_menu.visible = true;
				
				pause_menu._paused();
				get_tree().paused = true;
				
				Discord.update_discord_info("pause", "Paused");
				
			if ev.keycode in [KEY_F1]:
				finishSong();
				
func startCoutdown():
	MusicManager._stop_music();
	is_on_intro = true;
	start_song = true;
	
	if skipIntro && is_on_intro:
		playerNote.appearNOW = true;
		opponentNote.appearNOW = true;
		can_pause = true;
		is_on_intro = false;
		Conductor.getSongTime = 0;
		if SongData.chartData["song"]["needsVoices"] && !GlobalOptions.hatsune_miku_mode:
			voices.play(0.0);
		inst.play(0.0);
		return;
		
	var countdownPath = "default";
	if SongData.chartData["song"]["isPixelStage"]:
		countdownPath = "pixel";
		
	var idle_loop = 0;
	for i in 5:
		await get_tree().create_timer(Conductor.crochet/1000).timeout;
		idle_loop += 1;
		if !GlobalOptions.hatsune_miku_mode:
			if SongData.chartData["song"]["player1"] != "none":
				if idle_loop % 2 == 0 && !bf.curAnim.begins_with("sing"):
					bf.dance();
					
			if SongData.chartData["song"]["player2"] != "none":
				if idle_loop % 2 == 0 && !dad.curAnim.begins_with("sing"):
					dad.dance();
					
			if SongData.chartData["song"]["player3"] != "none" && gf != null:
				if idle_loop % 2 == 0 && !gf.curAnim.begins_with("sing"):
					gf.dance();
					
			if SongData.chartData["song"]["two opponents"]:
				if SongData.chartData["song"]["player4"] != "none" && new_opponent != null:
					if idle_loop % 2 == 0 && !new_opponent.curAnim.begins_with("sing"):
						new_opponent.dance();
						
		var tween = get_tree().create_tween();
		match i:
			0:
				tween.tween_property(countdownSprite, "modulate:a", 1.0, 0.14)
				countdownSprite.texture = load("res://assets/images/coutdown/%s.png"%[countdownset[countdownPath][0] + ratingPart]);
				SoundStuff.playAudio("intro3", true if SongData.chartData["song"]["isPixelStage"] else false);
				tween.tween_property(countdownSprite, "modulate:a", 0.0, 0.14)
			1:
				tween.tween_property(countdownSprite, "modulate:a", 1.0, 0.14)
				countdownSprite.texture = load("res://assets/images/coutdown/%s.png"%[countdownset[countdownPath][1] + ratingPart]);
				SoundStuff.playAudio("intro2", true if SongData.chartData["song"]["isPixelStage"] else false);
				tween.tween_property(countdownSprite, "modulate:a", 0.0, 0.14)
			2:
				tween.tween_property(countdownSprite, "modulate:a", 1.0, 0.14)
				countdownSprite.texture = load("res://assets/images/coutdown/%s.png"%[countdownset[countdownPath][2] + ratingPart]);
				SoundStuff.playAudio("intro1", true if SongData.chartData["song"]["isPixelStage"] else false);
				tween.tween_property(countdownSprite, "modulate:a", 0.0, 0.14)
			3:
				tween.tween_property(countdownSprite, "modulate:a", 1.0, 0.14)
				SoundStuff.playAudio("introGo", true if SongData.chartData["song"]["isPixelStage"] else false);
				countdownSprite.texture = load("res://assets/images/coutdown/%s.png"%[countdownset[countdownPath][3] + ratingPart]);
				tween.tween_property(countdownSprite, "modulate:a", 0.0, 0.14)
				
		if i == 4:
			countdownSprite.hide();
			can_pause = true;
			is_on_intro = false;
			if SongData.chartData["song"]["needsVoices"] && !GlobalOptions.hatsune_miku_mode:
				voices.play(0.0);
			inst.play(0.0);
			tween.stop();
			
func startSong():
	if SongData.chartData["song"]["song"] != "":
		var music_inst = load("res://assets/songs/" + SongData.chartData["song"]["song"].to_lower() + "/Inst.ogg");
		var music_voices = load("res://assets/songs/" + SongData.chartData["song"]["song"].to_lower() + "/Voices.ogg");
		
		inst.stream = music_inst;
		voices.stream = music_voices;
		
func finishSong():
	Global.death_count = 0;
	print("song finished");
	if score > HighScore.get_score(playlist if !Global.isStoryMode else playlist[0], "" if songDiff == "normal" else str('-', songDiff)):
		HighScore.get_song_score(playlist if !Global.isStoryMode else playlist[0], "" if songDiff == "normal" else str('-', songDiff), score);
		
	inst.stop();
	voices.stop();
	can_pause = false;
	if Global.isStoryMode:
		playlist.erase(playlist[0]);
		print(playlist);
		if playlist.size() == 0:
			await get_tree().create_timer(0.1).timeout
			print("go to story mode");
			Global.changeScene("menus/story_mode/storyMode", true, false);
			Global.week_status[Global.cur_week] = true;
			Global.save_week_status();
			MusicManager._play_music("freakyMenu", true, true);
			
		elif playlist.size() > 0:
			await get_tree().create_timer(0.1).timeout
			print("load NEW song");
			Global.reloadScene();
			SongData.loadJson(playlist[0], "" if songDiff == "normal" else songDiff);
	else:
		await get_tree().create_timer(0.2).timeout
		Global.changeScene("menus/freeplay/freeplay_menu", true, false)
		MusicManager._play_music("freakyMenu", true, true);
		print("go to freeplay")
		
	if Global.is_on_chartMode:
		Global.changeScene("menus/editors/chart_editor/chartState", true, false)
		MusicManager._play_music("freakyMenu", true, true);
		
func updateScoreText():
	if totalHits <= 0:
		ratingName = "???";
	else:
		newPercent();
		
	if totalHits <= 0:
		scoreText.text = 'Score: %s / Misses: %s / Rating: ???'%[score, misses];
	else:
		scoreText.position.x = 260;
		scoreText.text = 'Score: %s / Misses: %s / Rating: %s(%s) - %s'%[score, misses, ratingName, str(snapped(float(notesPlayed/totalHits)*100, 0.01), "%"), newFc()];
		
func step_hit(step):
	var curSection = floor(step/16);
	
	if curSection < SongData.chartData["song"]["notes"].size():
		if SongData.chartData["song"]["notes"][curSection]["changeBPM"]:
			#Conductor.changeBpm(SongData.chartData["song"]["notes"][curSection]["bpm"]);
			
			Conductor.bpm = SongData.chartData["song"]["notes"][curSection]["bpm"];
			Conductor.crochet = ((60 / float(SongData.chartData["song"]["notes"][curSection]["bpm"])) * 1000);
			Conductor.stepCrochet = Conductor.crochet/4;
			
			print('change bpm: ', SongData.chartData["song"]["notes"][curSection]["bpm"]);
			
		camera_on_Bf = SongData.chartData["song"]["notes"][curSection]["mustHitSection"];
		gf_is_singing = SongData.chartData["song"]["notes"][curSection]["gfSection"];
		
		if gf_is_singing:
			camera_position = Vector2(gf.position.x, gf.position.y);
			
		elif camera_on_Bf:
			camera_position = Vector2(bf.position.x, bf.position.y);
			
		else:
			camera_position = Vector2(dad.position.x, dad.position.y);
			
	sectionCamera.position.y = camera_position.y;
	sectionCamera.position.x = camera_position.x;
	
func beat_hit(beat):
	if !GlobalOptions.hatsune_miku_mode:
		if SongData.chartData["song"]["player1"] != "none":
			if beat % 2 == 0 && !bf.curAnim.begins_with("sing"):
				bf.dance();
				
		if SongData.chartData["song"]["player2"] != "none":
			if beat % 2 == 0 && !dad.curAnim.begins_with("sing"):
				dad.dance();
				
		if SongData.chartData["song"]["player3"] != "none" && gf != null:
			if beat % 2 == 0 && !gf.curAnim.begins_with("sing"):
				gf.dance();
				
		if SongData.chartData["song"]["two opponents"]:
			if SongData.chartData["song"]["player4"] != "none" && new_opponent != null:
				if beat % 2 == 0 && !new_opponent.curAnim.begins_with("sing"):
					new_opponent.dance();
					
	if beat % 4 == 0 && !is_on_intro:
		sectionCamera.zoom = Vector2(0.83, 0.83) if curStage != "school" else lerp(sectionCamera.zoom, Vector2(1.2, 1.2), 0.09);
		
	if curStage == "spooky mansion" && randf_range(0, 50) <= 2 && !is_on_intro:
		stage.lightning();
		
		if GlobalOptions.hatsune_miku_mode:
			return;
			
		if bf.animList.has("idle shaking"):
			bf._playAnim("idle shaking");
			
		if gf.animList.has("scared") && SongData.chartData["song"]["player3"] != "none" && gf != null:
			gf._playAnim("scared")
			
	if curStage == "philly" && beat % 4 == 0:
		stage.setRandomLight();
		
	if curStage == "philly" && beat % 8 == 4 && randf_range(0, 50) <= 10 && !is_on_intro:
		stage.trigger_train();
		
	if animatedIconP1.get_child_count() > 0:
		animatedIconP1.get_child(0).scale = Vector2(1.2, 1.2);
		
	if animatedIconP2.get_child_count() > 0:
		animatedIconP2.get_child(0).scale = Vector2(1.2, 1.2);
		
	iconP1.scale = Vector2(1.2, 1.2);
	iconP2.scale = Vector2(1.2, 1.2);
	
#cool stuff :>
func changeCharacter(id = 0, char = "boyfriend"):
	match id:
		0, "bf":
			remove_child(bf);
			bf = load("res://source/characters/%s.tscn"%[char]);
			bf.curIcon = bf.charData["HealthIcon"];
			iconP1.texture = load("res://assets/images/icons/icon-%s.png"%[bf.curIcon]);
			add_child(bf);
		1, "gf":
			if SongData.chartData["song"]["player3"] != "" && gf != null:
				remove_child(gf);
				gf = load("res://source/characters/%s.tscn"%[char]);
				gf.curIcon = gf.charData["HealthIcon"];
				add_child(gf);
			else:
				gf.hide();
		2, "dad":
			remove_child(dad);
			dad = load("res://source/characters/%s.tscn"%[char]);
			dad.curIcon = dad.charData["HealthIcon"];
			iconP2.texture = load("res://assets/images/icons/icon-%s.png"%[dad.curIcon])
			add_child(dad);
			
func changeBg(newBg = "stage"):
	stageGrp.remove_child(stage);
	stage = load("res://source/stage/%s.tscn"%[newBg]).instantiate();
	curStage = stage.stage;
	stageGrp.add_child(stage);
	
func characterPlayAnim(id = 0, anim = "idle dance"):
	match id:
		0, "bf":
			bf._playAnim(anim);
		1, "gf":
			if SongData.chartData["song"]["player3"] != "" && gf != null:
				gf._playAnim(anim);
		2, "dad":
			dad._playAnim(anim);
			
