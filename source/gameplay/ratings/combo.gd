extends Sprite2D

var ratingPart = "";

var vspeed = 0;
var grav = 0.30;

func _ready() -> void:
	vspeed = -0.4;
	if SongData.chartData["song"]["isPixelStage"]:
		self.scale = Vector2(3.5,3.5);
		ratingPart = "-pixel"
	else:
		ratingPart = ""
	texture = load("res://assets/images/hud/rating/combo%s.png"%[ratingPart])
	hide();
	
func _process(delta: float) -> void:
	modulate.a = lerp(modulate.a, 0.0, 0.21);
	position.y += vspeed;
	
	vspeed += grav
	
func pop_up_rating():
	position = Vector2(595, 295)
	
	vspeed = -4;
	
	texture = load("res://assets/images/hud/rating/combo%s.png"%[ratingPart])
	modulate.a = 20.0;
	queue_redraw();
	show();
