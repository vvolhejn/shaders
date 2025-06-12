// See e.g. https://10print.org/

// A single iteration of Bob Jenkins' One-At-A-Time hashing algorithm.
int hash( int x ) {
    x += ( x << 10u );
    x ^= ( x >>  6u );
    x += ( x <<  3u );
    x ^= ( x >> 11u );
    x += ( x << 15u );
    return x;
}

const float N = 10.;

void main() {
  float time = iGlobalTime * 1.0;
  vec2 uv = (gl_FragCoord.xy / iResolution.xy) * N;
  vec2 uv1 = fract(uv);
  vec2 gridPos = uv - uv1;

  int val = (hash(int(gridPos.x * N + gridPos.y + 100. * floor(time * 0.5))) % 2);

  float d;

  if (val == 1) {
    d = abs(uv1.x - uv1.y);
  } else {
    d = abs(uv1.x + uv1.y - 1.0);
  }

  

  vec3 color = vec3(step(0.1, d));
  gl_FragColor = vec4(color, 1.0);
}
