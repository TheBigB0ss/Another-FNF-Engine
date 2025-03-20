extends CharacterData

@export var json_path = "";
@onready var character = $'character';

var animatedIcon = false;
var loopAnim = false;
var healthBar_Color = Color();
var curIcon = '';

var curAnim = "";
var anim_offset = []
var idleTimer = 0;

func _ready():
	charPath = json_path;
	
	var jsonFile = FileAccess.open("res://assets/characters/%s.json"%[charPath],FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	charData = jsonData.get_data()
	jsonFile.close();
	
	if !charData.has("AnimatedIcon"):
		charData["AnimatedIcon"] = false;
		
	if !charData.has("scale"):
		charData["scale"] = [1, 1];
		
	if !charData.has("LoopAnim"):
		charData["LoopAnim"] = false;
		
	character.scale = Vector2(charData["scale"][0], charData["scale"][1]);
	
	character.flip_h = charData["FlipX"];
	character.flip_v = charData["FlipY"];
	
	curIcon = charData["HealthIcon"];
	animatedIcon = charData["AnimatedIcon"];
	healthBar_Color = Color(charData["HealthBarColor"]);
	loopAnim = charData["LoopAnim"];
	
	for i in charData["Poses"].size():
		animList.append(charData["Poses"][i]["Anim"]);
		posesList.append(charData["Poses"][i]["Name"]);
		
	_playAnim("dead")
	
	if Global.is_on_death_screen:
		SoundStuff.playAudio("game over/fnf_loss_sfx", false);
		
		if json_path == "Bf Pixel dead":
			SoundStuff.playAudio("game over/fnf_loss_sfx", true);
			
func _process(delta):
	if curAnim.begins_with("dead") && curAnim != "dead loop" && Global.is_on_death_screen:
		idleTimer += delta;
		
	if idleTimer >= 2 && curAnim != "dead confirm" && Global.is_on_death_screen:
		bf_loop_anim();
		idleTimer = 0;
		
	if curAnim == "dead confirm" && idleTimer >= 2.5 && idleTimer < 2.6 && Global.is_on_death_screen:
		print("go back")
		idleTimer = 0;
		SongData.loadJson(Global.songsShit[0] if Global.isStoryMode else Global.songsShit, Global.diffsShit);
		Global.changeScene("gameplay/PlayState", true, false);
		
func _playAnim(anim):
	for i in animList.size():
		if animList[i] == anim:
			character.offset.x = charData["Poses"][i]["Offset"][0];
			character.offset.y = charData["Poses"][i]["Offset"][1];
			character.play(posesList[i]);
			character.frame = 0;
			
	curAnim = anim;
	
func bf_loop_anim():
	if Global.is_on_death_screen:
		MusicManager._play_music("game over/gameOver", false, true);
		
		if json_path == "Bf Pixel dead":
			MusicManager._play_music("game over/gameOver-pixel", false, true);
			
		_playAnim("dead loop");
		
var confirm = false;
func _input(ev):
	if ev is InputEventKey && Global.is_on_death_screen:
		if ev.pressed && !ev.echo && !confirm:
			if ev.keycode in [KEY_ENTER] && curAnim != "dead" && idleTimer == 0:
				MusicManager._play_music("game over/gameOverEnd", false, false);
				if json_path == "Bf Pixel dead":
					MusicManager._play_music("game over/gameOverEnd-pixel", false, true);
					
				_playAnim("dead confirm");
				confirm = true;
				
			if ev.keycode in [KEY_ESCAPE]:
				Global.death_count = 0;
				MusicManager._play_music("freakyMenu", true, true);
				Global.changeScene("menus/main_menu/MainMenu");
				confirm = true
