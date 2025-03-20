extends Node2D

var GRID_SIZE = 40
var grid_Y_size = 40

var keyAmount:int = 5
var tileSize:int = 32

func _redraw_grid(new_size = 40):
	GRID_SIZE = new_size
	queue_redraw()
	
func _draw():
	for i in grid_Y_size:
		for j in 8:
			draw_rect(Rect2(j * 40, i * 40, 40, 40), Color.GRAY)
			if (i + j) % 2 == 0:
				draw_rect(Rect2(j * 40, i * 40, 40, 40), Color.WHITE_SMOKE)
				
	draw_line(Vector2(tileSize*keyAmount*2 / 2, 0), Vector2(tileSize*keyAmount*2 / 2, tileSize*40), Color.BLACK, 3)
