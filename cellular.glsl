vec2 cellularNoise(const in vec2 pos, const in vec2 scale, const in float jitter) 
{		
    // classic cellular/voronoi noise
    vec2 p = pos * floor(scale) + 0.5;
    vec2 i = floor(p);
    vec2 f = fract(p);

    vec2 distances = vec2(1.0);
    for (int y=-1; y<=1; y++)
    {
        for (int x=-1; x<=1; x++)
        {
            vec2 n = vec2(float(x), float(y));
            vec2 cPos = hash2d(mod(i + n, scale)) * jitter;
            vec2 rPos = n + cPos - f;

            float d = length(rPos);
            if(d < distances.x)
            {
                distances.y = distances.x;
                distances.x = d;
            }
            else if(d < distances.y)
            {
                distances.y = d;
            }
        }
    }
    return sqrt(distances);
}

float metaballs(const in vec2 pos, const in vec2 scale, const in float jitter) 
{		
    // classic cellular/voronoi noise
    vec2 p = pos * floor(scale) + 0.5;
    vec2 i = floor(p);
    vec2 f = fract(p);

    float minDistance = 1.0;
    for (int y=-1; y<=1; y++)
    {
        for (int x=-1; x<=1; x++)
        {
            vec2 n = vec2(float(x), float(y));
            vec2 cPos = hash2d(mod(i + n, scale)) * jitter;
            vec2 rPos = n + cPos - f;

            float d = length(rPos);
            minDistance = min(minDistance, minDistance * d);
        }
    }
    return minDistance;
}