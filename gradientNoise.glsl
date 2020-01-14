float gradientNoise(const in vec2 pos, vec2 scale) 
{
    // classic gradient noise
    scale = floor(scale);
    vec2 p = mod(pos * scale, scale);
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    vec2 a = hash2d(i);
    vec2 b = hash2d(mod(i + vec2(1.0, 0.0), scale));
    vec2 c = hash2d(mod(i + vec2(0.0, 1.0), scale));
    vec2 d = hash2d(mod(i + vec2(1.0, 1.0), scale));
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    float ab = mix(dot(a, f - vec2(0.0, 0.0)), dot(b, f - vec2(1.0, 0.0)), u.x);
    float cd = mix(dot(c, f - vec2(0.0, 1.0)), dot(d, f - vec2(1.0, 1.0)), u.x);
    return 2.0 * mix(ab, cd, u.y);
}

// @note position must be premultiplied with the scale
float gradientNoise(const in vec2 pos, vec2 scale, const in mat2 rotation) 
{
    // classic gradient noise
    scale = floor(scale);
    vec2 p = mod(pos, scale);
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    vec2 a = rotation * hash2d(i);
    vec2 b = rotation * hash2d(mod(i + vec2(1.0, 0.0), scale));
    vec2 c = rotation * hash2d(mod(i + vec2(0.0, 1.0), scale));
    vec2 d = rotation * hash2d(mod(i + vec2(1.0, 1.0), scale));
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    float ab = mix(dot(a, f - vec2(0.0, 0.0)), dot(b, f - vec2(1.0, 0.0)), u.x);
    float cd = mix(dot(c, f - vec2(0.0, 1.0)), dot(d, f - vec2(1.0, 1.0)), u.x);
    return 2.0 * mix(ab, cd, u.y);
}

float gradientNoise(const in vec2 pos, vec2 scale, const in float rotation) 
{
    float sinR = sin(rotation);
    float cosR = cos(rotation);
    return gradientNoise(pos, scale, mat2(cosR, sinR, sinR, cosR));
}

vec3 gradientNoised(const in vec2 pos, vec2 scale)
{
    // classic gradient noise with derivatives based on Inigo Quilez
    scale = floor(scale);
    vec2 p = mod(pos * scale, scale);
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    vec2 a = hash2d(i);
    vec2 b = hash2d(mod(i + vec2(1.0, 0.0), scale));
    vec2 c = hash2d(mod(i + vec2(0.0, 1.0), scale));
    vec2 d = hash2d(mod(i + vec2(1.0, 1.0), scale));

    float va = dot(a, f);
    float vb = dot(b, f - vec2(1.0, 0.0));
    float vc = dot(c, f - vec2(0.0, 1.0));
    float vd = dot(d, f - vec2(1.0, 1.0));

    vec2 f2 = f * f;
    vec2 u = f2 * f * (f * (f * 6.0 - 15.0) + 10.0); // = smootherstep
    vec2 du = 30.0 * f2 * (f * (f - 2.0) + 1.0);

    float value = va + u.x * (vb - va) + u.y * (vc - va) + u.x * u.y * (va - vb - vc + vd);
    vec2 dxdy = a + u.x * (b-a) + u.y * (c - a) + u.x * u.y * (a - b - c + d);
    dxdy += du * (u.yx * (va - vb - vc + vd) + vec2(vb, vc) - va);
    return vec3(value * 0.5 + 0.5, dxdy);
}
