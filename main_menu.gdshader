shader_type canvas_item;

uniform float speed = 0.05;
uniform float density = 10.0;
uniform float base_size = 0.12;
uniform float size_variation = 0.08;
uniform float pulse_speed = 3.0; // How fast they breathe
uniform float pulse_intensity = 0.3; // How much they change size (0.0 to 1.0)

uniform vec4 bg_color : source_color = vec4(0.02, 0.02, 0.05, 1.0);
uniform vec4 shape_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

float rand(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 moving_uv = UV + (TIME * speed);
    vec2 st = moving_uv * density;
    vec2 grid_uv = fract(st);
    vec2 cell_id = floor(st);

    float mask = 0.0;

    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 neighbor_offset = vec2(float(x), float(y));
            vec2 target_cell = cell_id + neighbor_offset;

            // 1. Generate random seeds for this cell
            float seed_pos = rand(target_cell);
            float seed_size = rand(target_cell + vec2(1.0, 1.0));
            float seed_pulse = rand(target_cell + vec2(2.0, 2.0)); // Unique seed for pulse

            // 2. Calculate breathing effect
            // We use seed_pulse * 10.0 so they don't all start at the same phase
            float pulse = sin(TIME * pulse_speed + (seed_pulse * 10.0));
            // Map sin (-1 to 1) to a multiplier (e.g., 0.7 to 1.3)
            float pulse_mult = 1.0 + (pulse * pulse_intensity);

            // 3. Position and Size
            vec2 shape_pos = vec2(seed_pos, fract(seed_pos * 1.512));
            float current_shape_size = (base_size + (seed_size - 0.5) * 2.0 * size_variation) * pulse_mult;

            // 4. Draw
            float dist = distance(grid_uv, neighbor_offset + shape_pos);
            mask += smoothstep(current_shape_size, current_shape_size - 0.02, dist);
        }
    }

    mask = clamp(mask, 0.0, 1.0);
    COLOR = mix(bg_color, shape_color, mask);
}