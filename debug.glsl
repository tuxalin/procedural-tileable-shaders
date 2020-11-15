
float sdfSegment(vec2 p, vec2 a, vec2 b) 
{
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba,ba), 0.0, 1.0);
	return length(pa - ba * h);
}

float drawLine(vec2 p1, vec2 p2, vec2 uv)
{ 
    float d = sdfSegment(uv, p1, p2);
    return 1.0 - sign(d - 0.005);
}

vec3 drawGradientDir(vec2 grid, vec2 scale, vec2 g0, vec2 uv)    
{
    uv = uv * 2.0 - 1.0;
    vec4 offsets = 2.0 / scale.xyxy;
    offsets *= vec2(1.0, 0.0).xxyy;
    
    g0 *= 0.1;
    grid = (grid / scale.xy) * 2.0 - 1.0;
    
    float r;
    r += drawLine(grid + offsets.ww, grid + offsets.ww + g0, uv);
    r += drawLine(grid + offsets.xy, grid + offsets.xy + g0, uv);
    r += drawLine(grid + offsets.xz, grid + offsets.xz + g0, uv);
    r += drawLine(grid + offsets.zw, grid + offsets.zw + g0, uv);
    r += drawLine(grid + offsets.zy, grid + offsets.zy + g0, uv);
    return r * min(hash3d(grid), vec3(0.1));
}
