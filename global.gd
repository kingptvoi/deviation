extends Node

var line_edit_max_lenght: int

var min_range: int = 1
var max_range: int = 100

var caret_color: Color

var number_of_players: int

var sounds_on: bool
var show_numbers: bool

func _ready() -> void:
	line_edit_max_lenght = 3
	sounds_on = true
	show_numbers = true
	caret_color = Color.CRIMSON
	number_of_players = 4

func _process(delta: float) -> void:
	number_of_players = clamp(number_of_players, 3, 10)
	check_max_lenght()

func check_max_lenght():
	# get string length of both line edits from the mainn menu
	var len_min = str(min_range).length()
	var len_max = str(max_range).length()
	
	# use whichever one is bigger so the input doesnt cut off
	line_edit_max_lenght = max(len_min, len_max)
