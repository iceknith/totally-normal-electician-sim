shader_type canvas_item;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

group_uniforms colors;
uniform float desaturation = 0.8;
uniform float contrast = 1.0;
uniform float brightness = 0.0;
uniform float redify = 0.2;

group_uniforms posterization;
//uniform vec3 posterizationLevelsIn;
uniform vec3 posterizationLevelsOut;

group_uniforms dither;
uniform sampler2D ditherMatrixTexture : repeat_enable, filter_nearest;
uniform int ditherSize = 1;
uniform vec3 colorLevels;
uniform vec2 ditherSpeed;

group_uniforms displacement;
uniform sampler2D displacementNoise : filter_nearest, repeat_enable;
uniform vec2 displacementDirection = vec2(1,1);
uniform float displacementStrength = 0.1;
group_uniforms noise;
uniform sampler2D noise : filter_nearest, repeat_enable;
uniform vec2 noiseDirection = vec2(1,1);
uniform float noiseStrength = 0.1;

vec3 rgb_to_hsv(vec3 rgb) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(rgb.bg, K.wz), vec4(rgb.gb, K.xy), step(rgb.b, rgb.g));
	vec4 q = mix(vec4(p.xyw, rgb.r), vec4(rgb.r, p.yzx), step(p.x, rgb.r));
	
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv_to_rgb(vec3 hsv) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(hsv.xxx + K.xyz) * 6.0 - K.www);
	return hsv.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), hsv.y);
}

float posterize(float v, float levels) {
	return floor(v*levels)/levels;
}

vec3 posterize(vec3 v, vec3 levels) {
	return round(v*levels)/levels;
}

vec3 dither(vec3 colRGB, vec2 uv, vec2 screen_pixel_size) { // dither with dither size of 1
	vec2 ditherMatrixSize = vec2(textureSize(ditherMatrixTexture,0));
	vec2 ditherMatrixSampleUV = uv / (screen_pixel_size * ditherMatrixSize * float(ditherSize));
	vec3 ditherValue = texture(ditherMatrixTexture, ditherMatrixSampleUV + TIME * ditherSpeed).rbg;
	return posterize(colRGB - ditherValue, colorLevels);
}

void fragment() {
	// Noises
	vec2 displacement = vec2(1,1) - texture(displacementNoise, UV + TIME * displacementDirection).rg*2.0;
	vec3 colRGB = texture(SCREEN_TEXTURE, UV + displacement * displacementStrength).rgb;
	
	vec3 colorNoise = texture(noise, UV + TIME * noiseDirection).rgb;
	colRGB = colRGB * (1.0-noiseStrength) + colorNoise*noiseStrength;
	
	// Tend to red
	colRGB.gb *= 1.0 - redify;
	
	// Apply contrast & brightness
	colRGB = (colRGB - 0.5) * contrast + 0.5;
	colRGB = min(vec3(1,1,1), colRGB + brightness * 0.5);
	
	// Posterize
	//colRGB = posterize(colRGB, posterizationLevelsIn);
	
	// Apply dithering
	colRGB = dither(colRGB, UV, SCREEN_PIXEL_SIZE);
	
	vec3 colHSV = rgb_to_hsv(colRGB);
	
	// Desaturate
	colHSV.g *= desaturation;
	
	// Posterize Out
	colRGB = posterize(hsv_to_rgb(colHSV), posterizationLevelsOut);
	
	COLOR.rgb = colRGB;
	//COLOR.rgb = colorNoise;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
