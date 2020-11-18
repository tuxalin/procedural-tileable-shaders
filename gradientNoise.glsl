// 2D Gradient noise.
// @param scale Number of tiles, must be  integer for tileable results, range: [2, inf]
// @return Value of the noise, range: [-1, 1]
float gradientNoise(vec2 pos, vec2 scale, float seed) 
{
    pos *= scale;
    vec4 i = floor(pos).xyxy + vec2(0.0, 1.0).xxyy;
    vec4 f = (pos.xyxy - i.xyxy) - vec2(0.0, 1.0).xxyy;
    i = mod(i, scale.xyxy) + seed;

    vec4 hashX, hashY;
    smultiHash2D(i, hashX, hashY);

    vec4 gradients = hashX * f.xzxz + hashY * f.yyww;
    vec2 u = noiseInterpolate(f.xy);
    vec2 g = mix(gradients.xz, gradients.yw, u.x);
    return 1.4142135623730950 * mix(g.x, g.y, u.y);
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
    
    vec4 hashX, hashY;
    smultiHash2D(i, hashX, hashY);

    // transform gradients
    vec4 rhash = vec4(hashX.x, hashY.x, hashX.y, hashY.y);
    rhash.xy = transform * rhash.xy;
    rhash.zw = transform * rhash.zw;
    hashX.xy = rhash.xz;
    hashY.xy = rhash.yw;

    rhash = vec4(hashX.z, hashY.z, hashX.w, hashY.w);
    rhash.xy = transform * rhash.xy;
    rhash.zw = transform * rhash.zw;
    hashX.zw = rhash.xz;
    hashY.zw = rhash.yw;
    
    vec4 gradients = hashX * f.xzxz + hashY * f.yyww;
    vec2 u = noiseInterpolate(f.xy);
    vec2 g = mix(gradients.xz, gradients.yw, u.x);
    return 1.4142135623730950 * mix(g.x, g.y, u.y);
}

float gradientNoise(vec2 pos, vec2 scale, float rotation, float seed) 
{
    vec2 sinCos = vec2(sin(rotation), cos(rotation));
    return gradientNoise(pos, scale, mat2(sinCos.y, sinCos.x, sinCos.x, sinCos.y), seed);
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
    
    vec4 hashX, hashY;
    smultiHash2D(i, hashX, hashY);
    vec2 a = vec2(hashX.x, hashY.x);
    vec2 b = vec2(hashX.y, hashY.y);
    vec2 c = vec2(hashX.z, hashY.z);
    vec2 d = vec2(hashX.w, hashY.w);
    
    vec4 gradients = hashX * f.xzxz + hashY * f.yyww;

    vec4 udu = noiseInterpolateDu(f.xy);
    vec2 u = udu.xy;
    vec2 g = mix(gradients.xz, gradients.yw, u.x);
    
    vec2 dxdy = a + u.x * (b - a) + u.y * (c - a) + u.x * u.y * (a - b - c + d);
    dxdy += udu.zw * (u.yx * (gradients.x - gradients.y - gradients.z + gradients.w) + gradients.yz - gradients.x);
    return vec3(mix(g.x, g.y, u.y) * 1.4142135623730950, dxdy);
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
    
    vec4 hashX, hashY;
    smultiHash2D(i, hashX, hashY);

    // transform gradients
    vec4 rhash = vec4(hashX.x, hashY.x, hashX.y, hashY.y);
    rhash.xy = transform * rhash.xy;
    rhash.zw = transform * rhash.zw;
    hashX.xy = rhash.xz;
    hashY.xy = rhash.yw;

    rhash = vec4(hashX.z, hashY.z, hashX.w, hashY.w);
    rhash.xy = transform * rhash.xy;
    rhash.zw = transform * rhash.zw;
    hashX.zw = rhash.xz;
    hashY.zw = rhash.yw;
    
    vec2 a = vec2(hashX.x, hashY.x);
    vec2 b = vec2(hashX.y, hashY.y);
    vec2 c = vec2(hashX.z, hashY.z);
    vec2 d = vec2(hashX.w, hashY.w);
    
    vec4 gradients = hashX * f.xzxz + hashY * f.yyww;

    vec4 udu = noiseInterpolateDu(f.xy);
    vec2 u = udu.xy;
    vec2 g = mix(gradients.xz, gradients.yw, u.x);
    
    vec2 dxdy = a + u.x * (b - a) + u.y * (c - a) + u.x * u.y * (a - b - c + d);
    dxdy += udu.zw * (u.yx * (gradients.x - gradients.y - gradients.z + gradients.w) + gradients.yz - gradients.x);
    return vec3(mix(g.x, g.y, u.y) * 1.4142135623730950, dxdy);
}

// @param scale Number of tiles, must be  integer for tileable results, range: [2, inf]
// @param rotation Rotation for the noise gradients, useful to animate flow, range: [0, PI]
// @return x = value of the noise, yz = derivative of the noise, range: [-1, 1]
vec3 gradientNoised(vec2 pos, vec2 scale, float rotation, float seed) 
{
    vec2 sinCos = vec2(sin(rotation), cos(rotation));
    return gradientNoised(pos, scale, mat2(sinCos.y, sinCos.x, sinCos.x, sinCos.y), seed);
}
