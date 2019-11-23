
float fbm(const in vec2 pos, const in vec2 scale, const int octaves, const float shift, const float axialShift, const in float gain, const in float lacunarity) 
{
    // classic fbm implementation
    float value = 0.0;
    float amplitude = 0.5;
    float angle = axialShift;
    vec2 frequency = floor(scale);
    
    vec2 p = pos * frequency;
    for (int i = 0; i < octaves; i++) 
    {
        float cosAngle = cos(angle); 
        float sinAngle = sin(angle); 
        mat2 rot = mat2(cosAngle, sinAngle,-sinAngle, cosAngle);
        value += amplitude * noise(p, frequency, rot);
        
        p = p * lacunarity + shift;
        frequency *= lacunarity;
        amplitude *= gain;
        angle += axialShift;
    }
    return value;
}

vec3 fbmVoronoi(const in vec2 pos, const in vec2 scale, const int octaves, const float shift, const float axialShift, const in float gain, const in float lacunarity, const in float jitter) 
{
    // classic fbm implementation with voronoi
    vec3 value = vec3(0.0);
    float amplitude = 0.5;
    vec2 frequency = floor(scale);
    float angle = axialShift;
    
    vec2 p = pos * frequency;
    for (int i = 0; i < octaves; i++) 
    {
        float cosAngle = cos(angle); 
        float sinAngle = sin(angle); 
        mat2 rot = mat2(cosAngle, sinAngle,-sinAngle, cosAngle);
        
        vec2 tilePos;
        value += amplitude * voronoi(p, frequency, jitter, rot, tilePos);
        
        p = p * lacunarity + shift;
        frequency *= lacunarity;
        amplitude *= gain;
        angle += axialShift;
    }
    return value;
}

vec3 fbmPerlin(const in vec2 pos, const in vec2 scale, const int octaves, const float shift, const float axialShift, const in float gain, const in float lacunarity, const in bool isMultiplyMode, const in float factor, const in float intensity) 
{
    // classic fbm implementation with perlin
    vec3 value = vec3(0.0);
    float amplitude = 0.5;
    vec2 frequency = floor(scale);
    float angle = axialShift;
    float n = 1.0;
    
    vec2 p = pos * frequency;
    for (int i = 0; i < octaves; i++) 
    {
        float cosAngle = cos(angle); 
        float sinAngle = sin(angle); 
        mat2 rot = mat2(cosAngle, sinAngle,-sinAngle, cosAngle);
        
        float pn = abs(perlinNoise(p, frequency, rot));
        n = isMultiplyMode ? n * pn : pn;
        n = pow(n, factor) * intensity;
        value += amplitude * n;
        
        p = p * lacunarity + shift;
        frequency *= lacunarity;
        amplitude *= gain;
        angle += axialShift;
    }
    return value;
}

float fbmd(const in vec2 pos, const in vec2 scale, const int octaves, const float shift, const in float gain, const in float lacunarity, const in float intensity) 
{
    // fbm implementation based on Inigo Quilez
    float value = 0.0;
    vec2 derivative = vec2(0.0);
    float amplitude = 0.5;
    vec2 frequency = floor(scale);
    
    mat2 rot = mat2(0.8,-0.6,0.6,0.8);
    vec2 p = pos * frequency;
    for (int i = 0; i < octaves; i++) 
    {
        vec3 n = noised(p, frequency, rot);
        derivative += n.yz;
        value += amplitude * n.x / (1.0 + mix(0.0, dot(derivative, derivative), intensity));
        
        p = p * lacunarity + shift;
        frequency *= lacunarity;
        amplitude *= gain;
        
        rot *= rot;
    }
    return value;
}
