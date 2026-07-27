extends ColorRect

func _process(_delta):
	# Get the mouse position relative to the screen
	var mouse_pos = get_global_mouse_position()
	
	# Pass the position into the shader's "mouse_offset" uniform
	# We use set_shader_parameter for Godot 4.x
	material.set_shader_parameter("mouse_offset", mouse_pos)
