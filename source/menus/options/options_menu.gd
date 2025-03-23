extends Node2D

@onready var options_stuff = $'options';
@onready var settings_stuff = $'settings';
@onready var settings = $'settings/new_options';
@onready var description_text = $'settings/Label';
@onready var option_suffix_stuff = $'settings/option_suffix';

var offSetShit = 0;
var coolOffset = 140;

var is_on_settings_mode = false;

var new_cur_option = 0;
var cur_option = 0;

var options_array = [];
var new_options_array = [];

var is_on_key_mode = false;
var options = {
	"graphics": {
		"fps":{
			"value": int(GlobalOptions.fps),
			"description": "change FPS"
		},
		"vsync":{
			"value": GlobalOptions.vsync,
			"description": "enabled vsync"
		},
		"low quality":{
			"value": GlobalOptions.low_quality,
			"description": "it help... i gues.."
		}
	},
	"controls": {
		"Left Key:":{
			"value": GlobalOptions.keys[0][0],
			"description": "change left key"
		},
		"Down Key:":{
			"value": GlobalOptions.keys[1][0],
			"description": "change down key"
		},
		"Up Key:":{
			"value": GlobalOptions.keys[2][0],
			"description": "change up key"
		},
		"Right Key:":{
			"value": GlobalOptions.keys[3][0],
			"description": "change right key"
		}
	},
	"visual": {
		"hide hud":{
			"value": GlobalOptions.hide_hud, 
			"description": "hide your hude"
		},
		"health bar alpha":{
			"value": GlobalOptions.health_bar_alpha, 
			"description": "your health bar opacity"
		},
		"time bar alpha":{
			"value": GlobalOptions.time_bar_alpha, 
			"description": "your time bar opacity"
		},
		"show FPS":{
			"value": GlobalOptions.show_fps,
			"description": "show fps count"
		},
		"use shader":{
			"value": GlobalOptions.use_shader,
			"description": "active shaders?"
		},
		"full screen":{
			"value": GlobalOptions.full_screen,
			"description": "window mode"
		}
	},
	"gameplay": {
		"ghost tapping":{
			"value": GlobalOptions.ghost_tapping, 
			"description": "disabled ghost tapping?"
		},
		"down scroll":{
			"value": GlobalOptions.down_scroll, 
			"description": "down scroll mode"
		},
		"middle scroll":{
			"value": GlobalOptions.middle_scroll, 
			"description": "middle scroll mode"
		},
		"pause music":{
			"value": GlobalOptions.pause_music, 
			"description": "choice the pause song"
		},
		"hatsune miku mode": { #man, I'm not going improve that, this is just a stupid joke
			"value": GlobalOptions.hatsune_miku_mode, 
			"description": "what have I done..."
		}
	},
	"offset menu": {}
}

func _ready() -> void:
	Discord.update_discord_info("options menu", "Is in menus")
	
	for i in options.keys():
		var alphabet = Alphabet.new();
		alphabet._creat_word(i);
		alphabet.position.y += offSetShit;
		options_stuff.add_child(alphabet);
		offSetShit += coolOffset;
		options_array.append(i)
		
	var reset_text = Alphabet.new();
	reset_text.position = Vector2(40, 685);
	reset_text.scale = Vector2(0.60, 0.65);
	reset_text._creat_word('Hold R to return to default settings');
	$reset.add_child(reset_text);
	
	change_option(0);
	
