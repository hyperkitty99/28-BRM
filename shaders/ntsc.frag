#pragma header
#pragma format R8G8B8A8_SRGB

const float luma_filter[33] = float[33](
    -0.0002, -0.0002, -0.0001, -0.0001, 0.0, -0.0001, -0.0002, -0.0004, -0.0005, -0.0003, 0.0002, 0.0007, 0.0009, 0.001, 0.0004, 0.0, 0.0003, 0.001, 0.003, 0.004,
    0.003, -0.001, -0.008, -0.02, -0.02, -0.02, -0.009, 0.02, 0.06, 0.1, 0.1, 0.2, 0.2
);

const float chroma_filter[33] = float[33](
    0.001, 0.002, 0.002, 0.002, 0.003, 0.003, 0.004, 0.005, 0.005, 0.006, 0.007, 0.008, 0.009, 0.01, 0.01, 0.01, 0.01, 0.02, 0.02, 0.02,
    0.02, 0.02, 0.02, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03, 0.03
);

vec4 pass1(vec2 uv, float chroma_phase) {
    vec4 cola = flixel_texture2D(bitmap, uv);
    return vec4(vec3(dot(cola.rgb, vec3(0.2989, 0.5870, 0.1140)), dot(cola.rgb, vec3(0.5959, -0.2744, -0.3216)), dot(cola.rgb, vec3(0.2115, -0.5229, 0.3114))), cola.a);
}

void main() {
    vec2 uv = openfl_TextureCoordv;
    float one_x = 1.0 / openfl_TextureSize.x;

    float chroma_phase = 3.14 * mod((uv * openfl_TextureSize).y, 2.0);

    vec4 signal = vec4(0.0);
    for (int i = 0; i < 32; i++) {
        signal += pass1(uv + vec2(((-32.5 * one_x) + float(i) * one_x), 0.0), chroma_phase) * (vec4(luma_filter[i], chroma_filter[i], chroma_filter[i], 1.0) * 2.0);
    }

    signal += pass1(uv - vec2(0.5 * one_x, 0.0), chroma_phase) * vec4(luma_filter[32], chroma_filter[32], chroma_filter[32], 1.0);

    gl_FragColor = vec4(pow(vec3(signal.x + 0.956 * signal.y + 0.621 * signal.z, signal.x - 0.272 * signal.y - 0.647 * signal.z, signal.x - 1.106 * signal.y + 1.704 * signal.z), vec3(1.25)), flixel_texture2D(bitmap, uv).a);
}