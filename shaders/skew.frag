#pragma header

uniform float skew;

void main() {
    vec2 uv = (openfl_TextureCoordv) * 2.0 - 0.5;
	uv *= mat2(1.0, skew, 0.0, 1.0);
    uv.y += 0.5;

	if (uv.x <= 0.0 || uv.x > 1.0 || uv.y <= 0.0 || uv.y > 1.0) gl_FragColor = vec4(0.0);

    gl_FragColor = flixel_texture2D(bitmap, uv);
}