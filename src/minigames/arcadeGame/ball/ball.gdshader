	shader_type canvas_item;

	uniform int pixel_to_check = 10;
	uniform int center_distance_cap =1;





	bool has_neighbor(vec2 uv, vec2 texture_pixel_size, sampler2D sprite_texture)
	{
		for (int x = -pixel_to_check; x <= pixel_to_check; x++)
		{
			for (int y = -pixel_to_check; y <= pixel_to_check; y++)
			{
				if (x == 0 && y == 0) {
					continue;
				}

				if ((abs(x) + abs(y)) > center_distance_cap) {
					continue;
				}

				vec2 xy = vec2(float(x), float(y));
				vec2 sprite_coordinates = uv + xy * texture_pixel_size;

				if (texture(sprite_texture, sprite_coordinates).a > 0.0) {
					return true;
				}
			}
		}
		return false;
	}

	void fragment() {

		vec4 color = vec4(2.0, 0.1, 0.2, 1.0);
		if (COLOR.a < 0.01 && has_neighbor(UV, TEXTURE_PIXEL_SIZE, TEXTURE)) {
			COLOR = color*0.5;
			COLOR.a = 1.0;
		}

	}