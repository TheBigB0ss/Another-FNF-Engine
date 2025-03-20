extends CanvasLayer

@onready var the_box = $Box;
@onready var box_text = $Label;

var bf = null;
var opponent = null;

var dialogue_spr = "";
var box_pixel_part = "";
var is_pixel_box = true;

var dialogue_array = [];
var characters_array = [];
var cur_dialogue = 0;

var new_dialogue = false;

func _ready():
	if FileAccess.file_exists("res://assets/data/%s/%sDialogue.txt"%[SongData.chartData["song"]["song"].to_lower(), SongData.chartData["song"]["song"].to_lower()]):
		#get_tree().paused = true;
		box_text.visible_characters = 0;
		
		if SongData.chartData["song"]["song"].to_lower() == "senpai" or SongData.chartData["song"]["song"].to_lower() == "roses":
			MusicManager._play_music("Lunchbox", false, true);
			
		elif SongData.chartData["song"]["song"].to_lower() == "thorns":
			$hand.hide();
			$opponent.position = Vector2(220, 240)
			MusicManager._play_music("LunchboxScary", false, true);
			
		is_pixel_box = SongData.chartData["song"]["isPixelStage"];
		
		if is_pixel_box:
			bf = load("res://assets/images/portraits/bf/pixel bfPortrait.tscn").instantiate();
			if SongData.chartData["song"]["song"].to_lower() == "senpai" or SongData.chartData["song"]["song"].to_lower() == "roses":
				opponent = load("res://assets/images/portraits/senpai/senpaiPortrait.tscn").instantiate();
				
			elif SongData.chartData["song"]["song"].to_lower() == "thorns":
				opponent = load("res://assets/images/portraits/spirit/spirit.tscn").instantiate();
				opponent.is_trans = is_joke_dialogue;
				
			the_box.scale = Vector2(5.4, 5);
			the_box.texture_filter = AnimatedSprite2D.TEXTURE_FILTER_NEAREST;
			
			box_pixel_part = "pixel";
			if SongData.chartData["song"]["song"].to_lower() == "roses":
				dialogue_spr = "dialogueBox-senpaiMad";
			else:
				dialogue_spr = "dialogueBox pixel" if SongData.chartData["song"]["song"].to_lower() != "thorns" else "dialogueBox evil";
		else:
			$hand.hide();
			the_box.texture_filter = AnimatedSprite2D.TEXTURE_FILTER_NEAREST;
			box_pixel_part = "pixel";
			dialogue_spr = "dialogueBox evil";
			
		the_box.sprite_frames = load("res://assets/images/portraits/dialogue box/%s/%s.res"%[box_pixel_part, dialogue_spr])
		
		for i in getTxt().size():
			dialogue_array.append(getTxt()[i][1])
			characters_array.append(getTxt()[i][0])
			
		if SongData.chartData["song"]["song"].to_lower() == "senpai" && is_joke_dialogue:
			opponent = load("res://assets/images/portraits/funny/does bad things guy/does bad things guy.tscn").instantiate();
			bf = load("res://assets/images/portraits/funny/mario/mario.tscn").instantiate();
			
			$boyfriend.position = Vector2(1015, 330);
			$opponent.position = Vector2(285, 280);
			
		$boyfriend.add_child(bf);
		$opponent.add_child(opponent);
		
		update_text(dialogue_array[cur_dialogue], characters_array[cur_dialogue]);
		
var is_joke_dialogue = false;
func getTxt():
	var txtData = [];
	var txtTexts = [];
	var path_file = "res://assets/data/%s/%sDialogue.txt"%[SongData.chartData["song"]["song"].to_lower(), SongData.chartData["song"]["song"].to_lower()];
	if SongData.chartData["song"]["song"].to_lower() == "thorns" or SongData.chartData["song"]["song"].to_lower() == "roses" or SongData.chartData["song"]["song"].to_lower() == "senpai":
		if is_joke() <= 2:
			is_joke_dialogue = true;
			path_file =  "res://assets/data/%s/%sDialogue-joke.txt"%[SongData.chartData["song"]["song"].to_lower(), SongData.chartData["song"]["song"].to_lower()];
		else:
			is_joke_dialogue = false;
			
	var readTxt = FileAccess.open(path_file, FileAccess.READ);
	txtData = readTxt.get_as_text().split("\n");
	
	for i in txtData:
		var coolest_split = i.split("::");
		txtTexts.append(coolest_split);
		
	return txtTexts;
	
func is_joke():
	return randf_range(0, 3000);
	
func _process(delta):
	dialogue_timer += 1*delta;
	if dialogue_timer >= 0.05 && !Global.is_not_in_cutscene:
		if box_text.visible_characters <= len(box_text.text):
			box_text.visible_characters += 1;
			dialogue_timer = 0;
			SoundStuff.playAudio("pixelText", false)
			
		if box_text.visible_characters >= len(box_text.text):
			$hand.show();
		else:
			$hand.hide();
			
	if Input.is_action_just_pressed("ui_accept") && !Global.is_not_in_cutscene && box_text.visible_characters-1 < len(box_text.text):
		box_text.visible_characters = len(box_text.text);
		
	if Input.is_action_just_pressed("ui_accept") && !Global.is_not_in_cutscene && box_text.visible_characters-1 == len(box_text.text):
		cur_dialogue += 1;
		SoundStuff.playAudio("clickText", false);
		if !cur_dialogue > dialogue_array.size()-1:
			update_text(dialogue_array[cur_dialogue], characters_array[cur_dialogue]);
		else:
			start_song();
			
var dialogue_timer = 0;
var letter_count = 0;

func set_text(text):
	var new_text = "";
	for i in text:
		new_text += i;
		letter_count += 1;
		if letter_count % 48 == 0 && len(new_text) > 0:
			new_text += "\n";
			
	return new_text;
	
func update_text(text, char):
	box_text.text = "";
	letter_count = 0;
	
	if is_pixel_box:
		if SongData.chartData["song"]["song"] != "Roses":
			the_box.play("Text Box Appear instance 1" if SongData.chartData["song"]["song"] != "Thorns" else "Spirit Textbox spawn instance 1");
		else:
			the_box.play("SENPAI ANGRY IMPACT SPEECH instance 1");
			
		if char == "dad":
			if SongData.chartData["song"]["song"] != "Roses":
				if opponent is AnimatedSprite2D:
					opponent.play("Senpai Portrait Enter instance 1");
				$opponent.show();
				
			$boyfriend.hide();
			
		elif char == "bf":
			if bf is AnimatedSprite2D:
				bf.play("Boyfriend portrait enter instance 1");
				
			$boyfriend.show();
			$opponent.hide();
	else:
		the_box.play("Spirit Textbox spawn instance 1");
		
	box_text.text = set_text(text);
	box_text.visible_characters = 0;
	
func start_song():
	MusicManager._stop_music();
	Global.is_not_in_cutscene = true;
	Global.emit_signal("end_dialogue")
	get_tree().paused = false;
	self.hide();
	
func pause_song():
	self.show();
