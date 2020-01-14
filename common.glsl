float hash(const in float x)
{ 
    return fract(sin(x) * 43758.5453123);
}

float hash(const in vec2 x) 
{ 
    return fract(sin(dot(x, vec2(12.9898, 4.1414))) * 43758.5453); 
}

vec2 hash2d(const in float x)
{
    vec2 q = vec2(dot(vec2(x),vec2(127.1,311.7)), 
                  dot(vec2(x),vec2(269.5,183.3)));
    return fract(sin(q)*43758.5453);
}

vec2 hash2d(const in vec2 x)
{
    vec2 q = vec2(dot(x,vec2(127.1,311.7)), 
                  dot(x,vec2(269.5,183.3)));
    return fract(sin(q)*43758.5453);
}

vec3 hash3d(const in vec2 x)
{
    vec3 q = vec3( dot(x, vec2(127.1,311.7)), 
                   dot(x, vec2(269.5,183.3)), 
                   dot(x, vec2(419.2,371.9)));
    return fract(sin(q) * 43758.5453);
}

vec3 permute(const in vec3 x) 
{ 
    return mod(((x * 34.0) + 1.0) * x * 1.0, 289.0); 
}

vec4 permute(const in vec4 x) 
{ 
    return mod(((x * 34.0) + 1.0) * x * 1.0, 289.0); 
}

vec2 smootherStep(const in vec2 x) 
{ 
    vec2 x2 = x * x;
    return x2 * x * (x * (x * 6.0 - 15.0) + 10.0); 
}
