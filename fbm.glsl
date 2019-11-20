float fbmNoise(const in vec2 pos, const in vec2 scale, const in float angle) 
{
    // based on classic value noise
    vec2 p = mod(pos, scale);
    vec2 i = floor(p);
    vec2 f = fract(p);

    float cosAngle = cos(angle); 
    float sinAngle = sin(angle); 
    mat2 rot = mat2(cosAngle, sinAngle,-sinAngle, cosAngle);
    
    float a = hash(rot * i);
    float b = hash(rot * mod(i + vec2(1.0, 0.0), scale));
    float c = hash(rot * mod(i + vec2(0.0, 1.0), scale));
    float d = hash(rot * mod(i + vec2(1.0, 1.0), scale));

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(const in vec2 pos, const in vec2 scale, const int octaves, const float shift, const float axialShift, const in float gain, const in float lacunarity) 
{
    // classic fbm implementation
    float value = 0.0;
    float amplitude = 0.5;
    float angle = axialShift;
    vec2 frequency = floor(scale);
    
    vec2 p = mod(pos * frequency, frequency);
    for (int i = 0; i < octaves; i++) 
    {
        value += amplitude * fbmNoise(p, frequency, angle);
        
        p = p * lacunarity + shift;
        frequency *= lacunarity;
        amplitude *= gain;
        angle += axialShift;
    }
    return value;
}

vec3 fbmVoronoi(const in vec2 pos, const in vec2 scale, const int octaves, const float shift, const in float gain, const in float lacunarity, const in float jitter) 
{
    // classic fbm implementation with voronoi
    vec3 value = vec3(0.0);
    float amplitude = 0.5;
    vec2 frequency = floor(scale);
    
    vec2 p = mod(pos * frequency, frequency);
    for (int i = 0; i < octaves; i++) 
    {
        vec2 tilePos;
        value += amplitude * voronoi(p, frequency, jitter, tilePos);
        
        p = p * lacunarity + shift;
        frequency *= lacunarity;
        amplitude *= gain;
    }
    return value;
}
