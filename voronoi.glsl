// Voronoi with the distance from edges.
// @param scale Number of tiles, must be  integer for tileable results, range: [2, inf]
// @param jitter Jitter factor for the voronoi cells, if zero then it will result in a square grid, range: [0, 1], default: 1.0
// @param phase The phase for rotating the cells, range: [0, inf], default: 0.0
// @param seed Seed to randomize result, range: [0, inf], default: 0.0
// @return Returns the distance from the cell edges, yz = tile position of the cell, range: [0, 1]
vec3 voronoi(vec2 pos, vec2 scale, float jitter, float phase, float seed)
{
     // voronoi based on Inigo Quilez: https://archive.is/Ta7dm
    const float kPI2 = 6.2831853071;
    pos *= scale;
    vec2 i = floor(pos);
    vec2 f = pos - i;

    //TODO: optimize this
    // first pass
    vec2 minPos, tilePos;
    float minDistance = 1e+5;
    for (int y=-1; y<=1; y++)
    {
        for (int x=-1; x<=1; x++)
        {
            vec2 n = vec2(float(x), float(y));
            vec2 cPos = hash2D(mod(i + n, scale) + seed) * jitter;
            cPos = 0.5 * sin(phase + kPI2 * cPos) + 0.5;
            vec2 rPos = n + cPos - f;

            float d = dot(rPos, rPos);
            if(d < minDistance)
            {
                minDistance = d;
                minPos = rPos;
                tilePos = cPos;
            }
        }
    }

    // second pass, distance to edges
    minDistance = 1e+5;
    for (int y=-2; y<=2; y++)
    {
        for (int x=-2; x<=2; x++)
        { 
            vec2 n = vec2(float(x), float(y));
            vec2 cPos = hash2D(mod(i + n, scale) + seed) * jitter;
            cPos = 0.5 * sin(phase + kPI2 * cPos) + 0.5;
            vec2 rPos = n + cPos - f;
            
            vec2 v = minPos - rPos;
            if(dot(v, v) > 1e-5)
                minDistance = min(minDistance, dot( 0.5 * (minPos + rPos), normalize(rPos - minPos)));
        }
    }

    return vec3(minDistance, tilePos);
}

// @param scale Number of tiles, must be  integer for tileable results, range: [2, inf]
// @param jitter Jitter factor for the voronoi cells, if zero then it will result in a square grid, range: [0, 1], default: 1.0
// @param variance The color variance, if zero then it will result in grayscale pattern, range: [0, 1], default: 1.0
// @param factor The position factor multiplier, range: [0, 10], default: 1.0
// @param seed Random seed for the color pattern, range: [0, inf], default: 0.0
// @return Returns the color of the pattern cells., range: [0, 1]
vec3 voronoiPattern(vec2 pos, vec2 scale, float jitter, float variance, float factor, float seed)
{
    vec2 tilePos = voronoi(pos, scale, jitter, 0.0, 0.0).yz;
    float rand = abs(hash1D(tilePos * factor + seed));
    return (rand < variance ? hash3D(tilePos + seed) : vec3(rand));
}

// @param scale Number of tiles, must be  integer for tileable results, range: [2, inf]
// @param jitter Jitter factor for the voronoi cells, if zero then it will result in a square grid, range: [0, 1], default: 1.0
// @param width Width of the lines, range: [0, 1], default: 0.1
// @param smoothness Controls how soft the lines are, range: [0, 1], default: 0.0
// @param warp The warp strength, range: [0, 1], default: 0.0
// @param warpScale The scale of warp, range: [0, 1], default: 2.0
// @param warpSmudge If true creates a smudge effect on the lines, range: [false, true], default: false
// @param seed Seed to randomize result, range: [0, inf], default: 0.0
// @return Returns the cell position and the value of the pattern, range: [0, 1]
vec3 cracks(vec2 pos, vec2 scale, float jitter, float width, float smoothness, float warp, float warpScale, bool warpSmudge, float smudgePhase, float seed)
{
    vec3 g = gradientNoised(pos, scale * warpScale, smudgePhase, seed);
    pos += (warpSmudge ? g.yz : g.xx) * 0.1 * warp;
    vec3 v = voronoi(pos, scale, jitter, 0.0, seed);
    return vec3(smoothstep(max(width - smoothness, 0.0), width + fwidth(v.x), v.x), v.yz);
}

// @param scale Number of tiles, must be  integer for tileable results, range: [2, inf]
// @param jitter Jitter factor for the voronoi cells, if zero then it will result in a square grid, range: [0, 1], default: 1.0
// @param width Width of the lines, range: [0, 1], default: 0.1
// @param smoothness Controls how soft the lines are, range: [0, 1], default: 0.0
// @param warp The warp strength, range: [0, 1], default: 0.0
// @param warpScale The scale of warp, range: [0, 1], default: 2.0
// @param warpSmudge If true creates a smudge effect on the lines, range: [false, true], default: false
// @param seed Seed to randomize result, range: [0, inf], default: 0.0
// @return Returns the value of the pattern, range: [0, 1]
float cracks(vec2 pos, vec2 scale, float jitter, float width, float smoothness, float warp, float warpScale, bool warpSmudge, float seed)
{   
    return cracks(pos, scale, jitter, width, smoothness, warp, warpScale, warpSmudge, 0.0, seed).x;
}
