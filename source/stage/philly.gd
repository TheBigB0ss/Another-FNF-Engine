extends Node2D

var lights = [0, 1, 2, 3, 4];
var train_canMove = false;
var train_time = 0;
var randomLight = '';

@onready var lightsBg = $'lightBg';

func setRandomLight():
	randomLight = lights.pick_random();
	print(randomLight)
	lightsBg.texture = load("res://assets/stages/week3/win%s.png"%[randomLight])
	
func _ready():
	if soakedAppears() <= 4:
		$soaked.show();
	else:
		$soaked.hide();
		
func soakedAppears():
	return randi_range(0, 1000);
	
func _process(delta):
	if train_canMove:
		train_time += delta;
		if train_time >= 5.0:
			train_time = 0;
			train_canMove = false;
			update_train();
			
func trigger_train():
	SoundStuff.playAudio("train_passes", false);
	train_canMove = true;
	
func update_train():
	var tw = get_tree().create_tween();
	tw.tween_property($TrainBg, "position:x", -2450, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
	
	var gf_anim = get_tree().current_scene.get("gf");
	
	if gf_anim.animList.has("special idle dance") && SongData.chartData["song"]["player3"] != "none" && gf_anim != null && !GlobalOptions.hatsune_miku_mode:
		gf_anim._playAnim("special idle dance");
		
	if $TrainBg.position.x <= -2450:
		reset_train();
		
func reset_train():
	train_time = 0;
	train_canMove = false;
	$TrainBg.position = Vector2(4140, 610);
