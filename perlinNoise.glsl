float perlinNoise(const in vec2 pos, vec2 scale)
{
    // classic Perlin noise based on Stefan Gustavson
    scale = floor(scale);
    vec2 p = pos * scale;
    vec4 i = mod(floor(p.xyxy) + vec4(0.0, 0.0, 1.0, 1.0), scale.xyxy);
    vec4 f = fract(p.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
    i = mod(i, 289.0); // avoid truncation effects in permutation
    
    vec4 ix = i.xzxz;
    vec4 iy = i.yyww;
    vec4 fx = f.xzxz;
    vec4 fy = f.yyww;
    
    vec4 ixy = permute(permute(ix) + iy);
    vec4 gx = 2.0 * fract(ixy * 0.0243902439) - 1.0; // 1/41 = 0.024...
    vec4 gy = abs(gx) - 0.5;
    vec4 tx = floor(gx + 0.5);
    gx = gx - tx;
    
    vec2 g00 = vec2(gx.x,gy.x);
    vec2 g10 = vec2(gx.y,gy.y);
    vec2 g01 = vec2(gx.z,gy.z);
    vec2 g11 = vec2(gx.w,gy.w);
    
    vec4 norm = 1.79284291400159 - 0.85373472095314 * 
    vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
    g00 *= norm.x;
    g01 *= norm.y;
    g10 *= norm.z;
    g11 *= norm.w;
    float n00 = dot(g00, vec2(fx.x, fy.x));
    float n10 = dot(g10, vec2(fx.y, fy.y));
    float n01 = dot(g01, vec2(fx.z, fy.z));
    float n11 = dot(g11, vec2(fx.w, fy.w));
    
    vec2 fade_xy = smootherStep(f.xy);
    vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
    float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
    return 2.0 * n_xy;
}

// @note position must be premultiplied with the scale
float perlinNoise(const in vec2 pos, vec2 scale, const in mat2 rotation) 
{
    scale = floor(scale);
    vec2 p = pos;
    vec2 i = floor(p);
    vec2 a = i;
    vec2 b = i + vec2(1.0, 0.0);
    vec2 c = i + vec2(0.0, 1.0);
    vec2 d = i + vec2(1.0, 1.0);

    vec2 g0 = rotation * hash2d(mod(a, scale));
    vec2 g1 = rotation * hash2d(mod(b, scale));
    vec2 g2 = rotation * hash2d(mod(c, scale));
    vec2 g3 = rotation * hash2d(mod(d, scale));

    vec2 u = smootherStep(p - i);
    float ab = (1.0 - u.x) * dot(g0, (p - a)) + u.x * dot(g1, (p - b)); // upper points
    float cd = (1.0 - u.x) * dot(g2, (p - c)) + u.x * dot(g3, (p - d)); // lower points
    return 2.3 * mix(ab, cd, u.y);
}
