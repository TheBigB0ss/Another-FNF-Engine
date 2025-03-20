class_name CharacterData extends Node2D

var charData:Dictionary = {
	"Poses": [
		{
			"Name": "",
			"Anim": "",
			"Offset": [0, 0]
		}
	],
	"HealthBarColor": "",
	"HealthIcon": "",
	"FlipX": false,
	"FlipY": false,
	"isPlayer": false
}

var charPath = '';
var animList = [];
var posesList = [];
var icon = '';

var healthColor = Color();

func _ready():
	if charPath == '':
		charPath = 'Bf';
