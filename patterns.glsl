vec3 checkerboard(const in vec2 pos, const in vec2 scale, const in vec2 smoothness)
{
    // based on filtering the checkerboard by Inigo Quilez 
    vec2 numTiles = floor(scale); 
    vec2 p = pos * numTiles * 2.0;
    vec2 tile = mod(floor(p), numTiles * 2.0);
    
    vec2 w = max(smoothness, vec2(0.001));
    // box filter using triangular signal
    vec2 s1 = abs(fract((p - 0.5 * w) / 2.0) - 0.5);
    vec2 s2 = abs(fract((p + 0.5 * w) / 2.0) - 0.5);
    vec2 i = 2.0 * (s1 - s2) / w;
    float d = 0.5 - 0.5 * i.x * i.y; // xor pattern
    return vec3(d, tile);
}

vec3 checkerboard45(const in vec2 pos, const in vec2 scale, const in vec2 smoothness)
{
    // based on filtering the checkerboard by Inigo Quilez 
    const float sqrtOfTwo = 1.41421356237;
    
    vec2 numTiles = floor(scale); 
    vec2 p = pos * numTiles * 2.0;
    
    const mat2 rotate45 = mat2(0.70710678119, 0.70710678119, -0.70710678119, 0.70710678119);
    p *= 1.0 / sqrtOfTwo;
    p.x += sqrtOfTwo * 0.5;
    p = p * rotate45;

    vec2 w = max(smoothness, vec2(0.001));
    // box filter using triangular signal
    vec2 s1 = abs(fract((p - 0.5 * w) / 2.0) - 0.5);
    vec2 s2 = abs(fract((p + 0.5 * w) / 2.0) - 0.5);
    vec2 i = 2.0 * (s1 - s2) / w;
    float d = 0.5 - 0.5 * i.x * i.y; // xor pattern
    vec2 tile = mod(floor(p), numTiles);
    return vec3(d, tile);
}

float triangleWave(float x) 
{
    const float pi = 3.141592;
    float t = x / (pi * 2.0) + pi / 4.0;
    return abs(fract(t) * 2.0 - 1.0) * 2.0 - 1.0;
}

float wavePattern(vec2 pos, vec2 scale, float width, float smoothness, float amplitude, float interpolate)
{
    scale = floor(scale);
    const float pi = 3.141592;
    vec2 p;
    p.x = pos.x * pi * scale.x;
    p.y = pos.y * scale.y;
    
    float sy = p.y + amplitude * mix(triangleWave(p.x), sin(p.x), interpolate);
    float t = triangleWave(sy * scale.y * pi * 0.25);
    return 1.0 - smoothstep(max(width - smoothness, 0.0), width, t * 0.5 + 0.5);
}

float crossPattern(vec2 pos, vec2 scale, vec2 smoothness)
{
    scale = floor(scale);
    vec2 p = pos * scale;
    
    const float N = 3.0;
    vec2 w = max(smoothness, vec2(0.001));
    vec2 halfW = 0.5 * w;
    vec2 a = p + halfW;                        
    vec2 b = p - halfW;  
    
    vec2 x = floor(a) + min(fract(a) * N, 1.0) - floor(b) - min(fract(b) * N, 1.0);
    vec2 i = x / (N * w);
    return 1.0 - i.x - i.y + 2.0 * i.x * i.y;
}

float stairsPattern(vec2 pos, vec2 scale, float width, float smoothness, float distance)   
{
    vec2 p = pos * scale;
    vec2 f = fract(p);
    
    vec2 m = floor(mod(p, vec2(2.0)));
    float d = mix(f.x, f.y, abs(m.x - m.y));
    d = mix(d, abs(d * 2.0 - 1.0), distance);
    
    return 1.0 - smoothstep(max(width - smoothness, 0.0), width, d);        
}

float sdfLens(vec2 p, float width, float height)
{
    // Vesica SDF based on Inigo Quilez
    float d = height / width - width / 4.0;
    float r = width / 2.0 + d;
    
    p = abs(p);

    float b = sqrt(r * r - d * d);
    vec4 par = p.xyxy - vec4(0.0, b, -d, 0.0);
    return (par.y * d > p.x * b) ? length(par.xy) : length(par.zw) - r;
}

vec3 tileWeave(vec2 pos, vec2 scale, float count, float width, float smoothness)
{
    vec2 i = floor(pos * scale);    
    float c = mod(i.x + i.y, 2.0);
    
    vec2 p = fract(pos.st * scale);
    p = mix(p.st, p.ts, c);
    p = fract(p * vec2(count, 1.0));
    
    width *= 2.0;
    p = p * 2.0 - 1.0;
    float d = sdfLens(p, width, 1.0);
    vec2 grad = vec2(dFdx(d), dFdy(d));

    float s = 1.0 - smoothstep(0.0, dot(abs(grad), vec2(1.0)) + smoothness, -d);
    return vec3(s, normalize(grad) * smoothstep(1.0, 0.99, s) * smoothstep(0.0, 0.01, s)); 
}

float sdfCapsule(vec2 p, float radiusA, float radiusB, float height)
{
    // Capsule SDF based on Inigo Quilez
    p.x = abs(p.x);
    p.y += height * 0.5;
    
    float b = (radiusA - radiusB) / height;
    vec2 c = vec2(sqrt(1.0 - b * b), b);
    vec3 mnk = vec3(c.x, p.x, c.x) * p.xxy + vec3(c.y, p.y, -c.y) * p.yyx;
    
    if( mnk.z < 0.0   ) 
        return sqrt(mnk.y) - radiusA;
    else if(mnk.z > c.x * height) 
        return sqrt(mnk.y + height * height - 2.0 * height * p.y) - radiusB;
    return mnk.x - radiusA;
}
vec3 tileWeave(vec2 pos, vec2 scale, float count, vec2 width, float smoothness)
{
    vec2 i = floor(pos * scale);    
    float c = mod(i.x + i.y, 2.0);
    
    vec2 p = fract(pos.st * scale);
    p = mix(p.st, p.ts, c);
    p = fract(p * vec2(count, 1.0));
    
    p = p * 2.0 - 1.0;
    float d = sdfCapsule(p, width.x, width.y, 1.0 - max(width.x, width.y) * 0.75);
    vec2 grad = vec2(dFdx(d), dFdy(d));

    float s = 1.0 - smoothstep(0.0, dot(abs(grad), vec2(1.0)) + smoothness, -d);
    return vec3(s, normalize(grad) * smoothstep(1.0, 0.99, s) * smoothstep(0.0, 0.01, s)); 
}
