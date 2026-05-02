shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec2 center;
uniform float force;
uniform float size;
uniform float ca_strength;
uniform float thickness;
uniform float offset;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	
	vec2 scaledUV = (SCREEN_UV - vec2(0.5, 0.0)) / vec2(ratio, 1.0) + vec2(0.5, 0.0);
	float mask = (1.0 - smoothstep(size - 0.1, size, length(scaledUV - center))) *
	smoothstep(size - thickness - 0.1, size - thickness, length(scaledUV - center));
	
	vec2 disp = normalize(SCREEN_UV - center) * force * mask;
	
	// Chromatic aberration: spread R/G/B along the displacement direction
	vec2 ca = disp * ca_strength;
	
	float r = texture(SCREEN_TEXTURE, UV - disp - ca).r;
	float g = texture(SCREEN_TEXTURE, UV - disp).g;
	float b = texture(SCREEN_TEXTURE, UV - disp + ca).b;
	
	COLOR = vec4(r, g, b, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
