@tool
extends Control

func _on_button_pressed() -> void:
	var click = EditorInterface.get_selection()
	if %CheckBox2.button_pressed == false:
		create_res_file(%LineEdit1.text, %LineEdit2.text, %CheckBox.button_pressed, %SpinBox.value)
		
	if %CheckBox2.button_pressed == true:
		create_tscn_file(%LineEdit1.text, %LineEdit2.text, %CheckBox.button_pressed, %SpinBox.value)
		
func create_tscn_file(image, anim, haveLoop, fps):
	var node = Node2D.new();
	var animPlayer = AnimationPlayer.new();
	var sprite = Sprite2D.new();
	
	node.name = anim;
	node.set_script(preload("res://source/characters/characters_scripts/New_Character.gd"));
	sprite.name = "Character_Sprite";
	animPlayer.name = "Character_Animation";
	
	sprite.texture = load("res://assets/%s.png"%[image]);
	sprite.region_enabled = true;
	
	node.add_child(sprite);
	node.add_child(animPlayer);
	sprite.set_owner(node);
	animPlayer.set_owner(node);
	
	var fileParser = XMLParser.new();
	fileParser.open("res://assets/%s.xml"%[image]);
	
	if fileParser.read() != OK:
		print("error in %s.xml"%[image]);
		return;
		
	var new_animation = [];
	var new_xmlList = [];
	var data_list = [];
	var new_anim_data = [];
	
	while fileParser.read() == OK:
		var xmlList = {
			"animation": [],
			"x": fileParser.get_named_attribute_value_safe("x").to_int(),
			"y": fileParser.get_named_attribute_value_safe("y").to_int(),
			"width": fileParser.get_named_attribute_value_safe("width").to_int(),
			"height": fileParser.get_named_attribute_value_safe("height").to_int(),
			"frameX": fileParser.get_named_attribute_value_safe("frameX").to_int(),
			"frameY": fileParser.get_named_attribute_value_safe("frameY").to_int()
		};
		
		if fileParser.get_named_attribute_value_safe("name") != '':
			var animArray = [];
			for i in fileParser.get_named_attribute_value_safe("name"):
				animArray.append(i);
				
			xmlList["animation"].append(''.join(animArray).substr(0, animArray.size() - 4));
			
			for i in xmlList["animation"]:
				if !new_animation.has(i):
					new_animation.append(i)
					
			new_anim_data.append_array(xmlList["animation"])
			
			new_xmlList = {
				xmlList["animation"][0]: [xmlList["x"], xmlList["y"], xmlList["width"], xmlList["height"], xmlList["frameX"], xmlList["frameY"]]
			};
			data_list.append(new_xmlList)
			
	for i in new_animation.size():
		var new_anim = Animation.new();
		var anim_lib = AnimationLibrary.new();
		var index = new_anim.add_track(Animation.TYPE_VALUE);
		var index_margin = new_anim.add_track(Animation.TYPE_VALUE);
		var anim_name = new_animation[i];
		
		new_anim.track_set_interpolation_type(index, Animation.INTERPOLATION_NEAREST);
		new_anim.track_set_interpolation_type(index_margin, Animation.INTERPOLATION_NEAREST);
		
		new_anim.track_set_path(index, "%s:region_rect"%[node.get_path_to(sprite)]);
		new_anim.track_set_path(index_margin, "%s:offset"%[node.get_path_to(sprite)]);
		
		new_anim.loop_mode = haveLoop;
		
		var cur_frame = 0;
		for j in new_anim_data.size():
			for key in data_list[j].keys():
				if key == anim_name:
					new_anim.track_insert_key(index, cur_frame*0.03, Rect2(data_list[j][key][0], data_list[j][key][1], data_list[j][key][2], data_list[j][key][3]));
					new_anim.track_insert_key(index_margin, cur_frame*0.03, -Vector2(data_list[j][key][4], data_list[j][key][5]) / 2);
					new_anim.length = cur_frame*0.03
					cur_frame += 1;
					
		anim_lib.add_animation(" ", new_anim);
		animPlayer.add_animation_library(new_animation[i], anim_lib);
		
	var packed_scene = PackedScene.new();
	packed_scene.pack(node);
	
	ResourceSaver.save(packed_scene, "res://assets/%s"%[anim] + ".tscn", ResourceSaver.FLAG_COMPRESS);
	
func create_res_file(image, anim, haveLoop, fps):
	var fileParser = XMLParser.new();
	fileParser.open("res://assets/%s.xml"%[image]);
	
	if fileParser.read() != OK:
		print("error in %s.xml"%[image]);
		return;
		
	var node = Node2D.new();
	var animated_spr = AnimatedSprite2D.new();
	
	var animationSTUFF = SpriteFrames.new();
	animationSTUFF.remove_animation("default");
	
	node.name = anim;
	node.set_script(preload("res://source/characters/characters_scripts/Character.gd"));
	animated_spr.name = "character";
	
	node.add_child(animated_spr);
	animated_spr.set_owner(node);
	
	while fileParser.read() == OK:
		var xmlList = {
			"animation": [],
			"x": fileParser.get_named_attribute_value_safe("x").to_int(),
			"y": fileParser.get_named_attribute_value_safe("y").to_int(),
			"width": fileParser.get_named_attribute_value_safe("width").to_int(),
			"height": fileParser.get_named_attribute_value_safe("height").to_int(),
			"frameX": fileParser.get_named_attribute_value_safe("frameX").to_int(),
			"frameY": fileParser.get_named_attribute_value_safe("frameY").to_int()
		};
		
		var frameTexture = AtlasTexture.new();
		frameTexture.atlas = load("res://assets/%s.png"%[image])
		
		if fileParser.get_named_attribute_value_safe("name") != '':
			var animArray = [];
			for i in fileParser.get_named_attribute_value_safe("name"):
				animArray.append(i);
				
			xmlList["animation"].append(''.join(animArray).substr(0, animArray.size() - 4));
			
			frameTexture.region = Rect2(
				Vector2(xmlList["x"], xmlList["y"]),
				Vector2(xmlList["width"], xmlList["height"])
			);
			
			var frame_offset = -Vector2(xmlList["frameX"], xmlList["frameY"]);
			var frame_size = Vector2(
				xmlList["width"] -frameTexture.region.size.x,
				xmlList["height"] -frameTexture.region.size.y
			);
			
			frameTexture.margin = Rect2(frame_offset, frame_size);
			
			if frameTexture.margin.size.x < abs(frameTexture.margin.position.x):
				frameTexture.margin.size.x = abs(frameTexture.margin.position.x);
				
			if frameTexture.margin.size.y < abs(frameTexture.margin.position.y):
				frameTexture.margin.size.y = abs(frameTexture.margin.position.y);
				
			var curAnimation = '';
			for j in xmlList["animation"]:
				if j != '':
					curAnimation = j;
					
			if !animationSTUFF.has_animation(curAnimation):
				animationSTUFF.add_animation(curAnimation);
				animationSTUFF.set_animation_loop(curAnimation, haveLoop);
				animationSTUFF.set_animation_speed(curAnimation, fps);
			animationSTUFF.add_frame(curAnimation, frameTexture);
			
			print("animation is: "+curAnimation);
			
	animated_spr.sprite_frames = animationSTUFF;
	
	var packed_scene = PackedScene.new();
	packed_scene.pack(node);
	
	ResourceSaver.save(packed_scene, "res://assets/%s"%[anim] + ".tscn", ResourceSaver.FLAG_COMPRESS);
	ResourceSaver.save(animationSTUFF, "res://assets/%s"%[anim] + ".res", ResourceSaver.FLAG_COMPRESS);
	
