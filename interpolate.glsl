
// the main noise interpolation function using a hermite polynomial
float noiseInterpolate(const in float x) 
{ 
    float x2 = x * x;
    return x2 * x * (x * (x * 6.0 - 15.0) + 10.0); 
}
vec2 noiseInterpolate(const in vec2 x) 
{ 
    vec2 x2 = x * x;
    return x2 * x * (x * (x * 6.0 - 15.0) + 10.0); 
}
vec3 noiseInterpolate(const in vec3 x) 
{ 
    vec3 x2 = x * x;
    return x2 * x * (x * (x * 6.0 - 15.0) + 10.0); 
}
vec4 noiseInterpolate(const in vec4 x) 
{ 
    vec4 x2 = x * x;
    return x2 * x * (x * (x * 6.0 - 15.0) + 10.0); 
}
vec2 noiseInterpolateDu(const in float x) 
{ 
    float x2 = x * x;
    float u = x2 * x * (x * (x * 6.0 - 15.0) + 10.0); 
    float du = 30.0 * x2 * (x * (x - 2.0) + 1.0);
    return vec2(u, du);
}
vec4 noiseInterpolateDu(const in vec2 x) 
{ 
    vec2 x2 = x * x;
    vec2 u = x2 * x * (x * (x * 6.0 - 15.0) + 10.0); 
    vec2 du = 30.0 * x2 * (x * (x - 2.0) + 1.0);
    return vec4(u, du);
}
void noiseInterpolateDu(const in vec3 x, out vec3 u, out vec3 du) 
{ 
    vec3 x2 = x * x;
    u = x2 * x * (x * (x * 6.0 - 15.0) + 10.0); 
    du = 30.0 * x2 * (x * (x - 2.0) + 1.0);
}