float perlinNoise(const in vec2 pos, const in vec2 scale)
{
    // classic Perlin noise based on Stefan Gustavson
    vec2 p = pos * floor(scale);
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
    return 2.3 * n_xy;
}
