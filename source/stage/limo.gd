extends Node2D

var stage = 'Limo';

@onready var dancer1 = $'Control/Dancer1';
@onready var dancer2 = $'Control/Dancer2';
@onready var dancer3 = $'Control/Dancer3';
@onready var dancer4 = $'Control/Dancer4';

@onready var dancers = $'Control';

@onready var limo = $'Limo';
@onready var backLimo = $'LimoBg';

@onready var coolCar = $'car';

func _ready():
	dancer1.play("bg dancer sketch PINK");
	dancer2.play("bg dancer sketch PINK");
	dancer3.play("bg dancer sketch PINK");
	dancer4.play("bg dancer sketch PINK");
	
	for i in dancers.get_children():
		i.play("bg dancer sketch PINK")
		
	limo.play('Limo stage');
	backLimo.play("background limo pink");
	
	if soakedAppears() <= 4:
		$soaked.show();
	else:
		$soaked.hide();
		
	if GlobalOptions.low_quality:
		$Control.hide();
		$LimoBg.hide();
		
func soakedAppears():
	return randi_range(0, 1000);
	
func fastCarZOOOOOOOOOOOOOOOOOOMMMMMMMMMMM():
	coolCar.x -= 4000;
	
func restFastCar():
	coolCar.x += 4000
