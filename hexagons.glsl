
float sdfHexagon(vec2 pos, float radius, bool isVertical)
{
    // 60 degrees, tan of 30 degrees and one over angle
    const vec3 kAngles = vec3(1.047198, 0.954929249292, 0.523599);
    // rotate 90 degrees
    pos = isVertical ? pos: -pos.yx;
    
    vec2 temp = vec2(radius, atan(pos.y, pos.x)) * kAngles.zy + vec2(0.0, 0.5);
    float angle = kAngles.x * floor(temp.y);
    vec2 rotation = vec2(sin(angle), cos(angle));
    pos = pos.x * rotation.yx * vec2(1.0, -1.0) + pos.y * rotation;

    float he = temp.x; 
    vec2 offset = vec2(radius, clamp(pos.y, -he, he));
    return length(pos - offset) * sign(pos.x - radius);
}

// Computes the radii of the hexagons.
// @param scale Number of tiles, must be an integer for tileable results, range: [1, inf]
// @param isVertical Changes the orientation of the hexagons.
// @return xy = horizontal or vertical radius, zw = diagonal radius, range: [0, 1]
vec4 tileHexagonsRadii(vec2 scale, bool isVertical)
{
    vec2 tileSize = 0.3333333 / scale;
    // the horizontal and diagonal radii
    vec4 radii = isVertical ? tileSize.yyyx : tileSize.xxxy;
    return radii * vec4(1.0, 0.0, 0.5, 1.5);
}

// 2D Hexagonal grid tiling.
// @param scale Number of tiles, must be an integer for tileable results, range: [1, inf]
// @param isVertical Changes the orientation of the hexagons.
// @return xy = normalized UV, zw = center position in UV space, range: [0, 1]
vec4 tileHexagons(vec2 pos, vec2 scale, bool isVertical)
{
    const float kSqrtThree = 1.73205080757;
    const float kHalfSqrtThree = 0.866025403785;
    const float kInvSqrtThree = 0.57735026919;
    vec4 hexScale = vec4(1.0, kSqrtThree, 1.0, kInvSqrtThree);
    hexScale = isVertical ? hexScale : hexScale.yxwz;
    vec4 r = vec4(1.0, kHalfSqrtThree, 0.5, kInvSqrtThree);
    r = isVertical ? r : r.yxwz;
    
    pos *= scale * hexScale.xy;
    vec4 center = floor(pos.xyxy * hexScale.zwzw + vec4(0.0, 0.0, -r.zw)) + 0.5;
    vec4 uv = pos.xyxy - center * hexScale.xyxy + vec4(0.0, 0.0, -0.5 * hexScale.xy);
    // dot product
    vec4 temp = uv * uv;
    temp.xy = temp.xz + temp.yw;
    vec4 uvCenter = temp.x < temp.y ? vec4(uv.xy, center.xy) : vec4(uv.zw, center.zw + 0.5);
    // normalize UV range and transform center position to UV space
    return uvCenter * vec4(r.xy, 1.0 / scale) + vec4(0.5, 0.5, 0.0, 0.0);
}

// 2D Hexagonal grid tiling.
// @param scale Number of tiles, must be an integer for tileable results, range: [1, inf]
// @param isVertical Changes the orientation of the hexagons.
// @return xy = normalized UV, zw = center position in UV space, range: [0, 1], edgeDistance = distonce from the edge
vec4 tileHexagons(vec2 pos, vec2 scale, bool isVertical, out float edgeDistance)
{
    const float kSqrtThree = 1.73205080757;
    const float kHalfSqrtThree = 0.866025403785;
    const float kInvSqrtThree = 0.57735026919;
    vec4 hexScale = vec4(1.0, kSqrtThree, 1.0, kInvSqrtThree);
    hexScale = isVertical ? hexScale : hexScale.yxwz;
    vec4 r = vec4(1.0, kHalfSqrtThree, 0.5, kInvSqrtThree);
    r = isVertical ? r : r.yxwz;
    
    vec2 invScale = 1.0 / scale;
    vec2 p = pos * scale * hexScale.xy;
    vec4 center = floor(p.xyxy * hexScale.zwzw + vec4(0.0, 0.0, -r.zw)) + 0.5;
    vec4 uv = p.xyxy - center * hexScale.xyxy + vec4(0.0, 0.0, -0.5 * hexScale.xy);
    // dot product
    vec4 temp = uv * uv;
    temp.xy = temp.xz + temp.yw;
    vec4 uvCenter = temp.x < temp.y ? vec4(uv.xy, center.xy) : vec4(uv.zw, center.zw + 0.5);
    // normalize UV range and transform center position to UV space
    uvCenter = uvCenter * vec4(r.xy, invScale) + vec4(0.5, 0.5, 0.0, 0.0);
    
    {
        // 60 degrees, tan of 30 degrees and one over angle
        const vec3 kAngles = vec3(1.047198, 0.954929249292, 0.523599);
        
        float size = isVertical ? invScale.x : invScale.y;
        p = (pos - uvCenter.zw) * scale * hexScale.xy * size;
        // rotate 90 degrees
        p = isVertical ? p: -p.yx;
        float radius = size * 0.5;
        temp.xy = vec2(radius, atan(p.y, p.x)) * kAngles.zy + vec2(0.0, 0.5);
        float angle = kAngles.x * floor(temp.y);
        vec2 rotation = vec2(sin(angle), cos(angle));
        p = p.x * rotation.yx * vec2(1.0, -1.0) + p.y * rotation;

        vec2 offset = vec2(radius, clamp(p.y, -temp.x, temp.x));
        edgeDistance = length(p - offset) / radius;
    }
    
    return uvCenter;
}

