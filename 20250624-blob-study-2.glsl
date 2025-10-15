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

const float Z_SCALE = 0.0;

float circleSdf(vec3 uv3, vec3 initialPosition, float a1, float a2, float a3) {
  vec3 pos = initialPosition * rotation(a1, a2, a3);
  pos.z *= Z_SCALE;

  // return distance(pos, uv3);
  return logdist(pos, uv3);
}

float compoundBlobSdf(vec3 uv3, float time) {
  float d1 = circleSdf(uv3, vec3(1.3, 0.0, 0.), time * 0.75, 1., 0.5);
  float d2 = circleSdf(uv3, vec3(0.0, 0.7, 0.), -time * 1.23, 0.3, 0.7);
  float d3 = circleSdf(uv3, vec3(-0.5, -0.5, 0.), -time * 1.0, 0.0, 1.5);

  float sdf = d1 + d2 + d3;
  return sdf;
}

void main() {
  float time = iGlobalTime * 1.0;
  vec2 uv = (gl_FragCoord.xy / iResolution.xy) * 2. - 1.;
  vec3 uv3 = vec3(uv, Z_SCALE);


  // Simple circles for debugging:
  // float sdf = min(d1, min(d2, d3));
  // float thresh = 0.2;

  float sdf1 = compoundBlobSdf(uv3, time);
  float sdf2 = compoundBlobSdf(uv3, -1.-time);
  float thresh = 1.5;

  vec3 colors[4] = vec3[4](
    vec3(1.0, 0.8, 0.8),
    vec3(0.65, 0.22, 0.38),
    vec3(0.16, 0.20, 0.61),
    vec3(0.38, 0.79, 0.66)
    
  );

  vec3 background = vec3(1.0, 0.8, 0.8);
  vec3 foreground = vec3(0.);

  vec3 color = colors[int(sdf1 < thresh) + 2 * int(sdf2 < thresh)];

  // vec3 color = sdf1 < thresh ? foreground : background;

  // Add "dust"
  float noise = smoothstep(0.99, 1.0, rand2(uv));
  color = color * (1. - noise) + (1. - color) * noise;

  gl_FragColor = vec4(color, 1.0);
}
