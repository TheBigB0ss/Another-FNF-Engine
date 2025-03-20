extends Node2D

@onready var characterGrp = $"character";
@onready var characters_options = $"CanvasLayer/characters";
@onready var cur_anim_text = $'CanvasLayer/current_anim';

var cur_pose = 0;
var character_list = [];
var offset_array = [];
var replaced = "";

var characterJson = {};
var characterData = [];
var offset_count = 0;

func _ready():
	Discord.update_discord_info("offset menu", "Is in menus")
	Global.is_on_death_screen = false;
	MusicManager._play_music(GlobalOptions.updated_pause_music, false, true);
	
	for i in addCharToList():
		if i.contains(".json"):
			replaced = i.replace(".json", "");
			
		character_list.append(replaced)
		characters_options.add_item(i.replace(".json", ""))
		
	characters_options.connect("item_selected",change_character);
	
	change_character(0);
	change_anim(0);
	play_anim();
	print(character_list)
	
func get_char_json(char, cur_offset = 0):
	var offset = {}
	var replaced = char;
	
	if char.contains(".tscn"):
		replaced = char.replace(".tscn", "");
		
	var jsonFile = FileAccess.open("res://assets/characters/%s.json"%[replaced],FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	offset = jsonData.get_data()
	jsonFile.close();
	return offset["Poses"][cur_offset]["Offset"]
	
func change_character(char):
	for i in characterGrp.get_children():
		characterGrp.remove_child(i);
		i.queue_free();
		
	offset_array = [];
	offset_count = 0;
	cur_pose = 0;
	characterData = [];
	characterJson = {};
	
	var character = load("res://source/characters/%s.tscn"%[character_list[characters_options.selected]]).instantiate();
	characterGrp.add_child(character);
	
	for i in characterGrp.get_children():
		%color_text.text = i.charData["HealthBarColor"];
		%icon_text.text = i.curIcon;
		%x_scale.value = i.charData["scale"][0];
		%y_scale.value = i.charData["scale"][1];
		%flipX.button_pressed = i.charData["FlipX"];
		%flipY.button_pressed = i.charData["FlipY"];
		%loopAnim.button_pressed = i.loopAnim;
		
		update_scale_value(i.charData["scale"][0], i.charData["scale"][1])
		flip_char(i.charData["FlipX"], i.charData["FlipY"]);
		
	change_anim(0);
	
func update_offset_value(x = 0, y = 0):
	for i in characterGrp.get_children():
		i.character.offset = Vector2(x, y)
		
func update_scale_value(x = 1, y = 1):
	for i in characterGrp.get_children():
		i.character.scale.x = x
		i.character.scale.y = y
		
func flip_char(flipX, flipY):
	for i in characterGrp.get_children():
		i.character.flip_h = flipX;
		i.character.flip_v = flipY;
		
func play_anim():
	for i in characterGrp.get_children():
		i.character.play(i.posesList[cur_pose]);
		
var pos_change_value = 0
func _input(ev) -> void:
	if ev is InputEventKey:
		if ev.pressed && !ev.echo:
			if ev.keycode in [KEY_ESCAPE] && !ev.echo:
				MusicManager._play_music("freakyMenu", true, true);
				Global.changeScene("menus/main_menu/MainMenu", true, false);
				
			if ev.keycode in [KEY_E]:
				change_anim(1);
				
			if ev.keycode in [KEY_Q]:
				change_anim(-1);
				
			if ev.keycode in [KEY_SPACE]:
				play_anim();
				
			if ev.keycode in [KEY_RIGHT]:
				offset_array[cur_pose][0] += pos_change_value
				update_offset_value(offset_array[cur_pose][0], offset_array[cur_pose][1])
				
			if ev.keycode in [KEY_LEFT]:
				offset_array[cur_pose][0] -= pos_change_value
				update_offset_value(offset_array[cur_pose][0], offset_array[cur_pose][1])
				
			if ev.keycode in [KEY_DOWN]:
				offset_array[cur_pose][1] += pos_change_value
				update_offset_value(offset_array[cur_pose][0], offset_array[cur_pose][1])
				
			if ev.keycode in [KEY_UP]:
				offset_array[cur_pose][1] -= pos_change_value
				update_offset_value(offset_array[cur_pose][0], offset_array[cur_pose][1])
				
func change_anim(change):
	if offset_array != []:
		cur_pose += change;
		print(cur_pose)
		cur_pose = wrapi(cur_pose, 0, offset_array.size());
		
		for i in characterGrp.get_children():
			cur_anim_text.text = "animation: %s"%[i.animList[cur_pose]];
			update_offset_value(offset_array[cur_pose][0], offset_array[cur_pose][1]);
			play_anim();
			
var character_data_array = [];
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_shift"):
		pos_change_value = 1;
	else:
		pos_change_value = 10;
		
	for i in characterGrp.get_children():
		if !offset_count > i.animList.size()-1:
			offset_array.append(get_char_json(character_list[characters_options.selected], offset_count))
			
			characterData.append({
				"Name": i.posesList[offset_count],
				"Anim": i.animList[offset_count],
				"Offset": [0, 0]
			});
			
			offset_count += 1;
			
		character_data_array.append(characterData);
		characterData[cur_pose]["Offset"] = [
			offset_array[cur_pose][0],
			offset_array[cur_pose][1]
		];
		#print(character_data_array)
		
		characterJson = {
			"Poses": characterData,
			"HealthBarColor": %color_text.text,
			"HealthIcon": %icon_text.text,
			"FlipX": %flipX.button_pressed,
			"FlipY": %flipY.button_pressed,
			"isPlayer": %is_player.button_pressed,
			"AnimatedIcon": %animated_icon.button_pressed,
			"scale": [%x_scale.value, %y_scale.value],
			"LoopAnim": %loopAnim.button_pressed
		};
		
	#print(get_global_mouse_position().x, " ", get_global_mouse_position().y)
	#for i in characterGrp.get_children():
	#	print( i.character.scale.x, " ", i.character.scale.y)
	
	#if Input.is_action_just_pressed("mouse_click"):
	#	for i in characterGrp.get_children():
	#		if get_global_mouse_position().x >= i.character.position.x && get_global_mouse_position().x <= i.character.position.x + i.character.scale.x*50 && get_global_mouse_position().y > i.character.position.y && get_global_mouse_position().y < i.character.position.y + i.character.scale.y*50:
	#			update_offset_value(get_global_mouse_position().x, get_global_mouse_position().y)
	#			print("vifnij")
	
func addCharToList():
	var charList = [];
	var char = getFolderShit("assets/characters/");
	for i in char:
		if i.ends_with(".json") && !i == "none":
			charList.append(i);
	return charList;
	
func getFolderShit(folder):
	var file = [];
	var coolFolder = DirAccess.open("res://%s"%[folder]);
	if coolFolder:
		coolFolder.list_dir_begin();
		var nameShit = coolFolder.get_next();
		while nameShit != "":
			file.append(nameShit);
			nameShit = coolFolder.get_next();
	return file;
	
func save_file() -> void:
	$FileDialog.popup_centered();
	
func _on_file_dialog_file_selected(json):
	var new_jsonFile = FileAccess.open(json, FileAccess.WRITE);
	new_jsonFile.store_string(JSON.stringify(characterJson, "\t"));
	new_jsonFile.close();
	print(characterJson)
	print('save: ', json);
	
func _on_x_scale_value_changed(value: float) -> void:
	update_scale_value(value, %y_scale.value)
	
func _on_y_scale_value_changed(value: float) -> void:
	update_scale_value(%x_scale.value, value)
	
func _on_flip_x_pressed() -> void:
	flip_char(%flipX.button_pressed, %flipY.button_pressed);
	
func _on_flip_y_pressed() -> void:
	flip_char(%flipX.button_pressed, %flipY.button_pressed);
