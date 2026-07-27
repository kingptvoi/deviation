extends Control

@onready var start = $VBoxContainer/start
@onready var increase = $VBoxContainer/HBoxContainer/increase
@onready var decrease = $VBoxContainer/HBoxContainer/decrease
@onready var players_number = $VBoxContainer/HBoxContainer/players_number
@onready var sounds_button = $VBoxContainer/sounds
@onready var show_numbers_button = $VBoxContainer/show_numbers
@onready var minimum_line_edit = $VBoxContainer/HBoxContainer2/minimum
@onready var maximum_line_edit = $VBoxContainer/HBoxContainer2/maximum

var players: int

var check = preload("res://assets/icons/check.png")
var x = preload("res://assets/icons/x.png")

@onready var animations = $AnimationPlayer

var minimum: int = 1
var maximum: int = 100

var max_value_value: int
var min_value_value: int

var can_start: bool

func _process(delta: float) -> void:

	players = Global.number_of_players
	players_number.text = str(players)
	
	#if Input.is_action_just_pressed("ui_accept"):
		#animations.play("start_game")
		#SoundManager.play_sfx(click)
		
	#if Input.is_action_just_pressed("ui_left"):
		#animations.play("decrease")
		#SoundManager.play_sfx(SoundsList.ui_click)
		#Global.number_of_players -= 1
	#
	#if Input.is_action_just_pressed("ui_right"):
		#animations.play("increase")
		#SoundManager.play_sfx(SoundsList.ui_click)
		#Global.number_of_players += 1

func _ready() -> void:
	
	can_start = true
	
	minimum_line_edit.text = str(Global.min_range)
	maximum_line_edit.text = str(Global.max_range)
	
	if Global.sounds_on == true:
		sounds_button.text = "Sounds: on"
	else:
		sounds_button.text = "Sounds: off"
	
	animations.play("intro")


	start.add_theme_color_override("font_outline_color", Color("#E4E4E4"))
	start.add_theme_constant_override("outline_size", 0)
	start.add_theme_font_size_override("font_size", 64)

	increase.add_theme_color_override("font_outline_color", Color("#E4E4E4"))
	increase.add_theme_constant_override("outline_size", 0)
	increase.add_theme_font_size_override("font_size", 64)

	decrease.add_theme_color_override("font_outline_color", Color("#E4E4E4"))
	decrease.add_theme_constant_override("outline_size", 0)
	decrease.add_theme_font_size_override("font_size", 64)
	
	sounds_button.add_theme_color_override("font_outline_color", Color("#E4E4E4"))
	sounds_button.add_theme_constant_override("outline_size", 0)
	sounds_button.add_theme_font_size_override("font_size", 64)
	
	show_numbers_button.add_theme_color_override("font_outline_color", Color("#E4E4E4"))
	show_numbers_button.add_theme_constant_override("outline_size", 0)
	show_numbers_button.add_theme_font_size_override("font_size", 64)
	
	minimum_line_edit.add_theme_color_override("font_outline_color", Color("#E4E4E4"))
	minimum_line_edit.add_theme_constant_override("outline_size", 0)
	minimum_line_edit.add_theme_font_size_override("font_size", 32)
	
	maximum_line_edit.add_theme_color_override("font_outline_color", Color("#E4E4E4"))
	maximum_line_edit.add_theme_constant_override("outline_size", 0)
	maximum_line_edit.add_theme_font_size_override("font_size", 32)

func _on_start_mouse_entered() -> void:
	start.add_theme_constant_override("outline_size", 20)
	start.text = "Start Game"


func _on_start_mouse_exited() -> void:
	start.add_theme_constant_override("outline_size", 0)
	start.text = "Start Game"


func _on_start_button_down() -> void:
	#start.add_theme_color_override("font_outline_color", Color("#E4E4E4"))
	
	if can_start:
		SoundManager.play_sfx(SoundsList.ui_click, -12, 1)
		$AnimationPlayer.play("start_game")
	else:
		SoundManager.play_sfx(SoundsList.ui_error, 1.9, -16)
		$AnimationPlayer.play("cant_start")
		shake_screen(8.0, 0.2)
		
	#SoundManager.play_sfx(SoundsList.ui_click)
	#$AnimationPlayer.play("start_game")


func _on_start_button_up() -> void:
	start.add_theme_color_override("font_outline_color", Color("#E4E4E4"))


func _on_decrease_mouse_entered() -> void:
	decrease.add_theme_constant_override("outline_size", 20)


func _on_decrease_mouse_exited() -> void:
	decrease.add_theme_constant_override("outline_size", 0)


func _on_decrease_button_down() -> void:
	#decrease.add_theme_color_override("font_outline_color", Color("#E4E4E4"))
	Global.number_of_players -= 1
	$AnimationPlayer.play("decrease")
	SoundManager.play_sfx(SoundsList.ui_click, -12, 1)


