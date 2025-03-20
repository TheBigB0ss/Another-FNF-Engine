extends CharacterData

@export var have_death_animation = false;
@export var death_scene = "";
@export var json_path = "";
@onready var character = $'Character_Sprite';
@onready var character_anim = $'Character_Animation';

var healthBar_Color = Color();
var curIcon = '';
var animatedIcon = false;
var loopAnim = false;
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
		
	dance();
	
func _process(delta):
	if curAnim.begins_with("sing") or curAnim.contains("sing"):
		idleTimer += delta;
		
	if idleTimer >= Conductor.stepCrochet * 5 * 0.001:
		if curAnim.contains("sing"):
			dance();
			idleTimer = 0;
			
var can_dance = false;
var have_anims = false;
func dance():
	can_dance = animList.has("danceRight") && animList.has("danceLeft");
	if can_dance:
		can_dance = !can_dance;
		if can_dance:
			_playAnim("danceRight");
		else:
			_playAnim("danceLeft");
			
	if animList.has("idle dance"):
		character_anim.playback_speed = 1.0;
		_playAnim("idle dance");
		
func _playAnim(anim):
	for i in animList.size():
		if animList[i] == anim:
			#character.offset.x = charData["Poses"][i]["Offset"][0];
			#character.offset.y = charData["Poses"][i]["Offset"][1];
			if !loopAnim:
				character_anim.seek(0.0);
				
			character_anim.play(str(posesList[i], "/ "));
			
			if animList[i].begins_with("sing"):
				idleTimer = 0;
				
	curAnim = anim;
	
