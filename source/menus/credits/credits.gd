extends Node

@onready var opts = $'creditsOpts';
@onready var socialOpts = $'socialOpts';

var coolOffset = 145;
var offSetShit = 0;

@onready var bg = $'Bg';

@onready var devName = $'Texts/name';
@onready var devRole = $'Texts/role';
@onready var groupTxt = $'Texts/Label';

var creditSelected = 0;
var socialSelected = 0;
var creditsJson:Dictionary = {
	"dev_info": [
		{
			"team": "",
			"name": "",
			"role": "",
			"icon": "",
			"social midia": [[]],
			"bg_color": ""
		}
	]
}

#lembre de tentar usar .keys()
func _ready():
	Discord.update_discord_info("credits menu", "Is in menus")
	
	var jsonFile = FileAccess.open("res://assets/data/credits_data.json" ,FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	creditsJson = jsonData.get_data();
	jsonFile.close();
	
	for i in creditsJson["dev_info"]:
		var icon = Sprite2D.new();
		icon.texture = load("res://assets/images/credits/%s.png"%[i["icon"]]);
		icon.position.y = offSetShit;
		icon.position.x -= 40;
		opts.add_child(icon);
		offSetShit += coolOffset;
		
	changeDev(0);
	change_social_midia(0);
	
func _input(event):
	if event is InputEventKey:
		if event.pressed && !event.echo:
			if event.keycode in [KEY_DOWN]:
				changeDev(1);
				
			if event.keycode in [KEY_UP]:
				changeDev(-1);
				
			if len(creditsJson["dev_info"][creditSelected]["social midia"].keys()) > 0:
				if event.keycode in [KEY_LEFT]:
					change_social_midia(-1);
					
				if event.keycode in [KEY_RIGHT]:
					change_social_midia(1);
					
				if (event.keycode in [KEY_ENTER] || event.keycode in [KEY_KP_ENTER]):
					open_link();
					
			if event.keycode in [KEY_ESCAPE]:
				Global.changeScene("menus/main_menu/MainMenu", true, false);
				
func changeDev(shit):
	creditSelected += shit;
	creditSelected = wrapi(creditSelected, 0, len(creditsJson["dev_info"]));
	SoundStuff.playAudio("scrollMenu", false);
	
	change_social_midia(0);
	updateDev();
	
func change_social_midia(shit):
	socialSelected += shit;
	socialSelected = wrapi(socialSelected, 0, len(creditsJson["dev_info"][creditSelected]["social midia"].keys()));
	SoundStuff.playAudio("scrollMenu", false);
	
	update_midia();
	
func update_social_icons():
	var social_offset = 165;
	var social_offset_shit = 0;
	
	for i in socialOpts.get_children():
		socialOpts.remove_child(i);
		i.queue_free();
		
	for i in creditsJson["dev_info"][creditSelected]["social midia"].keys():
		var social_icon = Sprite2D.new();
		social_icon.texture = load("res://assets/images/credits/social_midia/%s.png"%[i]);
		social_icon.position.x = social_offset_shit;
		social_icon.position.y -= 40;
		socialOpts.add_child(social_icon);
		social_offset_shit += social_offset;
		
func update_midia():
	update_social_icons()
	for i in len(creditsJson["dev_info"][creditSelected]["social midia"].keys()):
		if i == socialSelected:
			socialOpts.get_children()[i].modulate.a = 1;
		else:
			socialOpts.get_children()[i].modulate.a = 0.5;
			
func updateDev():
	devName.text = "";
	devRole.text = "";
	groupTxt.text = "";
	
	devName.text = creditsJson["dev_info"][creditSelected]["name"]
	devRole.text = creditsJson["dev_info"][creditSelected]["role"]
	groupTxt.text = creditsJson["dev_info"][creditSelected]["team"] 
	
	for j in creditsJson["dev_info"].size():
		if j == creditSelected:
			opts.get_children()[j].modulate.a = 1;
		else:
			opts.get_children()[j].modulate.a = 0.5;
			
	var tw = get_tree().create_tween();
	tw.tween_property(opts, "position:y", 480-coolOffset*creditSelected, 0.10).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
	var color_tw = get_tree().create_tween();
	color_tw.tween_property(bg, "modulate", Color(creditsJson["dev_info"][creditSelected]["bg_color"]), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
func open_link():
	OS.shell_open(creditsJson["dev_info"][creditSelected]["social midia"][creditsJson["dev_info"][creditSelected]["social midia"].keys()[socialSelected]]);
