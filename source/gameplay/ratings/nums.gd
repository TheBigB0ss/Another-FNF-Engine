extends Sprite2D

var ratingPart = "";
var numScore = [];

var vspeed = 0;
var grav = 0.30;

func _ready() -> void:
	vspeed = -0.4;
	if SongData.chartData["song"]["isPixelStage"]:
		self.scale = Vector2(4.3,4.3);
		ratingPart = "-pixel";
	else:
		ratingPart = "";
		
	for i in 10:
		numScore.append(load("res://assets/images/hud/rating/nums/num%s%s.png"%[i, ratingPart]))
	hide();
	
func _process(delta: float) -> void:
	modulate.a = lerp(modulate.a, 0.0, 0.21);
	position.y += vspeed;
	
	vspeed += grav
	
func pop_up_rating():
	position = Vector2(410, 310);
	
	vspeed = -4;
	
	modulate.a = 20.0;
	queue_redraw();
	show();
	
func _draw() -> void:
	var combo = str(Global.globalCombo);
	for i in range(len(combo)):
		if SongData.chartData["song"]["isPixelStage"]:
			draw_texture(numScore[int(combo[i])], Vector2(i*10, 0));
		else:
			draw_texture(numScore[int(combo[i])], Vector2(i*90, 0));
