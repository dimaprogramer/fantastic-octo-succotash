shader_type canvas_item;

uniform float color_strength : hint_range(0.0, 1.0) = 0.0;
uniform float red : hint_range(0.0, 1.0) = 0.0;
uniform float green : hint_range(0.0, 1.0) = 0.0;
uniform float blue : hint_range(0.0, 1.0) = 0.0;
uniform float alpha : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	vec3 color = vec3(red,green,blue);
	vec3 mixed = mix(tex.rgb, color, color_strength);
	float alpha_mixed = tex.a * alpha;

	COLOR = vec4(mixed, alpha_mixed);
}