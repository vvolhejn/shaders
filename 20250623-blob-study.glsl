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

float logdist(vec2 a, vec2 b) {
  return log(1. + distance(a, b));
}

float logdist(vec3 a, vec3 b) {
  return log(1. + distance(a, b));
}

mat3 euler1(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat3(
    c, -s, 0.,
    s, c, 0.,
    0., 0., 1.
  );
}

mat3 euler2(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat3(
    c, 0., s,
    0., 1., 0.,
    -s, 0., c
  );
}

mat3 euler3(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat3(
    1., 0., 0.,
    0., c, -s,
    0., s, c
  );
}

mat3 rotation(float a1, float a2, float a3) {
  return euler1(a1) * euler2(a2) * euler3(a3);
}

void main() {
  float time = iGlobalTime * 1.0;
  vec2 uv = (gl_FragCoord.xy / iResolution.xy) * 2. - 1.;
  float zScale = 0.1;
  vec3 uv3 = vec3(uv, zScale);

  float noise = smoothstep(0.99, 1.0, rand2(uv));

  vec3 c1 = vec3(0.7, 0.0, 0.) * rotation(1. + time * 0.75, .7, 0.5);
  vec3 c2 = vec3(0.0, 0.7, 0.) * rotation(time * 1.5, 0.05, .7);
  c1.z *= zScale;
  c2.z *= zScale;

  // float d1 =  distance(c1, uv3);
  // float d2 = distance(c2, uv3);
  float d1 = logdist(c1, uv3);
  float d2 = logdist(c2, uv3);

  float sdf = logdist(c1, uv3) + logdist(c2, uv3);
  float thresh = 0.85;

  // float sdf = min(d1, d2);
  // float thresh = 0.2;

  // float thresh = mix(0.1, .8, (sin(time * 1.) + 1.) * .5);
  // vec3 color = vec3(step(thresh, sdf));
  // color -= noise * 0.2;
  // color += noise2 * 0.2;
  vec3 background = vec3(1.0, 0.8, 0.8) - noise;
  vec3 foreground = vec3(0.) + noise * vec3(0.8, 0.8, 1.0);

  vec3 color = sdf < thresh ? foreground : background;
  // vec3 color = vec3(sdf);

  gl_FragColor = vec4(color, 1.0);
}
