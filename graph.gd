extends Control

signal animation_finished
signal average_ready

var dot_reveal = SoundsList.ui_click
var average_reveal = SoundsList.ui_winner_reveal

var guesses = []
var average = 0.0
var colors = []
var golden_indices = [] 

var draw_progress = 0.0      
var visible_dots = 0         
var target_alpha = 0.0       
var active_tween: Tween      

func setup(p_guesses: Array, p_average: float, p_colors: Array):
	if active_tween:
		active_tween.kill()
		
	guesses = p_guesses
	average = p_average
	colors = p_colors
	
	# find winner(s) for the gold circle highlight
	golden_indices.clear()
	var closest_diff = 10000000000.0
	for g in guesses:
		var diff = abs(g - average)
		if diff < closest_diff:
			closest_diff = diff
			
	for i in range(guesses.size()):
		if is_equal_approx(abs(guesses[i] - average), closest_diff):
			golden_indices.append(i)
	
	draw_progress = 0.0
	visible_dots = 0
	target_alpha = 0.0
	
	active_tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	active_tween.tween_property(self, "draw_progress", 1.0, 1.0)
	
	# sequential dot popping
	for i in range(1, guesses.size() + 1):
		active_tween.tween_interval(0.15)
		active_tween.tween_callback(play_dot_reveal.bind(i))
	
	active_tween.tween_interval(0.5)
	active_tween.tween_callback(func(): 
		if is_visible_in_tree(): 
			SoundManager.play_sfx(average_reveal, -16, 1.6)
	)
	
	active_tween.tween_callback(func(): 
		if is_visible_in_tree():
			get_parent().get_parent().get_parent().shake_screen(9.0, 0.2)
	)
	
	active_tween.tween_property(self, "target_alpha", 1.0, 0.25)

func play_dot_reveal(index: int):
	visible_dots = index
	if visible:
		SoundManager.play_sfx(dot_reveal, -12, 1.2)
	
	queue_redraw()

func _process(_delta):
	if draw_progress < 1.0 or target_alpha < 1.0:
		queue_redraw()

func _draw():
	var width = size.x
	var y_center = size.y / 3 
	var margin = 60 
	var full_width = width - (margin * 2)
	
	# main horizontal line
	draw_line(Vector2(margin, y_center), Vector2(margin + (full_width * draw_progress), y_center), Color.BLACK, 3.0, true)
	
	if draw_progress < 0.1: return 

	# snap average to whole numbers for visual alignment
	var rounded_avg = round(average)
	var avg_x = remap(rounded_avg, Global.min_range, Global.max_range, float(margin), float(width - margin))
	
	# calc stack height to offset indicator triangles
	var dot_radius = 12.0
	var padding = 10.0
	var avg_stack_height = 0
	
	for g in guesses:
		if round(g) == rounded_avg:
			avg_stack_height += 1
			
	var top_offset = dot_radius + padding
	var bottom_offset = dot_radius + padding + (max(0, avg_stack_height - 1) * 22)

	# draw average indicator (top/bottom triangles)
	var tri_w = 18.0
	var tri_h = 16.0
	var t_color = Color(0, 0, 0, target_alpha)
	
	var top_tri = PackedVector2Array([
		Vector2(avg_x - (tri_w/2), y_center - tri_h - top_offset), 
		Vector2(avg_x + (tri_w/2), y_center - tri_h - top_offset), 
		Vector2(avg_x, y_center - top_offset)
	])
	var bot_tri = PackedVector2Array([
		Vector2(avg_x - (tri_w/2), y_center + tri_h + bottom_offset), 
		Vector2(avg_x + (tri_w/2), y_center + tri_h + bottom_offset), 
		Vector2(avg_x, y_center + bottom_offset)
	])

	draw_colored_polygon(top_tri, t_color)
	draw_colored_polygon(bot_tri, t_color)

	# draw player dots (handle vertical stacking for same guesses)
	var frequency = {}
	for g in guesses: frequency[g] = frequency.get(g, 0) + 1
	var current_stack_indices = {} 

	for i in range(visible_dots):
		var guess = guesses[i]
		var x_pos = remap(guess, Global.min_range, Global.max_range, float(margin), float(width - margin))
		var y_pos = y_center 
		
		if frequency[guess] > 1:
			var stack_idx = current_stack_indices.get(guess, 0)
			if stack_idx > 0: y_pos = y_center + (stack_idx * 22) + 2 
			current_stack_indices[guess] = stack_idx + 1

		if i in golden_indices:
			draw_circle(Vector2(x_pos, y_pos), 16.0, Color.GOLD)

		draw_circle(Vector2(x_pos, y_pos), 12.0, Color.WHITE) 
		draw_circle(Vector2(x_pos, y_pos), 10.0, colors[i % colors.size()])
