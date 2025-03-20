extends Node2D

var notes = ["left", "down", "up", "right"];
var strumArray = [];
var offSetShit = 0;
var coolOffset = 105;
@export var note_type = "NOTE_assets";
@export var note_folder = "default";

var appearNOW = false;
var reset_arrow_anim = 0;

func _ready() -> void:
	for i in notes.size():
		var strumNote = null
		strumNote = load("res://source/arrows/note/note.tscn").instantiate();
		strumNote.modulate.a = 0.0;
		strumNote.position.x = offSetShit;
		if !SongData.chartData["song"]["isPixelStage"]:
			strumNote.note_skin = note_type;
			strumNote.note_type = note_folder;
			
		strumNote.noteData = i
		add_child(strumNote);
		offSetShit += coolOffset;
		
		strumArray.append(strumNote.note);
		strumArray[i].play(notes[i]+" static")
		
func _process(delta):
	for i in 4:
		var note = get_child(i)
		var key = "ui_%s"%GlobalOptions.keys[i][0];
		input_Arrow(key, note)
		notesAppears(note)
		
	if reset_arrow_anim > 0 or reset_arrow_anim != 0 && Global.is_a_bot:
		reset_arrow_anim -= 4*delta
		reset_arrow_anim = max(reset_arrow_anim, 0);
		
var new_key = InputEventKey.new();
func notesAppears(note):
	var tw = get_tree().create_tween();
	if !appearNOW:
		for i in notes.size():
			tw.tween_property(note, "modulate:a", 1, 0.5+(0.2*i)).set_ease(Tween.EASE_IN_OUT)
	else:
		note.modulate.a = 1;
		
var singAnims = ["singLeft", "singDown", "singUp", "singRight"];
func input_Arrow(key_to_press, ass_note):
	if Input.is_action_just_pressed(key_to_press) && !Global.is_a_bot && Global.is_not_in_cutscene:
		if !Global.pressed_note:
			ass_note.play_note_anim("press");
			
			if !GlobalOptions.ghost_tapping:
				var miss_anim = get_tree().current_scene.get("bf");
				var coolAnims = singAnims[int(ass_note.noteData)%4];
				
				miss_anim._playAnim(coolAnims+" MISS");
				GlobalOptions.emit_signal("ghost_tapping_miss");
				
	if !Input.is_action_pressed(key_to_press) && !Global.is_a_bot:
		ass_note.play_note_anim("static")
		
	if Global.is_a_bot && reset_arrow_anim <= 0:
		ass_note.play_note_anim("static")
