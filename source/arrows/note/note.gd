extends Node2D

@onready var note = $'Note'
@onready var note_line = $"noteLine"
@onready var note_end = $"noteLine/noteEnd"

var note_dir = "left"
var custom_note_dir = KEY_LEFT;

var type = "note";
var noteAnim = "purple";
var note_type = 'default';
var note_skin = "NOTE_assets";

var isGfNote = false;
var isPlayer = false;
var is_altAnim = false;

var must_press = false;
var is_pressing = false;
var can_press = false;

var miss_health = 0.0;
var songPos = 0;
var noteData = 0;
var isSustain = false;
var sustainLenght = 0.0;
var no_anim = false;
var is_hey_note = false;
var note_pressed = false;

var emit_longNote = false;
var emit_miss = false;

var is_a_bad_note = false;

var ms = 0.0;

var missed = false;

func reload_note_type():
	match type:
		"Hurt Note":
			is_a_bad_note = true;
			miss_health = 5;
			note.sprite_frames = load("res://assets/images/arrows/hurt note/HURTNOTE.res" if !SongData.chartData["song"]["isPixelStage"] else "res://assets/images/arrows/pixel/hurt note/pixel_hurtNotes.tres");
			if sustainLenght > 0.0:
				var new_texture = note.sprite_frames.get_frame_texture("%s hold piece"%[noteAnim], 0)
				var image = new_texture.get_image()
				image.rotate_90(CLOCKWISE)
				
				note_line.texture = ImageTexture.create_from_image(image) if !SongData.chartData["song"]["isPixelStage"] else load("res://assets/images/arrows/pixel/hurt note/pieces/hold.png");
				note_end.texture = note.sprite_frames.get_frame_texture("%s hold end"%[noteAnim], 0) if !SongData.chartData["song"]["isPixelStage"] else load("res://assets/images/arrows/pixel/hurt note/pieces/end.png");
				
		"Kill Note":
			is_a_bad_note = true;
			miss_health = 100;
			note.sprite_frames = load("res://assets/images/arrows/kill note/kill_note.res");
			if sustainLenght > 0.0:
				note_line.texture = load("res://assets/images/arrows/kill note/pieces/killNOTEpiece.png");
				note_end.texture = load("res://assets/images/arrows/kill note/pieces/killEnd.png");
				
		"Second opponent":
			note.scale = Vector2(0.5, 0.5);
			note_line.scale = Vector2(0.5, 0.5);
			note_end.scale = Vector2(0.5, 0.5);
			
func _ready():
	note.sprite_frames = load("res://assets/images/arrows/%s/%s.res"%[note_type, note_skin]);
	match noteData:
		0, 4:
			note_dir = "left";
			noteAnim = "purple";
			custom_note_dir = GlobalOptions.keys[0][0];
		1, 5:
			note_dir = "down";
			noteAnim = "blue";
			custom_note_dir = GlobalOptions.keys[1][0];
		2, 6:
			note_dir = "up";
			noteAnim = "green";
			custom_note_dir = GlobalOptions.keys[2][0];
		3, 7:
			note_dir = "right";
			noteAnim = "red";
			custom_note_dir = GlobalOptions.keys[3][0];
			
	if sustainLenght > 0.0:
		var new_texture = note.sprite_frames.get_frame_texture("%s hold piece"%[noteAnim], 0)
		var image = new_texture.get_image()
		image.rotate_90(CLOCKWISE)
		
		note_line.texture = ImageTexture.create_from_image(image) if note.sprite_frames.has_animation("%s hold piece"%[noteAnim]) else load("res://assets/images/arrows/%s/pieces/%s hold piece.png"%[note_type, noteAnim]);
		note_end.texture = note.sprite_frames.get_frame_texture("%s hold end"%[noteAnim], 0) if note.sprite_frames.has_animation("%s hold end"%[noteAnim]) else load("res://assets/images/arrows/%s/pieces/%s hold end.png"%[note_type, noteAnim]);
		
		if type == "note" or type == "":
			if noteAnim == "green":
				note_line.position.x += 2.5;
				#note_end.position.x += 2.5;
				
	note_line.modulate.a = 0.5;
	note_end.modulate.a = 0.9;
	
	if SongData.chartData["song"]["isPixelStage"]:
		note.texture_filter = AnimatedSprite2D.TEXTURE_FILTER_NEAREST;
		note_line.texture_filter = Line2D.TEXTURE_FILTER_NEAREST;
		note_end.texture_filter = Sprite2D.TEXTURE_FILTER_NEAREST;
		
		note.sprite_frames = load("res://assets/images/arrows/pixel/%s/%s.tres"%[note_type, note_skin]);
		note.scale = Vector2(9,9);
		if sustainLenght > 0.0:
			note_line.texture = load("res://assets/images/arrows/pixel/%s/pieces/%s hold piece.png"%[note_type, noteAnim]);
			note_end.texture = load("res://assets/images/arrows/pixel/%s/pieces/%s hold end.png"%[note_type, noteAnim]);
			note_end.scale = Vector2(7,7);
			note_line.modulate.a = 1;
			note_end.modulate.a = 1;
			
	reload_note_type();
	note.play(noteAnim);
	
	note_line.texture_mode = Line2D.LINE_TEXTURE_STRETCH;
	
