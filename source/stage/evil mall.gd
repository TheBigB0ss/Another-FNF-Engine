extends Node2D

var stage = 'EvilMall'

func _ready():
	if soakedAppears() <= 4:
		$soaked.show();
	else:
		$soaked.hide();
		
func soakedAppears():
	return randi_range(0, 1000);