func _on_decrease_button_up() -> void:
	decrease.add_theme_color_override("font_outline_color", Color("#E4E4E4"))

func _on_increase_mouse_entered() -> void:
	increase.add_theme_constant_override("outline_size", 20)


func _on_increase_mouse_exited() -> void:
	increase.add_theme_constant_override("outline_size", 0)


func _on_increase_button_down() -> void:
	#increase.add_theme_color_override("font_outline_color", Color("#EFEFEF"))
	Global.number_of_players += 1
	$AnimationPlayer.play("increase")
	SoundManager.play_sfx(SoundsList.ui_click, -12, 1)


func _on_increase_button_up() -> void:
	increase.add_theme_color_override("font_outline_color", Color("#E4E4E4"))


func _on_start_pressed() -> void:
	#$AnimationPlayer.play("start_game")
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "start_game":
		get_tree().change_scene_to_file("res://control.tscn")
		
		
func shake_screen(intensity: float = 10.0, duration: float = 0.2):
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# We create a series of rapid shakes that get smaller over time
	var shake_count = 6
	for i in range(shake_count):
		var current_intensity = intensity * (float(shake_count - i) / shake_count)
		var target_pos = Vector2(
			randf_range(-current_intensity, current_intensity),
			randf_range(-current_intensity, current_intensity)
		)
		tween.tween_property($Camera2D, "offset", target_pos, duration / shake_count)
	
	# Return to center
	tween.tween_property($Camera2D, "offset", Vector2.ZERO, 0.05)


func _on_minimum_text_changed(min_value: String) -> void:
	
	min_value_value = int(min_value)
	
	if min_value.is_valid_int():
		if int(min_value) < maximum:
			Global.min_range = int(min_value)
			can_start = true
		else:
			print("the minimum number (" + str(min_value_value) + ") is higher than the maximum (" + str(max_value_value) + ")")
			can_start = false
			#minimum_line_edit.text = str(Global.min_range)
	else:
		pass


func _on_maximum_text_changed(max_value: String) -> void:
	
	max_value_value = int(max_value)
	
	if max_value.is_valid_int():
		if int(max_value) > minimum:
			Global.max_range = int(max_value)
			can_start = true
		else:
			print("the maximum number (" + str(max_value_value) + ") is lower than the minimum (" + str(min_value_value) + ")")
			can_start = false
			#maximum_line_edit.text = str(Global.max_range)
	else:
		pass


func _on_sounds_button_down() -> void:
	Global.sounds_on = !Global.sounds_on
	animations.play("sounds_click")
	
	if Global.sounds_on == false:
		sounds_button.text = "Sounds: off"
	else:
		sounds_button.text = "Sounds: on"
		$AudioStreamPlayer.play()
	
	print(Global.sounds_on)


func _on_sounds_mouse_entered() -> void:
	sounds_button.add_theme_constant_override("outline_size", 20)

func _on_sounds_mouse_exited() -> void:
	sounds_button.add_theme_constant_override("outline_size", 0)


func _on_show_numbers_mouse_entered() -> void:
	show_numbers_button.add_theme_constant_override("outline_size", 20)


func _on_show_numbers_mouse_exited() -> void:
	show_numbers_button.add_theme_constant_override("outline_size", 0)


func _on_show_numbers_button_down() -> void:
	Global.show_numbers = !Global.show_numbers
	
	animations.play("numbers_click")
	SoundManager.play_sfx(SoundsList.ui_click, -12, 1)
	
	if Global.show_numbers == false:
		show_numbers_button.icon = x
	else:
		show_numbers_button.icon = check


func _on_show_numbers_button_up() -> void:
	pass # Replace with function body.


func _on_minimum_text_submitted(min_value: String) -> void:
	
	#min_value_value = int(min_value)
	#
	#if min_value.is_valid_int():
		#if int(min_value) < maximum:
			#Global.min_range = int(min_value)
			#animations.play("minimum_submit")
		#else:
			#print("the minimum number (" + str(min_value_value) + ") is higher than the maximum (" + str(max_value_value) + ")")
			#minimum_line_edit.text = str(Global.min_range)
	#else:
		#pass
	pass


func _on_maximum_text_submitted(max_value: String) -> void:
	
	#max_value_value = int(max_value)
	#
	#if max_value.is_valid_int():
		#if int(max_value) > minimum:
			#Global.max_range = int(max_value)
			#animations.play("maximum_submit")
		#else:
			#print("the maximum number (" + str(max_value_value) + ") is lower than the minimum (" + str(min_value_value) + ")")
			#maximum_line_edit.text = str(Global.max_range)
			#pass
	#else:
		#pass
	pass
