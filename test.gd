extends Node2D

var number: int = 0

func _process(delta: float) -> void:
	pass

func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text.is_valid_int() and int(new_text) >= 1 and int(new_text) <= 1000000:
		number = int(new_text)
		print(number)
	elif not new_text.is_valid_int():
		print("not an int")
	elif int(new_text) < 1:
		print("it needs to be between 1 and 1 000 000")
	elif int(new_text) > 1000000:
		print("it needs to be between 1 and 1 000 000")
