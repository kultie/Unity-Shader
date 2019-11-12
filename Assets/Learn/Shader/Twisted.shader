Shader "Learn/Post Processing/Twisted"
{
    Properties
    {
        [HideInInspector]
        _MainTex ("Texture", 2D) = "white" {}
        _Radius ("Radius", Range(0,1600)) = 0
        _Angle ("Angle", Range(-10,10)) = 0
        _Offset ("Offset", Vector) = (0,0,0,0)
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float _Radius;
            float _Angle;
            float2 _Offset;

            float2 mapCoord(float2 coord){
                coord *= _ScreenParams.xy;
                coord += _ScreenParams.zw;
                return coord;
            }

            float2 unmapCoord(float2 coord){
                coord -= _ScreenParams.zw;
                coord /= _ScreenParams.xy;
                return coord;
            }

            float2 twist(float2 coord){
                coord -= _Offset;
                float dist = length(coord);
                if(dist < _Radius){
                    float ratioDist = (_Radius - dist)/ _Radius;
                    float angleMod = ratioDist * ratioDist * _Angle;
                    float s = sin(angleMod);
                    float c = cos(angleMod);
                    coord = float2 (coord.x * c - coord.y * s, coord.x * s + coord.y * c);
                }
                coord += _Offset;
                return coord;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 coord = mapCoord(i.uv);
                coord = twist(coord);
                coord = unmapCoord(coord);
                return tex2D(_MainTex,coord);
            }
            ENDCG
        }
    }
}
