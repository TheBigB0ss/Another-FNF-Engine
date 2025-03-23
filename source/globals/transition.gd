extends CanvasLayer

var stickersTimer = Timer.new();

@onready var fade_anim = $'Control/Fade_anim';
@onready var stickersGrp = $'Control/stickers';

var transition_speed = 0.65
var can_show_stickers = true;
var stickersArray = [];
var deleteStickers = false;
var jsonStickers:Dictionary = {
	"Bf": [],
	"Gf": [],
	"Dad": [],
	"Mom": [],
	"Monster": [],
	"Pico": []
}

func _ready():
	$Control.hide();
	fade_anim.speed_scale = transition_speed
	add_child(stickersTimer)
	if !deleteStickers && stickersGrp.get_child_count() <= 75:
		stickersTimer.connect("timeout", spawnStickers)
		
	var jsonFile = FileAccess.open("res://assets/data/jsonSticker.json",FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	jsonStickers = jsonData.get_data()
	jsonFile.close();
	
	for i in jsonStickers.keys():
		for j in jsonStickers[i]:
			stickersArray.append(j);
			
func spawnStickers():
	if !deleteStickers && stickersGrp.get_child_count() <= 75:
		for i in 1:
			if can_show_stickers:
				SoundStuff.playAudio("stickerSounds/keyClick%s"%[randi_range(1, 8)], false);
			var random_sticker = stickersArray.pick_random()
			var trasitionStickers = Sprite2D.new();
			trasitionStickers.texture = load("res://assets/images/stickers/%s.png"%[random_sticker]);
			trasitionStickers.position.x = randi_range(0, 1380);
			trasitionStickers.position.y = randi_range(0, 810);
			trasitionStickers.rotation = randi_range(-20, 1050);
			stickersGrp.add_child(trasitionStickers);
			
		if stickersGrp.get_child_count() > 0:
			Global.can_use_menus = false;
	else:
		removeStickers();
		
func removeStickers():
	if deleteStickers && stickersGrp.get_child_count() > 0:
		for i in 1:
			if can_show_stickers:
				SoundStuff.playAudio("stickerSounds/keyClick%s"%[randi_range(1, 8)], false);
			var removed_child = stickersGrp.get_child(i)
			stickersGrp.remove_child(removed_child)
			removed_child.queue_free()
			
	if stickersGrp.get_child_count() <= 0:
		Global.can_use_menus = true;
		
func _is_in_transition(use_stickers):
	$Control.show();
	$Control/TransMaksDown.show();
	$Control/TransMaksUp.show();
	
	deleteStickers = false;
	can_show_stickers = use_stickers;
	stickersTimer.wait_time = 0.01;
	
	fade_anim.play("fade_in")
	if can_show_stickers:
		stickersGrp.show();
		if !deleteStickers:
			stickersTimer.start();
		else:
			stickersTimer.stop();
	else:
		stickersGrp.hide();
		
func _on_fade_anim_animation_finished(anim_name):
	if anim_name == "fade_in":
		fade_anim.play("fade_out");
		
	if anim_name == "fade_out":
		await get_tree().create_timer(0.1).timeout
		$Control/TransMaksDown.hide();
		$Control/TransMaksUp.hide();
		if !can_show_stickers:
			Global.can_use_menus = true;
		deleteStickers = true;
