extends Node2D

@onready var death_pos = $'death_position';

var bf = null;
var death_anim = null;

func _ready():
	if !GlobalOptions.hatsune_miku_mode:
		bf = load("res://source/characters/" + SongData.chartData["song"]["player1"] + ".tscn").instantiate();
		print(bf.death_scene);
		
		death_anim = load("res://source/%s.tscn"%[bf.death_scene]).instantiate();
		death_pos.add_child(death_anim);
