extends Control

const message_pos_start_x = 550
const message_pos_start_y = 874
const message_pos_end_x = 550
const message_pos_end_y = 610

var guesses = []

# readable colors for light mode
var player_colors_d = [
	Color.CRIMSON,
	Color.ROYAL_BLUE,
	Color.DARK_GREEN,
	Color.DARK_ORCHID,
	Color("#E67E22"),
	Color.TEAL,
	Color("#8B4513"),
	Color("#C71585"),
	Color("#2F4F4F"),
	Color("#191970")
]

var current_color_index = 0

var zoom_tween: Tween

@onready var background_grid = $ColorRect2

@onready var background_shader = background_grid.material as ShaderMaterial

@onready var label = $message
@onready var player = $player
@onready var line_edit = $LineEdit
@onready var animations = $AnimationPlayer

@onready var show_results_section = $show_results

@onready var results_label = $CenterContainer/VBoxContainer/results
@onready var average_label = $CenterContainer/VBoxContainer/average
@onready var result_graph = $CenterContainer/VBoxContainer/graph
@onready var winner_label = $CenterContainer/VBoxContainer/winner
@onready var restart_label = $CenterContainer/VBoxContainer/restart
@onready var menu_button = $CenterContainer/VBoxContainer/menu_button

@onready var sfx = $AudioStreamPlayer2D

var number_of_players: int

@onready var line_edit_style = line_edit.get_theme_stylebox("focus").duplicate()

func _ready() -> void:
	
	background_shader = background_grid.material as ShaderMaterial
	
	$show_results/show_results_button.add_theme_constant_override("outline_size", 0)
	reset_game()

# color sync for labels and inputs
func apply_theme_color(index: int):
	var safe_index = index % player_colors_d.size()
	var new_color = player_colors_d[safe_index]

	player.add_theme_color_override("font_color", new_color)
	label.add_theme_color_override("font_color", new_color)

	line_edit.add_theme_color_override("font_color", new_color)
	line_edit_style.border_color = new_color
	line_edit.add_theme_stylebox_override("focus", line_edit_style)

	if "caret_color" in Global:
		Global.caret_color = new_color

func update_status(text_msg):
	label.text = text_msg

func add_guess(num):
	guesses.append(num)

	if guesses.size() >= number_of_players:
		SoundManager.play_sfx(SoundsList.ui_number_submitted, -22, 1.4)
		$show_results_anim.play("last_player")
		show_results_section.visible = true
		label.visible = false
		player.visible = false
		line_edit.visible = false
		line_edit.editable = false
		#show_results()
	else:
		current_color_index = guesses.size()
		player.text = "Player " + str(current_color_index + 1) + "'s turn:"
		label.text = ("Choose a number between " + str(Global.min_range) + " and " + str(Global.max_range))
		apply_theme_color(current_color_index)

func show_results():
	
	#results_zoom(70, 1.0)
	
	animations.play("final_player")
	
	SoundManager.play_sfx(SoundsList.ui_results_reveal, -20, 1.3)

	label.visible = false
	player.visible = false
	line_edit.visible = false
	line_edit.editable = false
	menu_button.visible = true

	# calc average
	var total = 0.0
	for g in guesses:
		total += g
	var average = total / guesses.size()

	# find winner (closest to average)
	var closest_diff = Global.max_range + 1
	for g in guesses:
		var diff = abs(g - average)
		if diff < closest_diff:
			closest_diff = diff

	# check for ties
	var winner_indices = []
	for i in range(guesses.size()):
		var diff = abs(guesses[i] - average)
		if is_equal_approx(diff, closest_diff): 
			winner_indices.append(i)

	results_label.text = "RESULTS:\n\n"
	average_label.text = ""
	animate_average_reveal(average)
	
	result_graph.setup(guesses, average, player_colors_d)
	result_graph.visible = true

	var bb_text = ""

	# handle tie-breaker text vs single winner
	if winner_indices.size() > 1:
		bb_text = "TIE! Players: "
		var guesses_string = ""
		
		for i in range(winner_indices.size()):
			var win_idx = winner_indices[i]
			var p_color = player_colors_d[win_idx % player_colors_d.size()]
			var color_hex = p_color.to_html(false)

			bb_text += "[color=#" + color_hex + "]" + str(win_idx + 1) + "[/color]"
			guesses_string += str(guesses[win_idx])

			if i < winner_indices.size() - 1:
				bb_text += ", "
				guesses_string += ", "
		
		bb_text += " (" + guesses_string + ")"
	else:
		var win_idx = winner_indices[0]
		var p_color = player_colors_d[win_idx % player_colors_d.size()]
		var color_hex = p_color.to_html(false)

		bb_text = "Winner: [color=#" + color_hex + "]Player " + str(win_idx + 1) + "[/color]"
		bb_text += " (" + str(guesses[win_idx]) + ")"

	winner_label.text = bb_text
	restart_label.text = "\nPress 'Enter' to restart"
	set_process_input(true)

