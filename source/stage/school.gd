extends Node2D

func _ready():
	if soakedAppears() <= 4:
		$soaked.show();
	else:
		$soaked.hide();
		
	if GlobalOptions.use_shader:
		$CanvasLayer.show();
	else:
		$CanvasLayer.hide();
		
func soakedAppears():
	return randi_range(0, 1000);
