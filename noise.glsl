float noise(const in vec2 pos, const in vec2 scale) 
{
    // classic value noise
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
