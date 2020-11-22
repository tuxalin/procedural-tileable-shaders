float luma(const in vec4 color) { return dot(vec3(0.2558, 0.6511, 0.0931), color.rgb); }		
vec2 sobel(sampler2D tex, vec2 uv, float spread)
{
    vec3 offset = vec3(1.0 / vec2(textureSize(tex, 0)), 0.0) * spread;
    vec2 grad = vec2(0.0);
    grad.x -= luma(texture(tex, uv - offset.xy)) * 1.0;
    grad.x -= luma(texture(tex, uv - offset.xz)) * 2.0;
    grad.x -= luma(texture(tex, uv + offset.xy * vec2(-1.0, 1.0))) * 1.0;
    grad.x += luma(texture(tex, uv + offset.xy * vec2(1.0, -1.0))) * 1.0;
    grad.x += luma(texture(tex, uv + offset.xz)) * 2.0;
    grad.x += luma(texture(tex, uv + offset.xy)) * 1.0;
    grad.y -= luma(texture(tex, uv - offset.xy)) * 1.0;
    grad.y -= luma(texture(tex, uv - offset.zy)) * 2.0;
    grad.y -= luma(texture(tex, uv + offset.xy * vec2(1.0, -1.0))) * 1.0;
    grad.y += luma(texture(tex, uv + offset.xy * vec2(-1.0, 1.0))) * 1.0;
    grad.y += luma(texture(tex, uv + offset.zy)) * 2.0;
    grad.y += luma(texture(tex, uv + offset.xy)) * 1.0;
    return grad;
}	
vec2 grayscaleSobel(sampler2D tex, vec2 uv, float spread)
{
    vec3 offset = vec3(1.0 / vec2(textureSize(tex, 0)), 0.0) * spread;
    vec2 grad = vec2(0.0);
    grad.x -= texture(tex, uv - offset.xy).r * 1.0;
    grad.x -= texture(tex, uv - offset.xz).r * 2.0;
    grad.x -= texture(tex, uv + offset.xy * vec2(-1.0, 1.0)).r * 1.0;
    grad.x += texture(tex, uv + offset.xy * vec2(1.0, -1.0)).r * 1.0;
    grad.x += texture(tex, uv + offset.xz).r * 2.0;
    grad.x += texture(tex, uv + offset.xy).r * 1.0;
    grad.y -= texture(tex, uv - offset.xy).r * 1.0;
    grad.y -= texture(tex, uv - offset.zy).r * 2.0;
    grad.y -= texture(tex, uv + offset.xy * vec2(1.0, -1.0)).r * 1.0;
    grad.y += texture(tex, uv + offset.xy * vec2(-1.0, 1.0)).r * 1.0;
    grad.y += texture(tex, uv + offset.zy).r * 2.0;
    grad.y += texture(tex, uv + offset.xy).r * 1.0;
    return grad;
}

// @param scale Number of tiles, must be  integer for tileable results, range: [2, inf]
// @param octaves Number of octaves for the fbm, range: [1, inf]
// @param shift Position shift for each octave, range: [0, inf]
// @param axialShift Axial or rotational shift for each octave, range: [0, inf]
// @param gain Gain for each octave, range: [0, 2], default: 0.5
// @param lacunarity Frequency of the fbm, must be integer for tileable results, range: [1, 32]
// @param slopeness Slope intensity of the derivatives, range: [0, 1], default: 0.5
// @param spread Spread for the derivatives, range: [1, 16], default: 1.0
// @param octaveFactor The octave intensity factor, the lower the more pronounced the lower octaves will be, range: [-1, 1], default: 0.0
vec3 fbmImage(sampler2D tex, vec2 uv, vec2 scale, uint octaves, float shift, float axialShift, float gain, float lacunarity, float slopeness, float spread, float octaveFactor)
{
    // based on derivative fbm by Inigo Quilez
    vec3 value = vec3(0.0);
    vec2 derivative = vec2(0.0);
    
    float amplitude = gain;
    vec2 frequency = floor(scale);
    vec2 offset = vec2(shift, 0.0);
    float angle = 0.0;
    axialShift = 3.1415926 * 0.5 * floor(float(octaves) * axialShift);
    octaveFactor = 1.0 + octaveFactor * 0.12;
    
    vec2 sinCos = vec2(sin(axialShift), cos(axialShift));
    mat2 rotate = mat2(sinCos.y, sinCos.x, sinCos.x, sinCos.y);

    vec2 p = uv * frequency;
    for (uint i = 0u; i < octaves; i++)
    {
        vec3 color = texture(tex, p).rgb;
        vec2 grad = sobel(tex, p, spread);
        derivative += grad;
        value += amplitude * color / (1.0 + mix(0.0, dot(derivative, derivative), slopeness));

        amplitude = pow(amplitude * gain, octaveFactor);
        p = (p * lacunarity + offset) * rotate;
        frequency *= lacunarity;
        angle += axialShift;
        offset *= rotate;
    }
    return value;
}

// @param scale Number of tiles, must be  integer for tileable results, range: [2, inf]
// @param octaves Number of octaves for the fbm, range: [1, inf]
// @param shift Position shift for each octave, range: [0, inf]
// @param axialShift Axial or rotational shift for each octave, range: [0, inf]
// @param gain Gain for each octave, range: [0, 2], default: 0.5
// @param lacunarity Frequency of the fbm, must be integer for tileable results, range: [1, 32]
// @param slopeness Slope intensity of the derivatives, range: [0, 1], default: 0.5
// @param spread Spread for the derivatives, range: [1, 16], default: 1.0
// @param octaveFactor The octave intensity factor, the lower the more pronounced the lower octaves will be, range: [-1, 1], default: 0.0
vec3 fbmGrayscaleImaged(sampler2D tex, vec2 uv, vec2 scale, uint octaves, float shift, float axialShift, float gain, float lacunarity, float slopeness, float spread, float octaveFactor)
{
    float value = 0.0;
    vec2 derivative = vec2(0.0);
    
    float amplitude = gain;
    vec2 frequency = floor(scale);
    vec2 offset = vec2(shift, 0.0);
    float angle = 0.0;
    axialShift = 3.1415926 * 0.5 * floor(float(octaves) * axialShift);
    octaveFactor = 1.0 + octaveFactor * 0.12;
    
    vec2 sinCos = vec2(sin(axialShift), cos(axialShift));
    mat2 rotate = mat2(sinCos.y, sinCos.x, sinCos.x, sinCos.y);

    vec2 p = uv * frequency;
    for (uint i = 0u; i < octaves; i++)
    {
        float lum = texture(tex, p).r;
        vec2 grad = grayscaleSobel(tex, p, spread);
        derivative += grad;
        value += amplitude * lum / (1.0 + mix(0.0, dot(derivative, derivative), slopeness));
        
        amplitude = pow(amplitude * gain, octaveFactor);
        p = (p * lacunarity + offset) * rotate;
        frequency *= lacunarity;
        angle += axialShift;
        offset *= rotate;
    }
    return vec3(value, derivative);
}
