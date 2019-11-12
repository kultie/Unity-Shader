Shader "Learn/BookOfShader"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        _CatTex ("Cat Texture", 2D) = "white" {}
        _MousePos ("Mouse Position", Vector)  = (0,0,0,1.0)
        _Size ("Size", Range(0.01,.5)) = 0.01
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

            #define PI 3.141592653589793
            #define HALF_PI 1.5707963267948966

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

            float plot(float2 st, float pct){
                return smoothstep(pct-0.01,pct,st.y) - smoothstep(pct,pct + 0.01, st.y);
            }

            sampler2D _MainTex;
            sampler2D _CatTex;
            float2 _MousePos;

            float _Size;

            float bounceOut(float t) {
              const float a = 4.0 / 11.0;
              const float b = 8.0 / 11.0;
              const float c = 9.0 / 10.0;

              const float ca = 4356.0 / 361.0;
              const float cb = 35442.0 / 1805.0;
              const float cc = 16061.0 / 1805.0;

              float t2 = t * t;

              return t < a
                ? 7.5625 * t2
                : t < b
                  ? 9.075 * t2 - 9.9 * t + 3.4
                  : t < c
                    ? ca * t2 - cb * t + cc
                    : 10.8 * t * t - 20.52 * t + 10.72;
            }

            float bounceIn(float t) {
              return 1.0 - bounceOut(1.0 - t);
            }

            float bounceInOut(float t) {
              return t < 0.5
                ? 0.5 * (1.0 - bounceOut(1.0 - t * 2.0))
                : 0.5 * bounceOut(t * 2.0 - 1.0) + 0.5;
            }

            float quadraticInOut(float t) {
                float p = 2.0 * t * t;
                return t < 0.5 ? p : -p + (4.0 * t) - 1.0;
            }

            float quadraticIn(float t) {
                return t * t;
            }

            float quadraticOut(float t) {
                return -t * (t - 2.0);
            }

            float elasticIn(float t) {
                return sin(13.0 * t * HALF_PI) * pow(2.0, 10.0 * (t - 1.0));
            }

            float elasticOut(float t) {
                return sin(-13.0 * (t + 1.0) * HALF_PI) * pow(2.0, -10.0 * t) + 1.0;
            }

            float elasticInOut(float t) {
                return t < 0.5
                ? 0.5 * sin(+13.0 * HALF_PI * 2.0 * t) * pow(2.0, 10.0 * (2.0 * t - 1.0))
                : 0.5 * sin(-13.0 * HALF_PI * ((2.0 * t - 1.0) + 1.0)) * pow(2.0, -10.0 * (2.0 * t - 1.0)) + 1.0;
            }

            float box(in float2 _st, in float2 _size){
                _size = float2(0.5,.5) - _size*0.5;
                float2 uv = smoothstep(_size,_size+float2(0.001,0.001),_st);
                uv *= smoothstep(_size, _size+float2(0.001,0.001), float2(1.0,1.0)-_st);
                return uv.x*uv.y;
            }

            fixed4 frag (v2f IN) : SV_Target
            {
                float2 st = IN.uv;
                fixed3 color = fixed3(0,0,0);

                fixed4 col = tex2D(_MainTex, st);
                float2 translate = _MousePos - 0.5;
                st -= translate;

                // float box_ = box(st, 0.5);
                fixed3 boxColor = fixed3(0,1,0) * tex2D(_CatTex,st*2 - 0.5).a;

                return fixed4(boxColor + col, 1.0);
            }
            ENDCG
        }
    }
}
