#define MAXDIST 20.
#define EPS 0.001

float rand1(float x){
  return fract(sin(x * 88.233) * 43758.5453);
}

float rand2(vec2 co){
  return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
}

float rand22(vec2 co) {
  return rand1(rand2(co));
}

float opSmoothUnion( float d1, float d2, float k )
{
    k *= 4.0;
    float h = max(k-abs(d1-d2),0.0);
    return min(d1, d2) - h*h*0.25/k;
}

float sdScene(vec3 p, float time) {
  // vec3 offset =vec3(5., 5., 5.) / 2.;
  // p = mod(p + offset, vec3(5., 5., 5.));
  // p -= offset;

  float d = MAXDIST;
  float s1 = length(p - vec3(sin(time * 1.33), 0., 0.)) - 1.;
  float s2 = length(p - vec3(-1.5, 1.2 * sin(time * 1.2512), 0.)) - 1.;

  d = opSmoothUnion(s1, s2, mix(0.3, 0.5, sin(time * 2.)));
  return d;
}

vec3 getNormal(vec3 p, float time) {
  vec2 e = vec2(EPS, 0.);
  return normalize(
    vec3(sdScene(p, time))
    - vec3(
      sdScene(p - e.xyy, time),
      sdScene(p - e.yxy, time),
      sdScene(p - e.yyx, time)
    )
  );
}

vec3 getEnvironment(vec3 rd) {
    return texture(iChannel0, rd).xyz;
}


// ray origin, ray direction
vec4 trace(vec3 ro, vec3 rd, float n, float time) {
  vec3 p = ro;
  float d = 0.;

  rd = normalize(rd);

  int bounce = 0;

  float i;
  for (i = 0.; i < n; i++) {
    float cd = sdScene(p, time);
    if (cd <= EPS) {
      if (bounce <= 0) break;
      vec3 norm = getNormal(p, time);
      rd = reflect(rd, norm);
      p += EPS * norm;
      d += EPS;
      bounce -= 1;
    }
    p += cd * rd;
    d += cd;
    if (d >= MAXDIST) {
      return vec4(rd, -1.);
    }
  }

  if (i == n) {
    return vec4(rd, -1.);
  } else {
    return vec4(rd, length(p - ro));
  }
}

vec3 drawImage(vec2 uv, float ior) {
float time = iTime * 1.0;
  //vec3 ro = vec3(0., 2.5 * cos(time * 0.1), -2.5 * sin(time * 0.1));
  vec3 ro = vec3(0., 0., -2.5);
  uv += (vec2(rand22(uv + time), rand22(uv + 100. + time)) - 1.) * 0.001;
  vec3 rd = vec3(uv, 1.);

  vec4 traceResult = trace(ro, rd, 120., time);
  float d = traceResult[3];
  rd = traceResult.xyz;
  vec3 target = ro + rd * d;
  vec3 normal = getNormal(target, time);

  vec3 lighto = vec3(3., sin(time), 0.);
  vec3 lightdir = normalize(ro - lighto);

  vec3 c = vec3((2. - d));

  if (d == -1.) {
    // c = vec3(0.3, 0., 0.3);
    c = vec3(0.0, 0., 0.0);
    c = getEnvironment(rd);
  } else {
    c = normal * 0.5 + 0.5;
    float angle = atan(normal.y, normal.x);
    vec3 reflection = reflect(rd, normal);
    vec3 refraction = refract(rd, normal, ior);
    c = getEnvironment(refraction) * 0.3;
    c += getEnvironment(reflection) * 0.6;
    
    // c = vec3(sin(angle), cos(angle), -normal.z);
    // c = vec3(1., 0., 0.);
    // c *= dot(normal, lightdir);
  }
  return c;
}

void mainImage(out vec4 fragColor, in vec2 fragCoordinates) {
  vec2 uv = (2. * gl_FragCoord.xy - iResolution.xy)
    / min(iResolution.x, iResolution.y);
  vec3 c = vec3(0.);
  c.r = drawImage(uv, 0.5).r;
  c.g = drawImage(uv, 0.6).g;
  c.b = drawImage(uv, 0.7).b;

  fragColor = vec4(c, 1.0);
}