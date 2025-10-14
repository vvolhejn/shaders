// TODO: Make GLSL-Preview compatible
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
  float s1 = length(p - vec3(1., 0., 0.)) - 1.;
  float s2 = length(p - vec3(-1.5, 0.4, 0.)) - 1.;

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

// ray origin, ray direction
float trace(vec3 ro, vec3 rd, float n, float time) {
  vec3 p = ro;
  float d = 0.;

  rd = normalize(rd);

  int bounce = 0;

  float i;
  for (i = 0.; i < n; i++) {
    float cd = sdScene(p, time);
    if (cd <= EPS) {
      if (bounce > 0) {
        vec3 norm = getNormal(p, time);
        rd = reflect(rd, norm);
        p += 0.5 * norm;
        bounce -= 1;
      } else {
        break;
      }
    }
    p += cd * rd;
    d += cd;
    if (d >= MAXDIST) {
      return -1.;
    }
  }

  if (i == n) {
    return -1.;
  } else {
    return length(p - ro);
  }
}

void main() {
  float time = iGlobalTime * 1.0;
  vec2 uv = (2. * gl_FragCoord.xy - iResolution.xy)
    / min(iResolution.x, iResolution.y);
  
  vec3 ro = vec3(0., 0., -3.);
  uv += (vec2(rand22(uv + time), rand22(uv + 100. + time)) - 1.) * 0.001;
  vec3 rd = vec3(uv, 1.);

  float d = trace(ro, rd, 120., time);
  vec3 target = ro + rd * d;
  vec3 normal = getNormal(target, time);

  vec3 lighto = vec3(3., sin(time), 0.);
  vec3 lightdir = normalize(ro - lighto);

  vec3 c = vec3((2. - d));

  if (d == -1.) {
    // c = vec3(0.3, 0., 0.3);
    c = vec3(0.0, 0., 0.0);
  } else {
    c = normal * 0.5 + 0.5;
    float angle = atan(normal.y, normal.x);
    // c = vec3(sin(angle), cos(angle), -normal.z);
    // c = vec3(1., 0., 0.);
    // c *= dot(normal, lightdir);
  }

  gl_FragColor = vec4(c, 1.0);
}