// @note position must be premultiplied with the scale
vec3 voronoi(const in vec2 pos, const in vec2 scale, const in float jitter, const in mat2 rotation, out vec2 tilePos)
{
    // voronoi based on Inigo Quilez
    vec2 i = floor(pos);
    vec2 f = fract(pos);

    // first pass
    vec2 minPos;
    float F1 = 1e+5;
    float F2 = 1e+5;
    for (int y=-1; y<=1; y++)
    {
        for (int x=-1; x<=1; x++)
        {
            vec2 n = vec2(float(x), float(y));
            vec2 cPos = rotation * hash2d(mod(i + n, scale)) * jitter;
            vec2 rPos = n + cPos - f;

            float d = dot(rPos, rPos);
            if(d < F1)
            {
                F2 = F1;
                F1 = d;
                
                minPos = rPos;
                tilePos = cPos;
            }
            else if(d < F2) 
            {
                F2 = d;
            }
        }
    }

    // second pass, distance to borders
    float minDistance = 1e+5;
    for (int y=-2; y<=2; y++)
    {
        for (int x=-2; x<=2; x++)
        { 
            vec2 n = vec2(float(x), float(y));
            vec2 cPos = rotation * hash2d(mod(i + n, scale)) * jitter;
            vec2 rPos = n + cPos - f;
            
            vec2 v = minPos - rPos;
            if(dot(v, v) > 1e-5)
                minDistance = min(minDistance, dot( 0.5 * (minPos + rPos), normalize(rPos - minPos)));
        }
    }

    return vec3(minDistance, F1, F2);
}

vec3 voronoi(const in vec2 pos, const in vec2 scale, const in float jitter, out vec2 tilePos)
{
    mat2 identity = mat2(1.0, 0.0, 0.0, 1.0);
    return voronoi(pos * scale, scale, jitter, identity, tilePos);
}
