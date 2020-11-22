
// Domain warping using a factal sum of value noise.
// @param scale Number of tiles, must be  integer for tileable results, range: [2, inf]
// @param factors Controls the warp Q and R factors, range: [-1, 1], default: vec2(1.0, 1.0)
// @param octaves Number of octaves for the fbm, range: [1, inf]
// @param shifts Shift or seed values for the Q and R domain warp factors, range: [0, inf]
// @param gain Gain for each fbm octave, range: [0, 2], default: 0.5
// @param lacunarity Frequency of the fbm, must be integer for tileable results, range: [1, 32]
// @param slopeness Slope intensity of the derivatives, range: [0, 1], default: 0.5
// @param phase Phase to rotated the noise gradients, range: [0, PI]
// @param negative If true use a negative range for the noise values, range: [false, true]
// @param seed Seed to randomize result, range: [0, inf], default: 0.0
float fbmWarp(vec2 pos, vec2 scale, vec2 factors, int octaves, vec4 shifts, float timeShift, float gain, vec2 lacunarity, float slopeness, float octaveFactor, bool negative, float seed,
              out vec2 q, out vec2 r) 
{
    float qfactor = factors.x;
    float rfactor = factors.y;
    q.x = fbmd(pos, scale, octaves, vec2(0.0), timeShift, gain, lacunarity, slopeness, octaveFactor, seed).x;
    q.y = fbmd(pos, scale, octaves, vec2(shifts.x), timeShift, gain, lacunarity, slopeness, octaveFactor, seed).x;
    q = negative ? q * 2.0 - 1.0 : q;
    
    vec2 np = pos + qfactor * q;
    r.x = fbmd(np, scale, octaves, vec2(shifts.y), timeShift, gain, lacunarity, slopeness, octaveFactor, seed).x;
    r.y = fbmd(np, scale, octaves, vec2(shifts.z), timeShift, gain, lacunarity, slopeness, octaveFactor, seed).x;
    r = negative ? r * 2.0 - 1.0 : r;

    return fbmd(pos + r * rfactor, scale, octaves, vec2(shifts.w), timeShift, gain, lacunarity, slopeness, octaveFactor, seed).x;
}

// Domain warping using a factal sum of perlin noise.
// @param scale Number of tiles, must be  integer for tileable results, range: [2, inf]
// @param factors Controls the warp Q and R factors, range: [-1, 1], default: vec2(0.2, 0.2)
// @param octaves Number of octaves for the fbm, range: [1, inf]
// @param shifts Shift or seed values for the Q and R domain warp factors, range: [0, inf]
// @param gain Gain for each fbm octave, range: [0, 2], default: 0.5
// @param lacunarity Frequency of the fbm, must be integer for tileable results, range: [1, 32]
// @param slopeness Slope intensity of the derivatives, range: [0, 1], default: 0.5
// @param phase Phase to rotated the noise gradients, range: [0, PI]
// @param negative If true use a negative range for the noise values, range: [false, true]
// @param seed Seed to randomize result, range: [0, inf], default: 0.0
float fbmPerlinWarp(vec2 pos, vec2 scale, vec2 factors, int octaves, vec4 shifts, float timeShift, float gain, vec2 lacunarity, float slopeness, float octaveFactor, bool negative, float seed,
                      out vec2 q, out vec2 r) 
{
    float qfactor = factors.x;
    float rfactor = factors.y;
    q.x = fbmdPerlin(pos, scale, octaves, vec2(0.0), timeShift, gain, lacunarity, slopeness, octaveFactor, negative, seed).x;
    q.y = fbmdPerlin(pos, scale, octaves, vec2(shifts.x), timeShift, gain, lacunarity, slopeness, octaveFactor, negative, seed).x;
    
    vec2 np = pos + qfactor * q;
    r.x = fbmdPerlin(np, scale, octaves, vec2(shifts.y), timeShift, gain, lacunarity, slopeness, octaveFactor, negative, seed).x;
    r.y = fbmdPerlin(np, scale, octaves, vec2(shifts.z), timeShift, gain, lacunarity, slopeness, octaveFactor, negative, seed).x;
    
    return fbmdPerlin(pos + r * rfactor, scale, octaves, vec2(shifts.w), timeShift, gain, lacunarity, slopeness, octaveFactor, negative, seed).x;
}

// Domain warping using the derivatives of gradient noise.
// @param factors Controls the warp Q and R factors, range: [-1, 1], default: vec2(1.0, 1.0)
// @param seeds Seeds for the Q and R domain warp factors, range: [-inf, inf]
// @param curl Curl or bend of the noise, range: [0, 1], default: 0.5
// @param seed Seed to randomize result, range: [0, inf], default: 0.0
float curlWarp(vec2 pos, vec2 scale, vec2 factors, vec4 seeds, float curl, float seed,
               out vec2 q, out vec2 r)
{
    float qfactor = factors.x;
    float rfactor = factors.y;
    vec2 curlFactor = vec2(1.0, -1.0) * vec2(curl, 1.0 - curl);
    
    vec2 n = gradientNoised(pos, scale, seed).zy * curlFactor;
    q.x = n.x + n.y;
    n = gradientNoised(pos + hash2D(seeds.x), scale, seed).zy * curlFactor;
    q.x = n.x + n.y;
    
    vec2 np = pos + qfactor * q;
    n = gradientNoised(np + hash2D(seeds.y), scale, seed).zy * curlFactor;
    r.x = n.x + n.y;
    n = gradientNoised(np + hash2D(seeds.z), scale, seed).zy * curlFactor;
    r.y = n.x + n.y;

    return perlinNoise(pos + r * rfactor + hash2D(seeds.w), scale);
}

// Domain warping using the derivatives of perlin noise.
// @param scale Number of tiles, must be  integer for tileable results, range: [2, inf]
// @param strength Controls the warp strength, range: [-1, 1]
// @param phase Noise phase, range: [-inf, inf]
// @param spread The gradient spread, range: [0.001, inf], default: 0.001
// @param factor Pow intensity factor, range: [0, 10]
float perlinNoiseWarp(vec2 pos, vec2 scale, float strength, float phase, float factor, float spread, float seed)
{
    vec2 offset = vec2(spread, 0.0);
    strength *= 32.0 / max(scale.x, scale.y);
    
    vec4 gp;
    gp.x = perlinNoise(pos - offset.xy, scale, phase, seed);
    gp.y = perlinNoise(pos + offset.xy, scale, phase, seed);
    gp.z = perlinNoise(pos - offset.yx, scale, phase, seed);
    gp.w = perlinNoise(pos + offset.yx, scale, phase, seed);
    gp = pow(gp, vec4(factor));
    vec2 warp = vec2(gp.y - gp.x, gp.w - gp.z);
    return pow(perlinNoise(pos + warp * strength, scale, phase, seed), factor);
}
