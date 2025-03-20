extends Node2D

var notes = ["left", "down", "up", "right"];
var strumArray = [];
var offSetShit = 0;
var coolOffset = 105;
@export var note_type = "NOTE_assets";
@export var note_folder = "default";

var appearNOW = false;
var reset_arrow_anim = 0;

var second_opponent = false;

func _ready() -> void:
	for i in notes.size():
		var strumNote = null
		strumNote = load("res://source/arrows/note/note.tscn").instantiate();
		strumNote.modulate.a = 0.0;
		strumNote.position.x = offSetShit;
		if !SongData.chartData["song"]["isPixelStage"]:
			strumNote.note_skin = note_type;
			strumNote.note_type = note_folder;
			
		strumNote.noteData = i;
		add_child(strumNote);
		offSetShit += coolOffset;
		
		strumArray.append(strumNote.note);
		strumArray[i].play(notes[i]+" static");
		
func _process(delta):
	for i in 4:
		var notes = get_child(i);
		notesAppears(notes)
		anim_notes(notes)
		
	if reset_arrow_anim > 0 or reset_arrow_anim != 0:
		reset_arrow_anim -= 4*delta
		reset_arrow_anim = max(reset_arrow_anim, 0);
		
func anim_notes(ass_note):
	if reset_arrow_anim <= 0:
		ass_note.play_note_anim("static")
		
func notesAppears(note):
	var tw = get_tree().create_tween();
	if !appearNOW:
		for i in notes.size():
			tw.tween_property(note, "modulate:a", 1, 0.5+(0.2*i)).set_ease(Tween.EASE_IN_OUT)
	else:
		note.modulate.a = 1;
