shader_type canvas_item;

uniform sampler2D mask;

uniform vec4 current_color: hint_color;
uniform vec4 previous_color: hint_color;

uniform float delta: hint_range(0.0, 1.0) = 1.0;

uniform vec2 origin;


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
	
	vec4 m = texture(mask, UV);
	if (m.a != 0.0)
	{
		vec2 dir = position - origin;
		float dist = max(abs(dir.x), abs(dir.y));
		
		c = dist < delta * delta ? m * current_color : m*previous_color;
	}
	
	COLOR = c;
}