shader_type canvas_item;
//render_mode blend_mix;

uniform vec4 current_color: hint_color;
uniform vec4 previous_color: hint_color;

uniform float start_time;
uniform float duration: hint_range(0.01, 2.0) = 0.05 ;


vec2 texture_size(sampler2D t)
{
	ivec2 s = textureSize(t, 0);
	return vec2(float(s.x), float(s.y));
}


void fragment()
{
	vec2 size = texture_size(TEXTURE);
	
	vec2 position = UV * size;
	position.x = floor(position.x);
	position.y = floor(position.y);
	
	vec4 c = texture(TEXTURE, UV);
	
	if (position.x >= 4.0 && position.x <= 27.0 && position.y >= 4.0 && position.y <= 27.0)
	{
		vec2 dir = position - vec2(15.5, 15.5);
		float dist = max(abs(dir.x), abs(dir.y));
		float delta = (TIME - start_time) / duration;
		
		c = dist < delta * delta ? c * current_color : c * previous_color;
	}
	
	COLOR = c;
}