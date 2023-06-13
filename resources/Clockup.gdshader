shader_type canvas_item;

uniform float contrast = 1.0;

void fragment() {
	COLOR.rgb = (COLOR.rgb - 0.5) * contrast + 0.5;
	// Place fragment code here.
}
