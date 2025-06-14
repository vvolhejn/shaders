// use the Shader Toy VSCode plugin
#iChannel0 "file://textures/droste-small.jpg"

vec2 bottomLeft = vec2(0.42, 0.49);
vec2 topRight = vec2(0.912, 0.88);

vec2 rescale(vec2 uv) {
    vec2 a = (uv - bottomLeft) / (topRight - bottomLeft);

    return a;
}

void main() {
    vec2 uv = (gl_FragCoord.xy / iResolution.xy);

    float t = fract(iTime / 2.);
    float zoom = pow(2., t);
    vec2 rectSize = topRight - bottomLeft;
    
    // uv = vec2(
    //     uv.x + (1. - pow(1. - bottomLeft.x, t)),
    //     uv.y + (1. - pow(1. - bottomLeft.y, t))
    // );
    // uv = vec2(uv.x * pow(rectSize.x, t), uv.y * pow(rectSize.y, t));
    // uv = vec2(mix(uv.x * rectSize.x * (1 + t), uv.y);
    // uv += bottomLeft * t;

    // uv = mix(bottomLeft, topRight, uv);
    uv = mix(
        mix(bottomLeft, topRight, uv),
        uv,
        pow(2., 1. - t) - 1.
    );

    vec3 color = texture(iChannel0, uv).xyz;

    for (int i = 0; i < 5; i++) {
        if (uv.x >= bottomLeft.x && uv.x <= topRight.x &&
            uv.y >= bottomLeft.y && uv.y <= topRight.y) {
            uv = rescale(uv);
        }
    }
    color = texture(iChannel0, uv).xyz;
    gl_FragColor = vec4(color, 1.);
}