// 2D Gradient noise using an hexagonal grid.
// @param scale Number of tiles, must be an integer for tileable results, range: [1, inf]
// @param size The size of the gradient, range: [0, 2], default: 1.0
// @param jitter Jitter factor of the X and Y axis for the offsets, range: [0, 1], default: 1.0
// @param isVertical Changes the orientation of the hexagons.
// @return Value of the noise, range: [0, 1]
float noiseHexagons(vec2 pos, vec2 scale, float size, vec2 jitter, bool isVertical, bool useCenter)
{
    const float kSqrtThree = 1.73205080757;
    const float kHalfSqrtThree = 0.866025403785;
    const float kInvSqrtThree = 0.57735026919;
    
    vec2 invScale = 1.0 / scale;
    vec2 center;
    {
        vec4 hexScale = vec4(1.0, kSqrtThree, 1.0, kInvSqrtThree);
        hexScale = isVertical ? hexScale : hexScale.yxwz;
        vec4 r = vec4(1.0, kHalfSqrtThree, 0.5, kInvSqrtThree);
        r = isVertical ? r : r.yxwz;
    
        vec2 p = pos * scale * hexScale.xy;
        vec4 c = floor(p.xyxy * hexScale.zwzw + vec4(0.0, 0.0, -r.zw)) + 0.5;
        vec4 uv = p.xyxy - c * hexScale.xyxy + vec4(0.0, 0.0, -0.5 * hexScale.xy);
        // dot product
        vec4 temp = uv * uv;
        temp.xy = temp.xz + temp.yw;
        center = temp.x < temp.y ? c.xy : c.zw + 0.5;
        // normalize UV range and transform center position to UV space
        center = center * invScale;
    }
    
    // the horizontal/vertical and diagonal radii
    vec4 radii = isVertical ? invScale.yyxy * vec4(0.0, 0.33333333, 0.5, 0.1666666666) : invScale.xxxy * vec4(0.33333333, 0.0, 0.1666666666, 0.5);
    float radius = isVertical ? min(radii.y, radii.z) : min(radii.x, radii.w);

    jitter *= vec2(0.5, 0.5) * radius;
    vec4 p0 =  center.xyxy - radii, p1 =  center.xyxy + radii;
    vec4 hash0, hash1;
    betterHash2D(fract(p0) * 8192.0, fract(p1) * 8192.0, hash0, hash1);
    vec4 temp = hash0;
    hash0 = vec4(temp.xy, hash1.xy).xzyw * 2.0 - 1.0;
    hash1 = vec4(temp.zw, hash1.zw).xzyw * 2.0 - 1.0;
    
    vec4 dc;
    temp = pos.xyxy - p0 + hash0 * jitter.xyxy;
    temp *= temp;
    dc.xy = temp.xz + temp.yw;
    
    temp = pos.xyxy - p1 + hash1 * jitter.xyxy;
    temp *= temp;
    dc.zw = temp.xz + temp.yw;
    dc.xy = min(dc.xy, dc.zw);
    
    p0 = center.xyxy + radii.zwzw * vec4(-1.0, 1.0, 1.0, -1.0);
    betterHash2D(fract(p0) * 8192.0, fract(center.xyxy) * 8192.0, hash0, hash1);
    temp = hash0;
    hash0 = vec4(temp.xy, hash1.xy).xzyw * 2.0 - 1.0;
    hash1.xy = vec2(temp.z, hash1.z) * 2.0 - 1.0;
    
    temp = pos.xyxy - p0 + hash0 * jitter.xyxy;
    temp *= temp;
    dc.zw = temp.xz + temp.yw;
    dc.xy = min(dc.xy, dc.zw);
    
    float d = min(dc.x, dc.y);
    if (useCenter)
    {
        temp.xy = pos - center + hash1.xy * jitter.xy * 0.5;
        d = min(d, dot(temp.xy, temp.xy));
    }
    radius *= size;
    
    d = sqrt(d) - radius;
    return max(noiseInterpolate(-d / radius), 0.0);
}