func reset_game():
	
	background_shader.set_shader_parameter("grid_size", 50)
	
	show_results_section.visible = false
	$show_results/show_results_button.add_theme_font_size_override("font_size", 64)
	
	SoundManager.play_sfx(SoundsList.ui_round_start, -16, 1.4)
	animations.play("next_player")

	guesses.clear()
	current_color_index = 0

	line_edit.editable = true
	line_edit.visible = true
	line_edit.clear()
	label.visible = true
	player.visible = true
	
	set_process_input(false)

	player.text = "Player 1's turn:"
	label.text = ("Choose a number between " + str(Global.min_range) + " and " + str(Global.max_range))
	results_label.text = ""
	average_label.text = ""
	result_graph.visible = false
	winner_label.text = ""
	restart_label.text = ""
	menu_button.visible = false
	
	apply_theme_color(0)
	number_of_players = Global.number_of_players
	
	menu_button.add_theme_color_override("font_outline_color", Color("#E4E4E4"))
	menu_button.add_theme_constant_override("outline_size", 0)
	menu_button.add_theme_font_size_override("font_size", 64)

var _reveal_value: float = 0.0

func animate_average_reveal(final_average: float):
	average_label.text = "Average: " + str(int(Global.min_range))
	_reveal_value = float(Global.min_range)
	
	# wait for line draw to finish before starting
	await get_tree().create_timer(1.1).timeout
	
	var settle_tween = create_tween()
	settle_tween.set_trans(Tween.TRANS_LINEAR)
	#settle_tween.set_ease(Tween.EASE_IN)
	
	# just the dots duration + small buffer for the average reveal
	var duration = (guesses.size() * 0.15)
	
	settle_tween.tween_method(
		_on_reveal_tick,
		float(Global.min_range),
		round(final_average),
		duration
	)
	
	settle_tween.tween_callback(func():
		_on_reveal_tick(round(final_average))
	)

var _last_displayed: int = -1

func _on_reveal_tick(val: float):
	var displayed = int(val)
	if displayed != _last_displayed:
		_last_displayed = displayed
		average_label.text = "Average: " + str(displayed)
		SoundManager.play_sfx(SoundsList.ui_round_start, -30, 2.6)

func shake_screen(intensity: float = 10.0, duration: float = 0.2):
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# rapid jitter that fades out
	var shake_count = 6
	for i in range(shake_count):
		var current_intensity = intensity * (float(shake_count - i) / shake_count)
		var target_pos = Vector2(
			randf_range(-current_intensity, current_intensity),
			randf_range(-current_intensity, current_intensity)
		)
		tween.tween_property($Camera2D, "offset", target_pos, duration / shake_count)
	
	tween.tween_property($Camera2D, "offset", Vector2.ZERO, 0.05)
	
func results_zoom(target_grid_size, duration):
	var tween = create_tween()
	tween.tween_property(background_shader, "shader_parameter/grid_size", target_grid_size, duration)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_IN_OUT)  # ease in softens the initial jolt
		
func _input(event):
	if event.is_action_pressed("ui_accept") and !line_edit.editable:
		call_deferred("reset_game")

	if event.is_action_pressed("ui_esc") and !line_edit.editable:
		pass

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "main_menu":
		get_tree().change_scene_to_file("res://main_menu.tscn")
		SoundManager.play_sfx(SoundsList.ui_round_start, -16, 1.4)

# button hover effects
func _on_menu_button_mouse_entered() -> void:
	menu_button.add_theme_constant_override("outline_size", 20)

func _on_menu_button_mouse_exited() -> void:
	menu_button.add_theme_constant_override("outline_size", 0)

func _on_menu_button_button_down() -> void:
	animations.play("main_menu")
	SoundManager.play_sfx(SoundsList.ui_click, -12, 1)

func _on_menu_button_button_up() -> void:
	pass


func _on_show_results_button_button_down() -> void:
	$show_results_anim.play("show_results")


func _on_show_results_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "show_results":
		SoundManager.play_sfx(SoundsList.ui_click, -12, 1)
		show_results_section.visible = false
		show_results()


func _on_show_results_button_mouse_entered() -> void:
	$show_results/show_results_button.add_theme_constant_override("outline_size", 20)


func _on_show_results_button_mouse_exited() -> void:
	$show_results/show_results_button.add_theme_constant_override("outline_size", 0)
