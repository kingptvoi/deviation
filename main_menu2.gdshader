shader_type canvas_item;
uniform vec4 line_color : source_color = vec4(0.85, 0.85, 0.85, 1.0);
uniform float grid_size = 60.0;
uniform vec2 mouse_offset;
uniform float parallax_strength = 0.5;

void fragment() {
	vec2 movement = (TIME * 20.0) + (mouse_offset * parallax_strength);
	vec2 grid_uv = (FRAGCOORD.xy + movement) / grid_size;

    // Use a stable derivative based on screen pixels, not grid space
	vec2 grid_fwidth = vec2(length(vec2(dFdx(FRAGCOORD.x), dFdy(FRAGCOORD.x))),
							length(vec2(dFdx(FRAGCOORD.y), dFdy(FRAGCOORD.y)))) / grid_size;

	vec2 grid = abs(fract(grid_uv - 0.5) - 0.5) / grid_fwidth;
	float line = min(grid.x, grid.y);
	float mask = 1.0 - clamp(line, 0.0, 1.0);

 	vec4 bg_color = vec4(1.0, 1.0, 1.0, 1.0);
	COLOR = mix(bg_color, line_color, mask);
}