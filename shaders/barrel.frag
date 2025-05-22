#pragma header

uniform float distortionX;
uniform float distortionY;

void main() {
    vec2 centered = vec2((openfl_TextureCoordv.x - 0.125) / 0.75, openfl_TextureCoordv.y) - 0.5;
    centered *= 1.0 + vec2(distortionX, distortionY) * (dot(centered, centered) - 0.25);

    gl_FragColor = flixel_texture2D(bitmap, vec2(centered.x * 0.75, centered.y) + 0.5);
}