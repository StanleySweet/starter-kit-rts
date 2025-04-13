shader_type spatial;

uniform sampler2D albedo: hint_default_black;
uniform sampler2D mask : hint_default_black;
uniform vec4 color = vec4 (0.0, 0.0, 0.0, 1.0);


void fragment() {

	vec4 pixel = texture(albedo, UV);
	vec4 pixel_mask = texture(mask, UV);

	ALBEDO = mix(pixel.rgb, color.rgb, pixel_mask.r);
	ALPHA = pixel.a;
	// Called for every pixel the material is visible on.
}
