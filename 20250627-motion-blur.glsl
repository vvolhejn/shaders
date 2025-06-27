// Use with Shader Toy

// A single iteration of Bob Jenkins' One-At-A-Time hashing algorithm.
int hash( int x ) {
    x += ( x << 10u );
    x ^= ( x >>  6u );
    x += ( x <<  3u );
    x ^= ( x >> 11u );
    x += ( x << 15u );
    return x;
}

float rand1(float x){
  return fract(sin(x * 88.233) * 43758.5453);
}

float rand2(vec2 co){
  return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
}

const vec3 FG = vec3(1.000, 0.420, 0.424);
const vec3 BG = vec3(1.000, 1.000, 0.95);

const float N = 9.;
const float TWO_PI = 6.2831853072;

float wavy(float x) {
  x = mod(x, TWO_PI);
  return x + sin(x);
}

float getSdf(vec2 uv, float time) {
  float phase = wavy(time * 2.0) + wavy(time * 3.0);
  vec2 center = vec2(cos(phase), sin(phase)) * 0.7;
  float sdf = distance(center, uv) - 0.2;
  return sdf;
}

void main() {
  float time = iGlobalTime;
  vec2 uv = (gl_FragCoord.xy / iResolution.xy);

  uv = (uv - 0.5) * 2.;

  float sdf = getSdf(uv, time);

  float STEPS = 30.;
  float STEP_SIZE = 0.005;
  float THRESH = 0.01;

  for (float i = 0.; i < STEPS; i++) {
    float csdf = getSdf(uv, time - i * STEP_SIZE);
    sdf = min(sdf, max(csdf, i / STEPS * THRESH));
  }

  vec3 color = mix(FG, BG, smoothstep(0., THRESH, sdf));

  // color = vec3(tile[0] * 0.2, tile[1]* 0.2, 0.);
  gl_FragColor = vec4(color, 1.0);
}
