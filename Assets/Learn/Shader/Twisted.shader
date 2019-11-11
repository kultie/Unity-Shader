Shader "Learn/Post Processing/Twisted"
{
    Properties
    {
        [HideInInspector]
        _MainTex ("Texture", 2D) = "white" {}
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

            float4 effect(sampler2D tex, float2 uv, float time){
                float radius = _ScreenParams.x * 1.4;
                float angle = sin(time);
                float2 center = float2(_ScreenParams.x * 0.8, _ScreenParams.y) * 1.5;

                float2 texSize = float2(_ScreenParams.x/0.6, _ScreenParams.y/0.5);
                float2 tc = uv * texSize;

                tc -= center;
                float dist = length(tc * sin(time / 5.0));
                if(dist < radius){
                    float percent = (radius - dist) / radius;
                    float theta = percent * percent * angle * 8.0;
                    float s = sin(theta/2.);
                    float c = cos(sin(theta/2.));
                    tc = float2(dot(tc, float2(c, -s)), dot(tc, float2(s, c)));
                }
                tc += center;
                float3 color = tex2D(tex, (tc/texSize)).rgb;
                return float4(color,1.0);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                return effect(_MainTex,uv,_Time[1]);
            }
            ENDCG
        }
    }
}
