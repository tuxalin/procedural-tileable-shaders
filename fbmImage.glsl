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

// based on derivative fbm by Inigo Quilez
vec3 fbmImage(sampler2D tex, vec2 uv, vec2 scale, uint octaves, float shift, float axialShift, float gain, float intensity, float spread, uint lacunarity)
{
    vec3 value = vec3(0.0);
    vec2 derivative = vec2(0.0);
    
    float amplitude = 0.5;
    vec2 frequency = floor(scale);
    float angle = 0.0;
    axialShift =  3.1415926 * 0.5 * floor(float(octaves) * axialShift);
    float lacunarityf = float(lacunarity);

    vec2 p = uv * frequency;
    for (uint i = 0u; i < octaves; i++)
    {
        vec2 sinCos = vec2(sin(angle), cos(angle));
        mat2 rotate = mat2(sinCos.y, -sinCos.x, sinCos.x, sinCos.y); 

        vec2 coord = rotate * p;
        vec3 color = texture(tex, coord).rgb;
        vec2 grad = sobel(tex, coord, spread);
        derivative += grad;
        value += amplitude * color / (1.0 + mix(0.0, dot(derivative, derivative), intensity));

        amplitude *= gain;
        p = p * lacunarityf + shift;
        frequency *= lacunarityf;
        angle += axialShift;
    }
    return value;
}

vec3 fbmGrayscaleImaged(sampler2D tex, vec2 uv, vec2 scale, uint octaves, float shift, float axialShift, float gain, float intensity, float spread, uint lacunarity)
{
    float value = 0.0;
    vec2 derivative = vec2(0.0);
    
    float amplitude = 0.5;
    vec2 frequency = floor(scale);
    float angle = 0.0;
    axialShift =  3.1415926 * 0.5 * floor(float(octaves) * axialShift);
    float lacunarityf = float(lacunarity);

    vec2 p = uv * frequency;
    for (uint i = 0u; i < octaves; i++)
    {
        vec2 sinCos = vec2(sin(angle), cos(angle));
        mat2 rotate = mat2(sinCos.y, -sinCos.x, sinCos.x, sinCos.y); 

        vec2 coord = rotate * p;
        float lum = texture(tex, coord).r;
        vec2 grad = grayscaleSobel(tex, coord, spread);
        derivative += grad;
        value += amplitude * lum / (1.0 + mix(0.0, dot(derivative, derivative), intensity));

        amplitude *= gain;
        p = p * lacunarityf + shift;
        frequency *= lacunarityf;
        angle += axialShift;
    }
    return vec3(value, derivative);
}