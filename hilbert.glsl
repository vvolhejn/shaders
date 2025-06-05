precision highp float;
uniform vec2 u_resolution;
uniform float u_time;

mat2 m11 = mat2(1.,0.,0.,1.);
mat2 m21 = mat2(1.,0.,0.,1.);
mat2 m12 = mat2(1.,0.,0.,1.);
mat2 m22 = mat2(1.,0.,0.,1.);

float getProgress(vec2 uv, int level) {
    float progress = 0.;

    for (int i = 0; i < 10; ++i) {
        if (i >= level) break;

        vec2 uv2;
        float baseProgress;
        if (uv.x <= 0.5 && uv.y <= 0.5) {
            uv2 = m11 * uv * 2.;
            baseProgress = 0.;
        } else if (uv.x > 0.5 && uv.y <= 0.5) {
            uv2 = m21 * vec2(uv.x - 0.5, uv.y) * 2.;
            baseProgress = 3.;
        } else if (uv.x <= 0.5 && uv.y > 0.5) { 
            uv2 = m12 * vec2(uv.x, uv.y - 0.5) * 2.;
            baseProgress = 1.;
        } else if (uv.x > 0.5 && uv.y > 0.5) { 
            uv2 = m22 * vec2(uv.x - 0.5, uv.y - 0.5) * 2.;
            baseProgress = 2.;
        }

        uv = uv2;
        progress += baseProgress * pow(4., float(level-i));

        // return baseProgress + getProgress(uv2, level - 1) * 0.25;
    }

    return progress * pow(4., -float(level+1));
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;

    float progress = getProgress(uv, 2);


    vec3 color = vec3(progress, progress, progress);

    gl_FragColor = vec4(color, 1.0);


    // // Generate rapid movement effect
    // float speed = 5.0;
    // vec2 offset = vec2(
    //     cos(u_time * speed),
    //     sin(u_time * speed)
    // );

    // // Generate trippy color effect
    // vec3 color = vec3(
    //     sin(u_time * 1.0 + uv.x * 10.0) * cos(uv.y * 10.0),
    //     cos(u_time * 1.5 + uv.y * 5.0) * sin(uv.x * 10.0),
    //     cos(u_time * 2.0) * sin(uv.x * uv.y * 20.0)
    // );

    // // Apply color palette
    // vec3 lavender = vec3(0.8, 0.6, 1.0);
    // vec3 orange = vec3(1.0, 0.6, 0.2);
    // vec3 pastelPink = vec3(1.0, 0.7, 0.8);
    // vec3 pastelYellow = vec3(1.0, 0.9, 0.4);
    // vec3 lightBlue = vec3(0.6, 0.8, 1.0);

    // color = mix(color, lavender, 0.1);
    // color = mix(color, orange, 0.2);
    // color = mix(color, pastelPink, 0.3);
    // color = mix(color, pastelYellow, 0.4);
    // color = mix(color, lightBlue, 0.5);

    // // Apply movement offset
    // uv += offset * 0.03;

    // gl_FragColor = vec4(color, 1.0);
}
