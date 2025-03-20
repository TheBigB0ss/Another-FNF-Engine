class_name Alphabet extends AnimatedSprite2D

var wordArray = [];
var coolText = "";
var letterAnim = [];
var isBold = true;

var global_anim = AnimatedSprite2D.new();

func _creat_word(text = ""):
	coolText = text
	if text != "":
		coolText = text.to_upper()
		_clear_word();
		do_a_word();
		
func do_a_word():
	wordArray = coolText.split("");
	for i in wordArray:
		#I hate you Phantom Arcade
		match i:
			"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z":
				if isBold:
					i += " bold";
				else:
					i += " capital"
			"(":
				if isBold:
					i = "bold ("
				else:
					i = "("
			")":
				if isBold:
					i = "bold )"
				else:
					i = ")"
			"*":
				if isBold:
					i = "bold *"
				else:
					i = "*"
			"+":
				if isBold:
					i = "bold +"
				else:
					i = "+"
			"-":
				if isBold:
					i = "bold -"
				else:
					i = "-"
			">":
				if isBold:
					i = "bold >"
				else:
					i = ">"
			"<":
				if isBold:
					i = "bold <"
				else:
					i = "<"
			"\'":
				if isBold:
					i = "APOSTRAPHIE bold"
				else:
					i = "apostraphie"
			"?":
				if isBold:
					i = "QUESTION MARK bold"
				else:
					i = "question mark"
			"!":
				if isBold:
					i = "EXCLAMATION POINT bold"
				else:
					i = "exclamation point"
			"&":
				if isBold:
					i = "bold &"
				else:
					i = "amp"
			"$":
				i = "dollarsign"
			"/":
				i = "forward slash"
			"#":
				i = "hashtag"
			".":
				if isBold:
					i = "PERIOD bold"
				else:
					i = "period"
			"0":
				if isBold:
					i = "bold0"
				else:
					i = "0"
			"1":
				if isBold:
					i = "bold1"
				else:
					i = "1"
			"2":
				if isBold:
					i = "bold2"
				else:
					i = "2"
			"3":
				if isBold:
					i = "bold3"
				else:
					i = "3"
			"4":
				if isBold:
					i = "bold4"
				else:
					i = "4"
			"5":
				if isBold:
					i = "bold5"
				else:
					i = "5"
			"6":
				if isBold:
					i = "bold6"
				else:
					i = "6"
			"7":
				if isBold:
					i = "bold7"
				else:
					i = "7"
			"8":
				if isBold:
					i = "bold8"
				else:
					i = "8"
			"9":
				if isBold:
					i = "bold9"
				else:
					i = "9"
			":":
				if isBold:
					i = ":"
				else:
					i = ":"
			";":
				if isBold:
					i = ";"
				else:
					i = ";"
			"%":
				if isBold:
					i = "%"
				else:
					i = "%"
			"=":
				if isBold:
					i = "="
				else:
					i = "="
			"@":
				if isBold:
					i = "@"
				else:
					i = "@"
			"[":
				if isBold:
					i = "["
				else:
					i = "["
			"]":
				if isBold:
					i = "]"
				else:
					i = "]"
			"_":
				if isBold:
					i = "_"
				else:
					i = "_"
			"|":
				if isBold:
					i = "|"
				else:
					i = "|"
					
		if i == " ":
			i = "none"
			
		letterAnim.append(i)
		
	_create_a_letter(letterAnim)
	
func _create_a_letter(letter):
	var offSetShit = 0;
	var coolOffset = 55;
	for i in letter.size():
		var new_word = AnimatedSprite2D.new();
		new_word.sprite_frames = load("res://assets/images/alphabet/alphabet.res");
		new_word.position.x = offSetShit;
		new_word.play(letter[i]);
		add_child(new_word)
		
		global_anim.sprite_frames = new_word.sprite_frames;
		global_anim.position.x = offSetShit;
		global_anim.play(letter[i]);
		
		offSetShit += coolOffset;
		
func _clear_word():
	letterAnim = []
	for i in get_children():
		remove_child(i)
		i.queue_free();
