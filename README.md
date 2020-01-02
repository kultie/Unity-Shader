# Unity-Shader
Simple Shader Learning Respo from [ShaderToy](https://www.shadertoy.com/)

# GLSL Unity Shader Cheat sheet
## Syntax
| GLSL  | Unity |
| ------------- | ------------- |
| vec<n>  | float<n>  |
| mat<n>  | float<n>x<n>  |
| fract  | frac<n>x<n>  |
| mix<n>  | lerp<n>x<n>  |
| mod<n>  | x-y*floor(x/y)  |
| atan(x,y)  | atan2(y,x)  |
| texture  | tex2D  |
|Matrix "*" | Matrix mul()| 

## Type Casting

| GLSL  | Unity |
| ------------- | ------------- |
| vec3  | float3(1,1,1) or 1  |
| vec3 a = 1  | float3 a = 1  |

## Specific
| GLSL  | Unity |
| ------------- | ------------- |
| mainImage  | frag or surf |
| fragCoord/iResolution  | i.uv or IN.uv_MainTex  |
| iTime  | _Time.y or _Time[1] |
| iMouse  | Add manually |
|fragColor = color| return color|
|iChannel<n> | Add manually |
