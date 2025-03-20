extends Node2D

var stage = 'Spooky Mansion';
@onready var lightningBgAnim = $'spooky Bg';
var isAThunder = false;

func _ready():
	lightningBgAnim.play("halloweem bg");
	if soakedAppears() <= 4:
		$soaked.show();
	else:
		$soaked.hide();
		
func lightning():
	lightningBgAnim.play("halloweem bg lightning strike");
	Flash.flashAppears(0.3);
	SoundStuff.playAudio("thunder_1", false);
	
func soakedAppears():
	return randi_range(0, 1000);
	
func _on_spooky_bg_animation_finished() -> void:
	lightningBgAnim.play("halloweem bg");
