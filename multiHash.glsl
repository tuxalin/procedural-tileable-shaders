
// based on GPU Texture-Free Noise by Brian Sharpe: https://archive.is/Hn54S
vec3 permutePrepareMod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 permutePrepareMod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 permuteResolve(vec4 x) { return fract( x * (7.0 / 288.0 )); }
vec4 permuteHashInternal(vec4 x) { return fract(x * ((34.0 / 289.0) * x + (1.0 / 289.0))) * 289.0; }

// generates a random number for each of the 4 cell corners
vec4 permuteHash2D(vec4 cell)    
{
    cell = permutePrepareMod289(cell * 32.0);
    return permuteResolve(permuteHashInternal(permuteHashInternal(cell.xzxz) + cell.yyww));
}

// generates 2 random numbers for each of the 4 cell corners
void permuteHash2D(vec4 cell, out vec4 hashX, out vec4 hashY)
{
    cell = permutePrepareMod289(cell);
    hashX = permuteHashInternal(permuteHashInternal(cell.xzxz) + cell.yyww);
    hashY = permuteResolve(permuteHashInternal(hashX));
    hashX = permuteResolve(hashX);
}

// generates 2 random numbers for the coordinate
vec2 betterHash2D(vec2 x)
{
    uvec2 q = uvec2(x);
    uint h0 = ihash1D(ihash1D(q.x) + q.y);
    uint h1 = h0 * 1933247u + ~h0 ^ 230123u;
    return vec2(h0, h1)  * (1.0 / float(0xffffffffu));
}

// generates a random number for each of the 4 cell corners
vec4 betterHash2D(vec4 cell)    
{
    uvec4 i = uvec4(cell);
    uvec4 hash = ihash1D(ihash1D(i.xzxz) + i.yyww);
    return vec4(hash) * (1.0 / float(0xffffffffu));
}

// generates 2 random numbers for each of the 4 cell corners
void betterHash2D(vec4 cell, out vec4 hashX, out vec4 hashY)
{
    uvec4 i = uvec4(cell);
    uvec4 hash0 = ihash1D(ihash1D(i.xzxz) + i.yyww);
    uvec4 hash1 = ihash1D(hash0 ^ 1933247u);
    hashX = vec4(hash0) * (1.0 / float(0xffffffffu));
    hashY = vec4(hash1) * (1.0 / float(0xffffffffu));
}

// generates 2 random numbers for each of the 2D coordinates
vec4 betterHash2D(vec2 coords0, vec2 coords1)
{
    uvec4 i = uvec4(coords0, coords1);
    uvec4 hash = ihash1D(ihash1D(i.xz) + i.yw).xxyy;
    hash.yw = hash.yw * 1933247u + ~hash.yw ^ 230123u;
    return vec4(hash) * (1.0 / float(0xffffffffu));;
}

// generates 2 random numbers for each of the four 2D coordinates
void betterHash2D(vec4 coords0, vec4 coords1, out vec4 hashX, out vec4 hashY)
{
    uvec4 hash0 = ihash1D(ihash1D(uvec4(coords0.xz, coords1.xz)) + uvec4(coords0.yw, coords1.yw));
    uvec4 hash1 = hash0 * 1933247u + ~hash0 ^ 230123u;
    hashX = vec4(hash0) * (1.0 / float(0xffffffffu));
    hashY = vec4(hash1) * (1.0 / float(0xffffffffu));
} 

// 3D

// generates a random number for each of the 8 cell corners
void permuteHash3D(vec3 cell, vec3 cellPlusOne, out vec4 lowHash, out vec4 highHash)     
{
    cell = permutePrepareMod289(cell);
    cellPlusOne = step(cell, vec3(287.5)) * cellPlusOne;

    highHash = permuteHashInternal(permuteHashInternal(vec2(cell.x, cellPlusOne.x).xyxy) + vec2(cell.y, cellPlusOne.y).xxyy);
    lowHash = permuteResolve(permuteHashInternal(highHash + cell.zzzz));
    highHash = permuteResolve(permuteHashInternal(highHash + cellPlusOne.zzzz));
}

// generates a random number for each of the 8 cell corners
void fastHash3D(vec3 cell, vec3 cellPlusOne, out vec4 lowHash, out vec4 highHash)
{
    // based on: https://archive.is/wip/7j1wv
    const vec2 kOffset = vec2(50.0, 161.0);
    const float kDomainScale = 289.0;
    const float kLargeValue = 635.298681;
    const float kk = 48.500388;
    
    //truncate the domain, equivalant to mod(cell, kDomainScale)
    cell -= floor(cell.xyz * (1.0 / kDomainScale)) * kDomainScale;
    cellPlusOne = step(cell, vec3(kDomainScale - 1.5)) * cellPlusOne;

    vec4 r = vec4(cell.xy, cellPlusOne.xy) + kOffset.xyxy;
    r *= r;
    r = r.xzxz * r.yyww;
    highHash.xy = vec2(1.0 / (kLargeValue + vec2(cell.z, cellPlusOne.z) * kk));
    lowHash = fract(r * highHash.xxxx);
    highHash = fract(r * highHash.yyyy);
}

// generates a random number for each of the 8 cell corners
void betterHash3D(vec3 cell, vec3 cellPlusOne, out vec4 lowHash, out vec4 highHash)
{
    uvec4 cells = uvec4(cell.xy, cellPlusOne.xy);  
    uvec4 hash = ihash1D(ihash1D(cells.xzxz) + cells.yyww);
    
    lowHash = vec4(ihash1D(hash + uint(cell.z))) * (1.0 / float(0xffffffffu));
    highHash = vec4(ihash1D(hash + uint(cellPlusOne.z))) * (1.0 / float(0xffffffffu));
}

// @note Can change to (faster to slower order): permuteHash2D, betterHash2D
// Each has a tradeoff between quality and speed, some may also experience artifacts for certain ranges and are not realiable.
#define multiHash2D betterHash2D

// @note Can change to (faster to slower order): fastHash3D, permuteHash3D, betterHash3D
// Each has a tradeoff between quality and speed, some may also experience artifacts for certain ranges and are not realiable.
#define multiHash3D betterHash3D

void smultiHash2D(vec4 cell, out vec4 hashX, out vec4 hashY)
{
    multiHash2D(cell, hashX, hashY);
    hashX = hashX * 2.0 - 1.0; 
    hashY = hashY * 2.0 - 1.0;
}