func _process(delta):
	if sustainLenght > 0.0 or sustainLenght != 0:
		isSustain = true;
		if note_line != null:
			if note_line.points.size() == 0:
				note_line.add_point(Vector2(0, 0));
				note_line.add_point(Vector2(0, sustainLenght));
			else:
				note_line.set_point_position(1, Vector2(0, sustainLenght));
				
			note_line.scale.y = Conductor.songSpeed/1.5 if !GlobalOptions.down_scroll else -Conductor.songSpeed/1.5;
			
		if note_end != null:
			note_end.position.y = sustainLenght + note_end.get_rect().size.y/Conductor.songSpeed if !SongData.chartData["song"]["isPixelStage"] else sustainLenght + note_end.get_rect().size.y/Conductor.songSpeed-1.8;
			if !SongData.chartData["song"]["isPixelStage"]:
				note_end.scale.y = 2.5/Conductor.songSpeed;
	else:
		isSustain = false;
		
	if is_pressing:
		sustainLenght -= (delta*1000);
		if sustainLenght < 23:
			sustainLenght = 0;
		sustainLenght = max(sustainLenght, 0);
		
		if sustainLenght <= 0 && note_line != null && note_end != null:
			note_line.hide();
			note_end.hide();
			note_line.queue_free();
			note_end.queue_free();
			
		if note_line != null:
			note_line.set_point_position(1, Vector2(0, sustainLenght));
			note_end.position.y = sustainLenght + note_end.get_rect().size.y/Conductor.songSpeed
			
		if GlobalOptions.hatsune_miku_mode:
			SoundStuff.playAudio("bop", false)
			
	if Conductor.getSongTime > 390 + songPos && sustainLenght > 0 && !is_pressing:
		sustainLenght -= (delta*1000);
		sustainLenght = max(sustainLenght, 0);
		
		if sustainLenght <= 0 && note_line != null && note_end != null:
			note_line.hide();
			note_end.hide();
			note_line.queue_free();
			note_end.queue_free();
			
		if note_line != null:
			note_line.set_point_position(1, Vector2(0, sustainLenght));
			note_end.position.y = sustainLenght + note_end.get_rect().size.y/Conductor.songSpeed
			
func pressed():
	if sustainLenght <= 0:
		Global.emit_signal("notePressed");
		self.queue_free();
		
	elif sustainLenght > 0 && !emit_longNote:
		emit_longNote = true;
		Global.emit_signal("longNotePressed");
		
func opponent_pressed():
	self.queue_free();
	
func miss_note():
	self.modulate.a = 0.3;
	if !emit_miss:
		Global.emit_signal("noteMissed");
		emit_miss = true;
		
func play_note_anim(anim):
	note.play(str(note_dir, " ", anim));
