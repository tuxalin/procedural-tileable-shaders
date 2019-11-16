vec3 checkers45(const in vec2 pos, const in vec2 scale, const in vec2 smoothness)
{
    // based on filtering the checkerboard by Inigo Quilez 
    vec2 p = pos * floor(scale) * 2.0;
    vec2 tile = floor(p);
    
    vec2 w = smoothness;
    // box filter using triangular signal
    vec2 s1 = abs(fract((p - 0.5 * w) / 2.0) - 0.5);
    vec2 s2 = abs(fract((p + 0.5 * w) / 2.0) - 0.5);
    vec2 i = 2.0 * (s1 - s2) / w;
    float d = 0.5 - 0.5 * i.x * i.y; // xor pattern
    return vec3(d, tile);
}

vec3 checkers45(const in vec2 pos, const in vec2 scale, const in vec2 smoothness)
{
    // based on filtering the checkerboard by Inigo Quilez 
    vec2 p = pos * floor(scale) * 2.0;
    vec2 tile = floor(p);
    
    const float angle = 3.14152 / 4.0;
    const float cosAngle = cos(angle);
    const float sinAngle = sin(angle);

    p *= 1.0 / sqrt(2.0);
    p = p * mat2(cosAngle, sinAngle, -sinAngle, cosAngle);
    tile = mod(floor(p), scale);
    
    vec2 w = smoothness;
    // box filter using triangular signal
    vec2 s1 = abs(fract((p - 0.5 * w) / 2.0) - 0.5);
    vec2 s2 = abs(fract((p + 0.5 * w) / 2.0) - 0.5);
    vec2 i = 2.0 * (s1 - s2) / w;
    float d = 0.5 - 0.5 * i.x * i.y; // xor pattern
    return vec3(d, tile);
}
