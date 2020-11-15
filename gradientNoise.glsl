// 2D Gradient noise.
// @param scale Number of tiles, must be  integer for tileable results, range: [2, inf]
// @return Value of the noise, range: [-1, 1]
float gradientNoise(vec2 pos, vec2 scale, float seed) 
{
    pos *= scale;
    vec4 i = floor(pos).xyxy + vec2(0.0, 1.0).xxyy;
    vec4 f = (pos.xyxy - i.xyxy) - vec2(0.0, 1.0).xxyy;
    i = mod(i, scale.xyxy) + seed;

    vec4 hash0, hash1;
    smultiHash2D(i, hash0, hash1);
    vec2 a = vec2(hash0.x, hash1.x);
    vec2 b = vec2(hash0.y, hash1.y);
    vec2 c = vec2(hash0.z, hash1.z);
    vec2 d = vec2(hash0.w, hash1.w);
    
    vec2 u = noiseInterpolate(f.xy);
    vec2 g0 = vec2(dot(a, f.xy), dot(c, f.xw));
    vec2 g1 = vec2(dot(b, f.zy), dot(d, f.zw));
    vec2 g = mix(g0, g1, u.x);
    return 1.7 * mix(g.x, g.y, u.y);
}

// 2D Gradient noise with gradients transform (i.e. can be used to rotate the gradients).
// @param scale Number of tiles, must be  integer for tileable results, range: [2, inf]
// @param transform Transform matrix for the noise gradients.
// @return Value of the noise, range: [-1, 1]
float gradientNoise(vec2 pos, vec2 scale, mat2 transform, float seed) 
{
    pos *= scale;
    vec4 i = floor(pos).xyxy + vec2(0.0, 1.0).xxyy;
    vec4 f = (pos.xyxy - i.xyxy) - vec2(0.0, 1.0).xxyy;
    i = mod(i, scale.xyxy) + seed;
    
    vec4 hash0, hash1;
    smultiHash2D(i, hash0, hash1);
    vec2 a = transform * vec2(hash0.x, hash1.x);
    vec2 b = transform * vec2(hash0.y, hash1.y);
    vec2 c = transform * vec2(hash0.z, hash1.z);
    vec2 d = transform * vec2(hash0.w, hash1.w);
    
    vec2 u = noiseInterpolate(f.xy);
    vec2 g0 = vec2(dot(a, f.xy), dot(c, f.xw));
    vec2 g1 = vec2(dot(b, f.zy), dot(d, f.zw));
    vec2 g = mix(g0, g1, u.x);
    return 1.7 * mix(g.x, g.y, u.y);
}

// 2D Gradient noise with derivatives.
// @param scale Number of tiles, must be  integer for tileable results, range: [2, inf]
// @return x = value of the noise, yz = derivative of the noise, range: [-1, 1]
vec3 gradientNoised(vec2 pos, vec2 scale, float seed) 
{
    // gradient noise with derivatives based on Inigo Quilez
    pos *= scale;
    vec4 i = floor(pos).xyxy + vec2(0.0, 1.0).xxyy;
    vec4 f = (pos.xyxy - i.xyxy) - vec2(0.0, 1.0).xxyy;
    i = mod(i, scale.xyxy) + seed;
    
    vec4 hash0, hash1;
    smultiHash2D(i, hash0, hash1);
    vec2 a = vec2(hash0.x, hash1.x);
    vec2 b = vec2(hash0.y, hash1.y);
    vec2 c = vec2(hash0.z, hash1.z);
    vec2 d = vec2(hash0.w, hash1.w);

    float va = dot(a, f.xy);
    float vb = dot(b, f.zy);
    float vc = dot(c, f.xw);
    float vd = dot(d, f.zw);

    vec4 udu = noiseInterpolateDu(f.xy);
    vec2 u = udu.xy;

    float value = va + u.x * (vb - va) + u.y * (vc - va) + u.x * u.y * (va - vb - vc + vd);
    vec2 dxdy = a + u.x * (b-a) + u.y * (c - a) + u.x * u.y * (a - b - c + d);
    dxdy += udu.zw * (u.yx * (va - vb - vc + vd) + vec2(vb, vc) - va);
    return vec3(value * 1.7, dxdy);
}

// 2D Gradient noise with gradients transform (i.e. can be used to rotate the gradients) and derivatives.
// @param scale Number of tiles, must be  integer for tileable results, range: [2, inf]
// @param transform Transform matrix for the noise gradients.
// @return x = value of the noise, yz = derivative of the noise, range: [-1, 1]
vec3 gradientNoised(vec2 pos, vec2 scale, mat2 transform, float seed) 
{
    // gradient noise with derivatives based on Inigo Quilez
    pos *= scale;
    vec4 i = floor(pos).xyxy + vec2(0.0, 1.0).xxyy;
    vec4 f = (pos.xyxy - i.xyxy) - vec2(0.0, 1.0).xxyy;
    i = mod(i, scale.xyxy) + seed;
    
    vec4 hash0, hash1;
    smultiHash2D(i, hash0, hash1);
    vec2 a = transform * vec2(hash0.x, hash1.x);
    vec2 b = transform * vec2(hash0.y, hash1.y);
    vec2 c = transform * vec2(hash0.z, hash1.z);
    vec2 d = transform * vec2(hash0.w, hash1.w);

    float va = dot(a, f.xy);
    float vb = dot(b, f.zy);
    float vc = dot(c, f.xw);
    float vd = dot(d, f.zw);

    vec4 udu = noiseInterpolateDu(f.xy);
    vec2 u = udu.xy;

    float value = va + u.x * (vb - va) + u.y * (vc - va) + u.x * u.y * (va - vb - vc + vd);
    vec2 dxdy = a + u.x * (b-a) + u.y * (c - a) + u.x * u.y * (a - b - c + d);
    dxdy += udu.zw * (u.yx * (va - vb - vc + vd) + vec2(vb, vc) - va);
    return vec3(value * 1.7, dxdy);
}

// @param scale Number of tiles, must be  integer for tileable results, range: [2, inf]
// @param rotation Rotation for the noise gradients, useful to animate flow, range: [0, PI]
// @return x = value of the noise, yz = derivative of the noise, range: [-1, 1]
vec3 gradientNoised(vec2 pos, vec2 scale, float rotation, float seed) 
{
    vec2 sinCos = vec2(sin(rotation), cos(rotation));
    return gradientNoised(pos, scale, mat2(sinCos.y, sinCos.x, sinCos.x, sinCos.y), seed);
}
