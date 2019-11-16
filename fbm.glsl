float fbmNoise(const in vec2 pos, const in vec2 scale, const in float angle) 
{
    // based on classic value noise
    vec2 i = floor(pos);
    vec2 f = fract(pos);

    float cosAngle = cos(angle); 
    float sinAngle = sin(angle); 
    mat2 rot = mat2(cosAngle, sinAngle,
                   -sinAngle, cosAngle);
    
    float a = hash(rot * i);
    float b = hash(rot * mod(i + vec2(1.0, 0.0), scale));
    float c = hash(rot * mod(i + vec2(0.0, 1.0), scale));
    float d = hash(rot * mod(i + vec2(1.0, 1.0), scale));

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(const in vec2 pos, const in vec2 scale, const int octaves, const float shift, const float axialShift) 
{
    // classic fbm implementation
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 0.0;
    float angle = axialShift;
    
    vec2 s = floor(scale);
    vec2 p = mod(pos * s, s);
    for (int i = 0; i < 15; i++) 
    {
        value += amplitude * fbmNoise(p, s, angle);
        
        p = p * 2.0 + shift;
        s *= 2.0;
        p = mod(p, s);
        amplitude *= 0.5;
        angle += axialShift;
    }
    return value;
}
