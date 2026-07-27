extends LineEdit

@onready var animations = $"../AnimationPlayer"

@export var min_value: int = Global.min_range
@export var max_value: int = Global.max_range

@export var custom_caret_height: float = 50.0
@export var custom_caret_width: float = 3.0
@export var caret_color: Color = Color.BLACK

func _ready():
	min_value = Global.min_range
	max_value = Global.max_range
	
	grab_focus()
	# hide numbers by default
	secret = true

	set_caret_blink_enabled(false)
	add_theme_color_override("caret_color", Color(0,0,0,0)) # hide the ugly default caret
	
	self.max_length = Global.line_edit_max_lenght

func _process(_delta):
	# sync secret mode with global toggle
	secret = !Global.show_numbers
	
	queue_redraw()
	if not has_focus():
		grab_focus()

	caret_color = Global.caret_color

func _on_text_submitted(new_text):
	if new_text.is_valid_int():
		var val = int(new_text)
		if val >= min_value and val <= max_value:
			var parent = get_parent()
			parent.add_guess(val)
			clear()

			# move to next player if we aren't at the limit
			if parent.guesses.size() < parent.number_of_players:
				animations.play("next_player")
				SoundManager.play_sfx(SoundsList.ui_number_submitted, -22, 1.4)
		else:
			# show range error
			animations.play("error")
			SoundManager.play_sfx(SoundsList.ui_error, -16, 1.9)
			get_parent().shake_screen(8.0, 0.2)
			get_parent().update_status("Number must be " + str(min_value) + "-" + str(max_value) + "!")
	else:
		# not a number
		animations.play("error")
		SoundManager.play_sfx(SoundsList.ui_error, -16, 1.9)
		get_parent().shake_screen(8.0, 0.2)
		get_parent().update_status("Only numbers!")

func _on_text_changed(new_text: String) -> void:
	pass

func _draw():
	if has_focus():
		var font = get_theme_font("font")
		var font_size = get_theme_font_size("font_size")

		var bullet_char: String
		var carret_v_offset: int
		
		# adjust caret height so it doesnt look weird when switching modes
		if Global.show_numbers == true:
			bullet_char = "8"
			custom_caret_height = 54.0
			carret_v_offset = -4
		else:
			bullet_char = "•"
			custom_caret_height = 50.0
			carret_v_offset = 0
			
		var bullet_w = font.get_string_size(bullet_char, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var text_offset = bullet_w * caret_column

		# handle center alignment math
		var start_x = 0
		var total_text_w = bullet_w * text.length()

		if alignment == HORIZONTAL_ALIGNMENT_CENTER:
			start_x = (size.x / 2.0) - (total_text_w / 2.0)
		elif alignment == HORIZONTAL_ALIGNMENT_RIGHT:
			start_x = size.x - total_text_w

		# manual blink calc
		var y_pos = (size.y - custom_caret_height) / 2 + carret_v_offset
		var blink_alpha = 1.0 if (Time.get_ticks_msec() % 1300 < 650) else 0.0
		var final_color = caret_color
		final_color.a = blink_alpha

		# +2 offset so it isn't touching the text
		draw_rect(Rect2(start_x + text_offset + 2, y_pos, custom_caret_width, custom_caret_height), final_color)
