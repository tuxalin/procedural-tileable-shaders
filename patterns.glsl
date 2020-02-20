float triangleWave(float x) 
{
    const float pi = 3.141592;
    float t = x / (pi * 2.0) + pi / 4.0;
    return abs(fract(t) * 2.0 - 1.0) * 2.0 - 1.0;
}

float wavePattern(const in vec2 pos, vec2 scale, const in float width, const in float smoothness, const in float amplitude, const in float interpolate)
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

float crossPattern(const in vec2 pos, vec2 scale, const in vec2 smoothness)
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

float stairsPattern(const in vec2 pos, vec2 scale, float width, float smoothness, float distance)   
{
    vec2 p = pos * scale;
    vec2 f = fract(p);
    
    vec2 m = floor(mod(p, vec2(2.0)));
    float d = mix(f.x, f.y, abs(m.x - m.y));
    d = mix(d, abs(d * 2.0 - 1.0), distance);
    
    return 1.0 - smoothstep(max(width - smoothness, 0.0), width, d);        
}
