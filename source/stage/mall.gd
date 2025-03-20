extends Node2D

var stage = 'Mall'

func _ready():
	if soakedAppears() <= 4:
		$soaked.show();
	else:
		$soaked.hide();
		
	if GlobalOptions.low_quality:
		$upperBop.hide();
		$bottomBop.hide();
		
func soakedAppears():
	return randi_range(0, 1000);
