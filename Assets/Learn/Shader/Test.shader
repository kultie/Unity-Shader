Shader "Learn/Test"
{
    Properties
    {
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
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
            float step = 0;

            #define S(a,b,t) smoothstep(a,b,t)
            #define sat(x) clamp(x,0,1)

            float remap01(float a, float b, float t){
                return sat(((t-a)/(b-a)));
            }

            float remap(float a, float b, float c, float d, float t){
                return ((t-a)/(b-a)) * (d-c) + c;
            }


            fixed4 Head(float2 uv){
                fixed4 col = fixed4(.9,.65,.1,1);

                float d = length(uv);
                col.a = S(.5,.49,d);
                float edgeShade = remap01(0.35,0.5,d);
                col.rgb *= 1 - edgeShade * .5;
                return col;
            }

            fixed4 Mouth(float2 uv){
                fixed4 col = fixed4(0,0,0,1);
                return col;
            }

            fixed4 Eye(float2 uv){
                fixed4 col = fixed4(0,0,0,1);
                return col;
            }

            fixed4 Smiley(float2 uv){
                fixed4 col = fixed4(0,0,0,1);
                fixed4 head = Head(uv);

                col = lerp(col,head,head.a);
                return col;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                uv -= 0.5;
                uv.x *= _ScreenParams.x / _ScreenParams.y;
                return Smiley(uv);
            }
            ENDCG
        }
    }
}