var cur_array_option = 0;
func _input(ev):
	if ev is InputEventKey:
		if ev.pressed && Global.can_use_menus:
			if is_on_settings_mode:
				if ev.keycode in [KEY_ESCAPE] && !ev.echo:
					if !is_on_key_mode:
						new_cur_option = 0;
						$settings/ColorRect.hide();
						is_on_settings_mode = false;
						is_on_key_mode = false;
						settings_stuff.hide();
						options_stuff.show();
						$reset.show();
						for i in settings.get_children():
							settings.remove_child(i);
							i.queue_free();
						$keys.hide();
						Global.updated_options = [];
						
					elif is_on_key_mode:
						is_on_key_mode = false;
						$keys.hide();
						
				if ev.keycode in [KEY_DOWN] && !ev.echo && !is_on_key_mode:
					change_new_option(1);
					
				if ev.keycode in [KEY_UP] && !ev.echo && !is_on_key_mode:
					change_new_option(-1);
					
				if Global.updated_options != [] && typeof(settings.get_child(new_cur_option).opt_type) == TYPE_INT:
					if ev.keycode in [KEY_RIGHT] && !is_on_key_mode:
						settings.get_child(new_cur_option).opt_type += 1;
						SoundStuff.playAudio("scrollMenu", false);
						settings.get_child(new_cur_option).update_text(str("<", int(settings.get_child(new_cur_option).opt_type), ">"), -80);
						GlobalOptions.get_setting(settings.get_child(new_cur_option).opt_name, settings.get_child(new_cur_option).opt_type);
						
					if ev.keycode in [KEY_LEFT] && !settings.get_child(new_cur_option).opt_type < 2 && !is_on_key_mode:
						settings.get_child(new_cur_option).opt_type -= 1;
						SoundStuff.playAudio("scrollMenu", false);
						settings.get_child(new_cur_option).update_text(str("<", int(settings.get_child(new_cur_option).opt_type), ">"), -80);
						GlobalOptions.get_setting(settings.get_child(new_cur_option).opt_name, settings.get_child(new_cur_option).opt_type);
						
				if Global.updated_options != [] && typeof(settings.get_child(new_cur_option).opt_type) == TYPE_FLOAT:
					if ev.keycode in [KEY_RIGHT] && !settings.get_child(new_cur_option).opt_type > 0.9 if settings.get_child(new_cur_option).opt_name.ends_with("alpha") else !settings.get_child(new_cur_option).opt_type > 9999.9 && !is_on_key_mode:
						settings.get_child(new_cur_option).opt_type += 0.1;
						SoundStuff.playAudio("scrollMenu", false);
						settings.get_child(new_cur_option).update_text(str("<", settings.get_child(new_cur_option).opt_type, ">"), -80);
						GlobalOptions.get_setting(settings.get_child(new_cur_option).opt_name, settings.get_child(new_cur_option).opt_type);
						
					if ev.keycode in [KEY_LEFT] && !settings.get_child(new_cur_option).opt_type < 0.1 && !is_on_key_mode:
						settings.get_child(new_cur_option).opt_type -= 0.1;
						SoundStuff.playAudio("scrollMenu", false);
						settings.get_child(new_cur_option).update_text(str("<", settings.get_child(new_cur_option).opt_type, ">"), -80);
						GlobalOptions.get_setting(settings.get_child(new_cur_option).opt_name, settings.get_child(new_cur_option).opt_type);
						
				if Global.updated_options != [] && typeof(settings.get_child(new_cur_option).opt_type) == TYPE_BOOL:
					if (ev.keycode in [KEY_ENTER] || ev.keycode in [KEY_KP_ENTER]) && !ev.echo && !is_on_key_mode:
						settings.get_child(new_cur_option).opt_type = !settings.get_child(new_cur_option).opt_type;
						settings.get_child(new_cur_option).update_bool_spr(settings.get_child(new_cur_option).opt_type)
						GlobalOptions.get_setting(settings.get_child(new_cur_option).opt_name, settings.get_child(new_cur_option).opt_type);
						
						if settings.get_child(new_cur_option).opt_name == "full screen":
							Global.update_windowMode(settings.get_child(new_cur_option).opt_type);
							
				if Global.updated_options != [] && typeof(settings.get_child(new_cur_option).opt_type) == TYPE_ARRAY:
					if ev.keycode in [KEY_RIGHT] && !is_on_key_mode:
						cur_array_option += 1
						
					if ev.keycode in [KEY_LEFT] && !is_on_key_mode:
						cur_array_option -= 1
						
					cur_array_option = wrapi(cur_array_option, 0, len(settings.get_child(new_cur_option).opt_type));
					GlobalOptions.current_array_opt = cur_array_option;
					settings.get_child(new_cur_option).update_text(str("<", settings.get_child(new_cur_option).opt_type[cur_array_option], ">"), -90);
					GlobalOptions.get_setting(settings.get_child(new_cur_option).opt_name, settings.get_child(new_cur_option).opt_type[cur_array_option]);
					
				if Global.updated_options != [] && typeof(settings.get_child(new_cur_option).opt_type) == TYPE_STRING:
					if (ev.keycode in [KEY_ENTER] || ev.keycode in [KEY_KP_ENTER]) && !ev.echo && !is_on_key_mode:
						if settings.get_child(new_cur_option).opt_name.ends_with("Key:"):
							is_on_key_mode = true;
							$keys/Label.text = "%s %s"%[settings.get_child(new_cur_option).opt_name, GlobalOptions.keys[new_cur_option][0]];
							$keys.show();
							
					if is_on_key_mode:
						if ev.pressed && !ev.echo:
							if InputMap.has_action("ui_%s"%[OS.get_keycode_string(ev.keycode).to_lower()]):
								InputMap.erase_action("ui_%s"%[OS.get_keycode_string(ev.keycode).to_lower()]);
								
							InputMap.add_action("ui_%s"%[OS.get_keycode_string(ev.keycode).to_lower()]);
							InputMap.action_add_event("ui_%s"%[OS.get_keycode_string(ev.keycode).to_lower()], ev);
							
							GlobalOptions.keys[new_cur_option][0] = OS.get_keycode_string(ev.keycode).to_lower();
							GlobalOptions.keys[new_cur_option][1] = ev.keycode;
							
							settings.get_child(new_cur_option).update_text(GlobalOptions.keys[new_cur_option][0]);
							$keys/Label.text = "%s %s"%[settings.get_child(new_cur_option).opt_name, GlobalOptions.keys[new_cur_option][0]]
							GlobalOptions.rebind_keys(new_cur_option, GlobalOptions.keys[new_cur_option][0], GlobalOptions.keys[new_cur_option][1])
			else:
				if ev.keycode in [KEY_DOWN] && !ev.echo:
					change_option(1);
					
				if ev.keycode in [KEY_UP] && !ev.echo:
					change_option(-1);
					
				if (ev.keycode in [KEY_ENTER] || ev.keycode in [KEY_KP_ENTER]) && !ev.echo:
					if options_array[cur_option] == "offset menu":
						Global.changeScene("/menus/editors/offset_editor/offset_menu", true, false);
					else:
						update_options();
						
				if ev.keycode in [KEY_ESCAPE] && !ev.echo:
					Global.changeScene("menus/main_menu/MainMenu", true, false);
					
				if ev.keycode in [KEY_R] && ev.echo:
					GlobalOptions.reset_settings();
					
