precision highp float;
uniform vec2 u_resolution;
uniform float u_time;

mat2 m11 = mat2(0.,1.,1.,0.);
mat2 m12 = mat2(1.,0.,0.,1.);
mat2 m22 = mat2(1.,0.,0.,1.);
mat2 m21 = mat2(0.,-1.,-1.,0.);

float rand(vec2 co){
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

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
    float periodicTime = fract(u_time * .2);
    // periodicTime = 0.;

    float zoom = pow(2., periodicTime);
    vec2 uv = (gl_FragCoord.xy / u_resolution.xy - 0.5) * 2.;

    uv = vec2((uv.x + 1.) / zoom - 1., (uv.y - 1.) / zoom + 1.);
    
    float progress = getProgress(uv, 7);
    
    // "snake" animation
    // progress = fract(progress + periodicTime);
    
    // color periodically (doesn't play nice with zoom)
    // progress = (sin(progress * 3.14159 * 2. + u_time * 0.3) + 1.) / 2.;

    progress -= 0.25 * periodicTime;
    progress *= pow(4., periodicTime);

    float highlight1 = cos(u_time * 1. + progress * 100.);
    float highlight2 = sin(u_time * sqrt(1./5.) + progress * 90.);

    vec3 color = mix(vec3(0.8,0.6,0.1), vec3(0.6,.2,0.8), progress);

    color += rand(uv) * 0.03;

    gl_FragColor = vec4(color, 1.0);
}
