extends Node

var updated_chart = null;
var chartData:Dictionary = {
	"song":{
		"player1": "",
		"player2": "",
		"notes": [
			{
				"lengthInSteps": 16,
				"sectionNotes": [
					[
						0.0,
						0,
						0.0,
						""
					]
				],
				"typeOfSection": 0,
				"altAnim": false,
				"gfSection": false,
				"bpm": 100,
				"changeBPM": false,
				"mustHitSection": true
			}
		],
		"player3": "",
		"song": "",
		"stage": "",
		"needsVoices": true,
		"validScore": true,
		"speed": 1,
		"bpm": 100,
		"isPixelStage": false,
		"two opponents": false,
		"player4": ""
	}
};

var stageData:Dictionary = {
	"opponent": [],
	"gf": [],
	"bf": []
};

func loadStageJson(stage):
	var jsonFile = FileAccess.open("res://assets/stages/data/%s.json"%[stage], FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	stageData = jsonData.get_data();
	jsonFile.close();
	
func loadJson(song, difficulty = "", new_chart = null):
	var new_chart_data = new_chart;
	var difficultyPath = "";
	if difficulty == "" or difficulty == "normal":
		difficultyPath = "res://assets/data/%s/%s.json"%[song, song];
	else:
		difficultyPath = "res://assets/data/%s/%s-%s.json"%[song, song, difficulty];
		
	var jsonFile = FileAccess.open(difficultyPath, FileAccess.READ);
	var jsonData = JSON.new();
	jsonData.parse(jsonFile.get_as_text());
	jsonFile.close();
	
	if new_chart_data != null:
		chartData = new_chart;
		
	elif new_chart_data == null:
		chartData = jsonData.get_data();
		
	if !chartData["song"].has("speed"):
		chartData["song"]["speed"] = 1;
		
	if !chartData["song"].has("bpm"):
		chartData["song"]["bpm"] = 100;
		
	if !chartData["song"].has("two opponents"):
		chartData["song"]["two opponents"] = false;
		
	if !chartData["song"].has("player4"):
		chartData["song"]["player4"] = "";
		
	if !chartData["song"].has("stage"):
		chartData["song"]["stage"] = "stage";
		
	if !chartData["song"].has("song"):
		chartData["song"]["song"] = "bopeebo";
		
	if !chartData["song"].has("isPixelStage"):
		chartData["song"]["isPixelStage"] = false;
		
	for i in chartData["song"]["notes"]:
		if !i.has("gfSection"): 
			i["gfSection"] = false;
			
		if !i.has("altAnim"): 
			i["altAnim"] = false;
			
		if !i.has("changeBPM"): 
			i["changeBPM"] = false;
			
		if !i.has("bpm"): 
			i["bpm"] = 100;
			
	for i in chartData["song"]["notes"].size():
		for j in chartData["song"]["notes"][i]["sectionNotes"].size():
			if chartData["song"]["notes"][i]["sectionNotes"][j].size() < 4:
				chartData["song"]["notes"][i]["sectionNotes"][j].append("")
