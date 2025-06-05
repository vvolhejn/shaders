precision highp float;
uniform vec2 u_resolution;
uniform float u_time;

mat2 m11 = mat2(0.,1.,1.,0.);
mat2 m12 = mat2(1.,0.,0.,1.);
mat2 m22 = mat2(1.,0.,0.,1.);
mat2 m21 = mat2(0.,-1.,-1.,0.);

float getProgress(vec2 uv, int level) {
    float progress = 0.;

    for (int i = 0; i < 10; ++i) {
        if (i >= level) break;

        vec2 uv2;
        float baseProgress;
        if (uv.x <= 0. && uv.y <= 0.) {
            uv2 = m11 * vec2(uv.x + 0.5, uv.y + 0.5) * 2.;
            baseProgress = 0.;
        } else if (uv.x <= 0. && uv.y > 0.) {
            uv2 = m12 * vec2(uv.x + 0.5, uv.y - 0.5) * 2.;
            baseProgress = 1.;
        } else if (uv.x > 0. && uv.y > 0.) { 
            uv2 = m22 * vec2(uv.x - 0.5, uv.y - 0.5) * 2.;
            baseProgress = 2.;
        } else if (uv.x > 0. && uv.y <= 0.) { 
            uv2 = m21 * vec2(uv.x - 0.5, uv.y + 0.5) * 2.;
            baseProgress = 3.;
        }

        uv = uv2;
        progress += baseProgress * pow(4., float(level-i));
    }

    return progress * pow(4., -float(level+1));
}

void main() {
    vec2 uv = (gl_FragCoord.xy / u_resolution.xy - 0.5) * 2.;

    float progress = getProgress(uv, 7);
    float highlight1 = cos(u_time * 1. + progress * 100.);
    float highlight2 = sin(u_time * sqrt(1./5.) - progress * 100.);

    vec3 color = vec3((highlight1 - 0.9) * 7., (highlight2 - 0.9) * 7., 0.1);

    gl_FragColor = vec4(color, 1.0);
}
