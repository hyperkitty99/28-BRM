#pragma header
#define distortion 0.5

void main() {
    vec2 uv = openfl_TextureCoordv - 0.5;
    uv = uv * (1.0 + distortion * (dot(uv, uv) - 0.25)) + 0.5;

    gl_FragColor = (uv.x <= 0.0 || uv.x > 1.0 || uv.y <= 0.0 || uv.y > 1.0) ? vec4(0.0) : flixel_texture2D(bitmap, uv);
}