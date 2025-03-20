extends CanvasLayer

var fade_timer = 0;
var white_fade_timer = 0;

@onready var senpai_timer = $"senpai fade timer";
@onready var senpai = $senpaiCrazy;

func _ready():
	MusicManager._play_music("LunchboxScary", false, true);
	Global.connect("end_senpai_cutscene", end_cutscene);
	
	if GlobalOptions.use_shader:
		$CanvasLayer.show();
	else:
		$CanvasLayer.hide();
		
func _process(delta):
	if fade_timer == 5:
		SoundStuff.playAudio("Senpai_Dies", false);
		senpai.animation.play("Senpai Pre Explosion instance 1/ ");
		
	white_fade_timer += 1*delta;
	
	if white_fade_timer >= 8.1:
		var tween = get_tree().create_tween();
		tween.tween_property($'white_bg', "modulate:a", 1, 0.5)
		
	if white_fade_timer >= 11.5 && white_fade_timer <= 11.6:
		Global.emit_signal("end_senpai_cutscene");
		
func end_cutscene():
	self.hide();
	
func _on_senpai_fade_timer_timeout() -> void:
	fade_timer += 1;
	if fade_timer <= 5:
		senpai_timer.start(0.6);
		
	match fade_timer:
		1:
			senpai.modulate.a = 0.4;
		2:
			senpai.modulate.a = 0.6;
		3:
			senpai.modulate.a = 0.8;
		4:
			senpai.modulate.a = 1;
