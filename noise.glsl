float noise(const in vec2 pos, vec2 scale) 
{
    // classic value noise
    scale = floor(scale);
    vec2 p = mod(pos * floor(scale), scale);
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash(i);
    float b = hash(mod(i + vec2(1.0, 0.0), scale));
    float c = hash(mod(i + vec2(0.0, 1.0), scale));
    float d = hash(mod(i + vec2(1.0, 1.0), scale));

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// @note position must be premultiplied with the scale
float noise(const in vec2 pos, vec2 scale, const in mat2 rotation) 
{
     // classic value noise with rotation
    scale = floor(scale);
    vec2 p = mod(pos, scale);
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash(rotation * i);
    float b = hash(rotation * mod(i + vec2(1.0, 0.0), scale));
    float c = hash(rotation * mod(i + vec2(0.0, 1.0), scale));
    float d = hash(rotation * mod(i + vec2(1.0, 1.0), scale));

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

vec3 noised(const in vec2 pos, vec2 scale) 
{
    // value noise with derivative based on Inigo Quilez
    scale = floor(scale);
    vec2 p = mod(pos * scale, scale);
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    float a = hash(i);
    float b = hash(mod(i + vec2(1.0, 0.0), scale));
    float c = hash(mod(i + vec2(0.0, 1.0), scale));
    float d = hash(mod(i + vec2(1.0, 1.0), scale));
    
    vec2 f2 = f * f;
    vec2 u = f2 * f * (f * (f * 6.0 - 15.0) + 10.0); // = smootherStep
    vec2 du = 30.0 * f2 * (f * (f - 2.0) + 1.0);
    
    float abcd = a - b - c + d;
    float value = a + (b - a) * u.x + (c - a) * u.y + abcd * u.x * u.y;
    vec2 derivative = du * (u.yx * abcd + vec2(b, c) - a);
    return vec3(value, derivative);
}

// @note position must be premultiplied with the scale
vec3 noised(const in vec2 pos, vec2 scale, const in mat2 rotation) 
{
    // value noise with derivative based on Inigo Quilez
    scale = floor(scale);
    vec2 p = mod(pos, scale);
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    float a = hash(rotation * i);
    float b = hash(rotation * mod(i + vec2(1.0, 0.0), scale));
    float c = hash(rotation * mod(i + vec2(0.0, 1.0), scale));
    float d = hash(rotation * mod(i + vec2(1.0, 1.0), scale));
    
    vec2 f2 = f * f;
    vec2 u = f2 * f * (f * (f * 6.0 - 15.0) + 10.0); // = smootherStep
    vec2 du = 30.0 * f2 * (f * (f - 2.0) + 1.0);
    
    float abcd = a - b - c + d;
    float value = a + (b - a) * u.x + (c - a) * u.y + abcd * u.x * u.y;
    vec2 derivative = du * (u.yx * abcd + vec2(b, c) - a);
    return vec3(value, derivative);
}
