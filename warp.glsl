
float fbmWarp(const in vec2 pos, const in vec2 scale, const in vec2 factors, const int octaves, const in vec4 shifts, const in float gain, const in float lacunarity, const in float slopeness, 
              out vec2 q, out vec2 r) 
{
    // domain warping with factal sum value noise

    float qfactor = factors.x;
    float rfactor = factors.y;
    
    q.x = fbmd(pos, scale, octaves, 0.0, gain, lacunarity, slopeness);
    q.y = fbmd(pos, scale, octaves, shifts.x, gain, lacunarity, slopeness);
    
    vec2 np = pos + qfactor * q;
    r.x = fbmd(np, scale, octaves, shifts.y, gain, lacunarity, slopeness);
    r.y = fbmd(np, scale, octaves, shifts.z, gain, lacunarity, slopeness);
    
    return fbmd(pos + r * rfactor, scale, octaves, shifts.w, gain, lacunarity, slopeness);
}

float curlWarp(const in vec2 pos, const in vec2 scale, const vec2 factors, const in vec4 seeds, const in float curl,
               out vec2 q, out vec2 r)
{
    float qfactor = factors.x;
    float rfactor = factors.y;
    vec2 curlFactor = vec2(1.0, -1.0) * vec2(curl, 1.0 - curl);
    
    vec2 n = gradientNoised(pos, scale).zy * curlFactor;
    q.x = n.x + n.y;
    n = gradientNoised(pos + hash2d(seeds.x), scale).zy * curlFactor;
    q.x = n.x + n.y;
    
    vec2 np = pos + qfactor * q;
    n = gradientNoised(np + hash2d(seeds.y), scale).zy * curlFactor;
    r.x = n.x + n.y;
    n = gradientNoised(np + hash2d(seeds.z), scale).zy * curlFactor;
    r.y = n.x + n.y;

    return gradientNoise(pos + r * rfactor + hash2d(seeds.w), scale);
}