func update_options():
	options = {
		"graphics": {
			"fps":{"value": int(GlobalOptions.fps), "description": "change FPS"},
			"vsync":{"value": GlobalOptions.vsync, "description": "enabled vsync"},
			"low quality":{"value": GlobalOptions.low_quality, "description": "it help... i gues.."}
		},
		"controls": {
			"Left Key:":{"value": GlobalOptions.keys[0][0], "description": "change left key"},
			"Down Key:":{"value": GlobalOptions.keys[1][0], "description": "change down key"},
			"Up Key:":{"value": GlobalOptions.keys[2][0], "description": "change up key"},
			"Right Key:":{"value": GlobalOptions.keys[3][0], "description": "change right key"}
		},
		"visual": {
			"hide hud":{"value": GlobalOptions.hide_hud, "description": "hide your hude"},
			"health bar alpha":{"value": GlobalOptions.health_bar_alpha, "description": "your health bar opacity"},
			"time bar alpha":{"value": GlobalOptions.time_bar_alpha, "description": "your time bar opacity"},
			"show FPS":{"value": GlobalOptions.show_fps, "description": "show fps count"},
			"use shader":{"value": GlobalOptions.use_shader, "description": "active shaders?"},
			"full screen":{"value": GlobalOptions.full_screen, "description": "window mode"}
		},
		"gameplay": {
			"ghost tapping":{"value": GlobalOptions.ghost_tapping, "description": "disabled ghost tapping?"},
			"down scroll":{"value": GlobalOptions.down_scroll, "description": "down scroll mode"},
			"middle scroll":{"value": GlobalOptions.middle_scroll, "description": "middle scroll mode"},
			"pause music":{"value": GlobalOptions.pause_music, "description": "choice the pause song"},
			"hatsune miku mode": {"value": GlobalOptions.hatsune_miku_mode, "description": "what have I done..."}
		},
		"offset menu": {}
	};
	
	for i in settings.get_children():
		i.new_options = [];
		settings.remove_child(i);
		i.queue_free();
		
	is_on_settings_mode = true;
	
	offSetShit = 0;
	coolOffset = 140;
	
	new_options_array = options[options_array[cur_option]].keys()
	
	settings_stuff.show();
	options_stuff.hide();
	$reset.hide();
	$settings/ColorRect.show();
	
	for i in new_options_array:
		var new_option = Option.new();
		new_option.opt_name = i;
		new_option.opt_type = options[options_array[cur_option]][i]["value"];
		new_option.option_new_x = 190;
		new_option.opt_id = len(i);
		new_option.position.y += offSetShit;
		new_option.new_options.append(new_option);
		settings.add_child(new_option);
		
		offSetShit += coolOffset;
		
	change_new_option(0);
	
func change_option(change):
	cur_option += change;
	SoundStuff.playAudio("scrollMenu", false);
	cur_option = wrapi(cur_option, 0, len(options));
	print(options_array[cur_option])
	
	for j in options.size():
		options_stuff.get_children()[j].modulate.a = 0.4
		if j == cur_option:
			options_stuff.get_children()[j].modulate.a = 1
			
	var tw = get_tree().create_tween();
	tw.tween_property(options_stuff, "position:y", 480-coolOffset*cur_option, 0.09).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
func change_new_option(change):
	new_cur_option += change;
	SoundStuff.playAudio("scrollMenu", false);
	new_cur_option = wrapi(new_cur_option, 0, len(new_options_array));
	
	description_text.text = options[options_array[cur_option]][new_options_array[new_cur_option]]["description"];
	
	for j in new_options_array.size():
		settings.get_children()[j].modulate.a = 0.4;
		if j == new_cur_option:
			settings.get_children()[j].modulate.a = 1;
			
	print(settings.get_child(new_cur_option).opt_name);
	
	var tw = get_tree().create_tween();
	tw.tween_property(settings, "position:y", 480-coolOffset*new_cur_option, 0.09).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
