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

const int N = 4;
const int N_COLORS = 5;
const int N_STRIPES = 2;

vec3 colors[] = vec3[N_COLORS](
  vec3(0.38, 0.51, 0.58),
  vec3(0.59, 0.54, 0.48),
  vec3(0.86, 0.68, 0.42),
  vec3(0.81, 0.60, 0.44),
  vec3(0.76, 0.81, 0.49)
);

float lp_norm(vec2 v, float p) {
  if (p > 30.) {
    return max(abs(v.x), abs(v.y));
  } else {
    return pow(pow(abs(v.x), p) + pow(abs(v.y), p), 1./p);
  }
}

float sin01(float x) {
  return (sin(x) + 0.5) / 2.;
}

void main() {
  float time = iGlobalTime * 1.0;
  vec2 uv = (gl_FragCoord.xy / iResolution.xy);
  
  float stripe = 0.;
  stripe = floor(fract((gl_FragCoord.x + gl_FragCoord.y) / 10.) * float(N_STRIPES));
  float stripeWiggle = stripe * 0.001;

  vec2 speeds[N];
  for (int i = 0; i < N; i++) {
    speeds[i] = vec2(rand1(0.03 + float(i) + stripeWiggle) - 0.5, rand1(0.04 + float(i) + stripeWiggle) - 0.5);
  }


  vec2 centers[N];
  for (int i = 0; i < N; i++) {
    centers[i] = vec2(rand1(0.01 + float(i) + stripeWiggle), rand1(0.02 + float(i)) + stripeWiggle);
    centers[i] += time * speeds[i] * 0.1;
    centers[i] = fract(centers[i]);
  }

  // Use a time-varying Lp norm for each cell
  float ps[N];
  for (int i = 0; i < N; i++) {
    float cycleTime = mix(2., 5., rand1(0.06 + float(i) + stripeWiggle));
    float phase = rand1(0.05 + float(i) + stripeWiggle);
    ps[i] = mix(1.5, 3.0, sin01(phase + time / cycleTime));
  }

  float sdfs[N];
  for (int i = 0; i < N; i++) {
    sdfs[i] = 1000.;

    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        sdfs[i] = min(sdfs[i], lp_norm(vec2(dx, dy) + uv - centers[i], ps[i]));
      }
    }
  }

  int minIndex = 0;
  float minDist = 1000.0;
  for (int i = 0; i < N; i++) {
    float dist = sdfs[i];
    if (dist < minDist) {
      minDist = dist;
      minIndex = i;
    }
  }

  vec3 color = colors[(int(stripe) + minIndex) % N_COLORS];

  // if (stripe == 0.) {
  //   color = vec3(0.,0.,0.);
  // }

  gl_FragColor = vec4(color, 1.0);
}