// 2D Gradient noise using an hexagonal grid.
// @param scale Number of tiles, must be an integer for tileable results, range: [1, inf]
// @param size The size of the gradient, range: [0, 2], default: 1.0
// @param jitter Jitter factor of the X and Y axis for the offsets, range: [0, 1], default: 1.0
// @param isVertical Changes the orientation of the hexagons.
// @return x = value of the noise range: [0, 1], yz = derivative of the noise, range: [-1, 1]
vec3 noiseHexagonsd(vec2 pos, vec2 scale, float size, vec2 disorder, bool isVertical, bool useCenter)
{
    const float kSqrtThree = 1.73205080757;
    const float kHalfSqrtThree = 0.866025403785;
    const float kInvSqrtThree = 0.57735026919;
    
    vec2 invScale = 1.0 / scale;
    vec2 center;
    {
        vec4 hexScale = vec4(1.0, kSqrtThree, 1.0, kInvSqrtThree);
        hexScale = isVertical ? hexScale : hexScale.yxwz;
        vec4 r = vec4(1.0, kHalfSqrtThree, 0.5, kInvSqrtThree);
        r = isVertical ? r : r.yxwz;
    
        vec2 p = pos * scale * hexScale.xy;
        vec4 c = floor(p.xyxy * hexScale.zwzw + vec4(0.0, 0.0, -r.zw)) + 0.5;
        vec4 uv = p.xyxy - c * hexScale.xyxy + vec4(0.0, 0.0, -0.5 * hexScale.xy);
        // dot product
        vec4 temp = uv * uv;
        temp.xy = temp.xz + temp.yw;
        center = temp.x < temp.y ? c.xy : c.zw + 0.5;
        // normalize UV range and transform center position to UV space
        center = center * invScale;
    }
    
    // the horizontal/vertical and diagonal radii
    vec4 radii = isVertical ? invScale.yyxy * vec4(0.0, 0.33333333, 0.5, 0.1666666666) : invScale.xxxy * vec4(0.33333333, 0.0, 0.1666666666, 0.5);
    float radius = isVertical ? min(radii.y, radii.z) : min(radii.x, radii.w);

    disorder *= 0.5 * radius;
    vec4 p0 =  center.xyxy - radii, p1 =  center.xyxy + radii;
    vec4 hash0, hash1;
    betterHash2D(fract(p0) * 8192.0, fract(p1) * 8192.0, hash0, hash1);
    vec4 temp = hash0;
    hash0 = vec4(temp.xy, hash1.xy).xzyw * 2.0 - 1.0;
    hash1 = vec4(temp.zw, hash1.zw).xzyw * 2.0 - 1.0;
    
    vec4 dc;
    vec4 pc;
    p0 = pos.xyxy - p0 + hash0 * disorder.xyxy;
    temp = p0 * p0;
    dc.xy = temp.xz + temp.yw;
    
    p1 = pos.xyxy - p1 + hash1 * disorder.xyxy;
    temp = p1 * p1;
    dc.zw = temp.xz + temp.yw;
    pc = mix(p0, p1, step(dc.zw, dc.xy).xxyy);
    dc.xy = min(dc.xy, dc.zw);
    
    p0 = center.xyxy + radii.zwzw * vec4(-1.0, 1.0, 1.0, -1.0);
    betterHash2D(fract(p0) * 8192.0, fract(center.xyxy) * 8192.0, hash0, hash1);
    temp = hash0;
    hash0 = vec4(temp.xy, hash1.xy).xzyw * 2.0 - 1.0;
    hash1.xy = vec2(temp.z, hash1.z) * 2.0 - 1.0;
    
    p0 = pos.xyxy - p0 + hash0 * disorder.xyxy;
    temp = p0 * p0;
    dc.zw = temp.xz + temp.yw;
    pc = mix(pc, p0, step(dc.zw, dc.xy).xxyy);
    dc.xy = min(dc.xy, dc.zw);
    
    float d = min(dc.x, dc.y);
    pc.xy = dc.x < dc.y ? pc.xy : pc.zw;
    if (useCenter)
    {
        p0.xy = pos - center + hash1.xy * disorder.xy * 0.5;
        dc.x = dot(p0.xy, p0.xy);
        pc.xy = d < dc.x ? pc.xy : p0.xy;
        d = min(d, dc.x);
    }
    radius *= size;
    
    d = sqrt(d);
    vec2 dxdy = pc.xy / d;
    vec2 uDu = noiseInterpolateDu((radius - d) / radius);
    return vec3(uDu.x,  dxdy * (uDu.y * radius)) * step(0.0, uDu.x);
}
