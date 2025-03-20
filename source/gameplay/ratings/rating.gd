extends Sprite2D

var ratings = ["sick", "good", "bad", "shit", "miss"];
var ratingPart = "";

var velocity = Vector2();
var vspeed = 0
var grav = 0.30

func _ready() -> void:
	if SongData.chartData["song"]["isPixelStage"]:
		self.scale = Vector2(3.5,3.5);
		ratingPart = "-pixel";
	else:
		ratingPart = "";
		
	hide();
	
func _process(delta: float) -> void:
	modulate.a = lerp(modulate.a, 0.0, 0.21);
	position.y += vspeed;
	
	vspeed += grav
	
func pop_up_rating(rating):
	position = Vector2(535, 245);
	
	vspeed = -4;
	
	texture = load("res://assets/images/hud/rating/%s.png"%[ratings[rating] + ratingPart]);
	modulate.a = 20.0;
	show();
