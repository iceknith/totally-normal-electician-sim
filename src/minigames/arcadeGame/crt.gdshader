shader_type canvas_item;

uniform sampler2D input_texture : repeat_disable, filter_linear_mipmap;

uniform float shake : hint_range(0.0, 1.0) = 0.1;

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = UV; 
    
    // Shake
    if (rand(vec2(TIME, 0.0)) < shake) {
        uv.x += rand(vec2(TIME, uv.y)) * 0.01;
    }

    // RGB split
    float r = texture(input_texture, uv + vec2(0.003, 0.0)).r;
    float g = texture(input_texture, uv).g;
    float b = texture(input_texture, uv - vec2(0.003, 0.0)).b;
    
    // Scanlines
    float scanline = sin(uv.y * 400.0) * 0.04;

    COLOR = vec4(r - scanline, g - scanline, b - scanline, 1.0);
}